param(
    [string]$DeviceId,
    [switch]$PrepareOnly,
    [switch]$ShowAndroidLogs,
    [switch]$NoResident
)

$ErrorActionPreference = 'Stop'

$adbCommand = Get-Command adb -ErrorAction SilentlyContinue
if ($adbCommand) {
    $adbPath = $adbCommand.Source
} else {
    $sdkPath = if ($env:ANDROID_HOME) { $env:ANDROID_HOME }
        elseif ($env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT }
        else { Join-Path $env:LOCALAPPDATA 'Android\Sdk' }
    $adbPath = Join-Path $sdkPath 'platform-tools\adb.exe'
}

if (-not (Test-Path -LiteralPath $adbPath)) {
    throw 'No se encontro adb. Instala Android SDK Platform-Tools o configura ANDROID_HOME.'
}
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw 'No se encontro Flutter en el PATH.'
}

$deviceOutput = & $adbPath devices
if ($LASTEXITCODE -ne 0) { throw 'No se pudo consultar los dispositivos Android.' }
$deviceIds = @($deviceOutput | ForEach-Object {
    if ($_ -match '^(\S+)\s+device$') { $Matches[1] }
})
if (-not $DeviceId) {
    if ($deviceIds.Count -ne 1) {
        throw 'Conecta un celular con depuracion USB autorizada. Si hay varios dispositivos, usa -DeviceId con su identificador de adb devices.'
    }
    $DeviceId = $deviceIds[0]
}
if ($DeviceId -notin $deviceIds) {
    throw "El dispositivo $DeviceId no esta conectado o no tiene autorizada la depuracion USB."
}

& $adbPath -s $DeviceId reverse tcp:3000 tcp:3000
if ($LASTEXITCODE -ne 0) { throw 'No se pudo conectar el puerto 3000 mediante USB.' }

try {
    $backendResponse = Invoke-WebRequest -Uri 'http://localhost:3000/' -UseBasicParsing -TimeoutSec 5
    if ($backendResponse.StatusCode -ne 200) { throw 'El backend no responde correctamente.' }
} catch {
    throw 'El backend no responde en http://localhost:3000. Inicialo antes de ejecutar la app.'
}

if ($PrepareOnly) {
    Write-Host 'Backend disponible y conexion USB al puerto 3000 preparada.'
    return
}

Push-Location $PSScriptRoot
try {
    Write-Host 'Iniciando la app con el backend http://localhost:3000/api por USB...'
    $flutterArguments = @('run', '-d', $DeviceId, '--dart-define=API_BASE_URL=http://localhost:3000/api')
    if ($NoResident) { $flutterArguments += '--no-resident' }
    if ($ShowAndroidLogs) {
        & flutter @flutterArguments
    } else {
        # Hide only Samsung's repetitive informational frame callbacks.
        # Flutter output, backend errors and Android error messages stay visible.
        & flutter @flutterArguments | Where-Object {
            $_ -notmatch '^I/VRI\[MainActivity\]@[^:]+:\s+(mWNT:|registerCallbackForPendingTransactions)'
        } | ForEach-Object { Write-Host $_ }
    }
    if ($LASTEXITCODE -ne 0) { throw 'Flutter no pudo ejecutar la app. Revisa el error anterior.' }
} finally {
    Pop-Location
}

param(
    [string]$DeviceId
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

Push-Location $PSScriptRoot
try {
    Write-Host 'Iniciando la app con el backend http://localhost:3000/api por USB...'
    & flutter run -d $DeviceId --dart-define=API_BASE_URL=http://localhost:3000/api
    if ($LASTEXITCODE -ne 0) { throw 'Flutter no pudo ejecutar la app. Revisa el error anterior.' }
} finally {
    Pop-Location
}

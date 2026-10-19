# Explicación detallada del código de ULima Recicla

## 1. Propósito y alcance

Este repositorio contiene el cliente móvil de **ULima Recicla**, desarrollado con Flutter y Dart. La aplicación permite autenticarse, registrar una cuenta con correo institucional verificado, recuperar el acceso y consultar los puntos, el historial de reciclaje y el perfil del usuario.

El cliente se comunica por HTTP con la API Tachín Verde. La API es responsable de autenticar usuarios, validar códigos, crear cuentas, calcular y almacenar datos y enviar los correos. El cliente no contiene la configuración SMTP ni envía correos directamente.

La interfaz sí tiene acceso a los endpoints necesarios para registro, inicio de sesión, recuperación, consulta del panel e historial. Otras capacidades documentadas por el backend (por ejemplo, registrar una entrega, administrar tachos, premios, logros y notificaciones) todavía no están expuestas en pantallas de esta aplicación.

## 2. Organización del proyecto

```text
FrontEndMovil/
├── android/                         Configuración nativa Android
├── ios/                             Configuración nativa iOS
├── linux/                           Configuración nativa Linux
├── macos/                           Configuración nativa macOS
├── web/                             Punto de entrada y recursos web
├── windows/                         Configuración nativa Windows
├── lib/
│   ├── main.dart                    Inicio, recuperación de sesión y rutas
│   ├── models/
│   │   ├── app_user.dart            Usuario de la API
│   │   ├── dashboard_data.dart      Métricas, panel e historial paginado
│   │   └── delivery.dart            Entrega de reciclaje
│   ├── screens/
│   │   ├── login_screen.dart        Inicio de sesión
│   │   ├── register_email_screen.dart Datos iniciales y solicitud del código
│   │   ├── register_verify_screen.dart Confirmación del código de registro
│   │   ├── register_password_screen.dart Contraseña y creación de cuenta
│   │   ├── recover_password_screen.dart Recuperación de contraseña
│   │   ├── home_shell.dart          Carga y navegación del área autenticada
│   │   ├── points_screen.dart       Puntos e impacto
│   │   ├── history_screen.dart      Historial y paginación
│   │   └── profile_screen.dart      Perfil y cierre de sesión
│   ├── services/
│   │   └── api_service.dart         Cliente HTTP, autenticación y API
│   ├── theme/
│   │   ├── app_colors.dart          Paleta visual
│   │   └── app_theme.dart           Tema global de Material
│   └── widgets/                     Componentes reutilizables de interfaz
├── test/
│   ├── models_test.dart             Pruebas de conversión de modelos
│   └── widget_test.dart             Prueba básica de la pantalla de acceso
├── pubspec.yaml                     Dependencias y metadatos Flutter
├── analysis_options.yaml            Reglas del analizador Dart
├── README.md                        Configuración y ejecución resumidas
└── ExplicacionDetalladaCodigo.md    Este documento
```

### Dependencias principales

- `http`: envía las solicitudes HTTP al backend.
- `flutter_secure_storage`: guarda el JWT de sesión en almacenamiento seguro del dispositivo.
- `flutter_test`: infraestructura de pruebas.
- `flutter` y Material: interfaz y navegación.

## 3. Arranque de la aplicación y navegación

### `lib/main.dart`

La función `main()`:

1. Inicializa los bindings de Flutter para poder usar plugins antes de crear la interfaz.
2. Llama a `ApiService.instance.restoreSession()` para comprobar si existe una sesión guardada y si el backend todavía la acepta.
3. Crea `UlimaReciclaApp`, cuyo `MaterialApp` configura el título, el tema y las rutas nombradas.

Rutas registradas:

| Ruta | Pantalla | Uso |
|---|---|---|
| `/login` | `LoginScreen` | Entrada sin sesión |
| `/register/email` | `RegisterEmailScreen` | Primer paso del registro |
| `/register/verify` | `RegisterVerifyScreen` | Validación del código de registro |
| `/register/password` | `RegisterPasswordScreen` | Contraseña y creación de la cuenta |
| `/recover` | `RecoverPasswordScreen` | Recuperar acceso |
| `/home` | `HomeShell` | Área que requiere sesión |

El flujo de registro pasa los datos entre pantallas mediante `Navigator.pushNamed(..., arguments: ...)`. La pantalla de verificación añade el token de un solo uso antes de avanzar a la pantalla de contraseña.

### `lib/screens/home_shell.dart`

`HomeShell` es el contenedor de las pantallas autenticadas. Al inicializarse llama a `ApiService.instance.loadDashboard()` y muestra:

- un indicador de progreso mientras llegan los datos;
- un mensaje con opción de reintento si la carga falla;
- las pestañas Puntos, Historial y Mi perfil cuando los datos están disponibles.

Usa `IndexedStack` para conservar las pestañas mientras cambia la selección inferior. Su método `_logout()` elimina el token local mediante `ApiService.logout()` y vuelve al login eliminando las pantallas autenticadas de la navegación.

## 4. Servicios y comunicación con el backend

### `lib/services/api_service.dart`

`ApiService` es un singleton (`ApiService.instance`) compartido por las pantallas. Centraliza URL base, solicitudes HTTP, credenciales, parseo de respuestas y errores.

#### URL base

La URL puede definirse al ejecutar Flutter con:

```text
--dart-define=API_BASE_URL=https://servidor.example/api
```

Si no se define, el servicio usa:

- Android: `http://10.0.2.2:3000/api` (emulador Android conectado al host).
- Otras plataformas: `http://localhost:3000/api`.

La app añade la ruta del recurso a esa URL. Por ejemplo, con el valor predeterminado de Android, `/auth/login` se convierte en `http://10.0.2.2:3000/api/auth/login`.

#### Método privado `_request`

Es el punto común de las llamadas HTTP:

1. Agrega `Accept: application/json`.
2. Si hay body, agrega `Content-Type: application/json` y lo codifica como JSON.
3. Si la ruta requiere sesión, lee el JWT de almacenamiento seguro y agrega `Authorization: Bearer <JWT>`. Si no existe, genera `ApiException` solicitando volver a iniciar sesión.
4. Envía la solicitud y espera como máximo 20 segundos.
5. Convierte errores de conexión y timeout en mensajes de `ApiException`.
6. Comprueba que la respuesta sea JSON con el formato esperado. Para errores HTTP o `ok != true`, usa el mensaje `mensaje` o `error` de la API cuando esté disponible.
7. Devuelve el objeto `data` si es un objeto JSON; si el formato no coincide, produce un error explícito.

Las pantallas muestran estos errores en un `SnackBar` o en el estado de error del panel. No se simulan resultados exitosos.

#### Métodos públicos de autenticación

| Método | Endpoint | Qué hace |
|---|---|---|
| `login(userCode, password)` | `POST /auth/login` | Envía `cod_user` y `contraseña`; valida la respuesta, guarda `token` de forma segura y convierte `usuario` en `AppUser`. |
| `requestRegistrationCode(email)` | `POST /auth/registro/codigo` | Solicita al backend el envío del código al correo institucional. |
| `verifyCode(email, code, purpose)` | `POST /auth/verificar-codigo` | Envía correo, código y propósito; devuelve `token_seguridad` después de validar que la API lo haya proporcionado. |
| `register(userCode, name, password, email, securityToken)` | `POST /auth/registro` | Envía identidad, contraseña, correo y token de seguridad; después intenta iniciar sesión automáticamente. |
| `requestPasswordRecoveryCode(email)` | `POST /auth/recuperar-contrasena` | Solicita un código de recuperación. La API responde sin revelar si existe una cuenta para ese correo. |
| `changePassword(userCode, password, securityToken)` | `POST /auth/modificar-contrasena` | Envía el código de usuario, la nueva contraseña y el token de seguridad verificado. |
| `logout()` | Sin endpoint | Borra el JWT local. |
| `restoreSession()` | `GET /usuarios` | Si hay JWT, consulta un recurso protegido; borra la sesión si el backend responde 401/403. |

#### Métodos públicos de datos

| Método | Solicitudes | Resultado |
|---|---|---|
| `get(path)` | GET protegido | Devuelve `data` de un endpoint autenticado. |
| `loadDashboard()` | `GET /usuarios`, `GET /usuarios/me/metricas`, `GET /ranking`, `GET /usuarios/me/historial?pagina=1&limite=10` | Realiza las cuatro consultas en paralelo y construye un `DashboardData`. |
| `loadHistoryPage(page)` | `GET /usuarios/me/historial?pagina=<page>&limite=10` | Obtiene otra página y la convierte en `HistoryPage`. |

El parseo del historial valida que `registros` sea una lista, convierte sus elementos válidos en `Delivery` y obtiene el total de `paginacion.total`. Las respuestas inesperadas generan errores en vez de ocultar una incompatibilidad con la API.

## 5. Flujos de pantalla y llamadas al backend

### 5.1 Inicio de sesión

1. `LoginScreen` recibe el código de usuario y la contraseña.
2. Los campos limitan el código a dígitos y ocho caracteres; el formulario envía los datos a `ApiService.login()`.
3. `login()` llama a `POST /auth/login`.
4. Si la respuesta contiene un JWT y un objeto de usuario válidos, guarda el JWT y devuelve un `AppUser`.
5. La pantalla navega a `/home`. Si ocurre un error, informa al usuario con un `SnackBar`.

Desde el login se puede navegar a registro o recuperación. La UI no gestiona ni conoce contraseñas almacenadas; la autenticación se realiza en el backend.

### 5.2 Registro con correo institucional

**Paso 1 — datos y solicitud del código (`RegisterEmailScreen`)**

- Solicita nombre, código de usuario de ocho dígitos y correo institucional.
- Comprueba localmente que el nombre no esté vacío, el código tenga ocho dígitos y el correo tenga un formato básico válido.
- Llama a `requestRegistrationCode(email)`, que envía:

  ```json
  {
    "correo_institucional": "persona@universidad.edu"
  }
  ```

- Solo cuando la API confirma la solicitud, navega a la pantalla de verificación con los datos ingresados.

La validación del cliente solo comprueba el formato del correo: no implementa una lista de dominios permitidos. La validez real, la unicidad y la posibilidad de enviar el correo corresponden al backend.

**Paso 2 — verificación (`RegisterVerifyScreen`)**

- Muestra nombre, código y correo para confirmar los datos de registro.
- Acepta un código numérico de ocho dígitos.
- `verifyCode()` envía a `POST /auth/verificar-codigo` el correo, el código y `proposito: "registro"`.
- Si la API responde con `token_seguridad`, navega a la pantalla de contraseña transportando ese token.
- El botón de reenvío vuelve a llamar a `POST /auth/registro/codigo`. El backend aplica el límite de reenvío.

De acuerdo con la guía de la API, el código vence a los 3 minutos, permite hasta 5 intentos y el reenvío se limita a una vez por minuto. Esas reglas las aplica el backend, no el temporizador de la interfaz.

**Paso 3 — contraseña y alta (`RegisterPasswordScreen`)**

- Pide contraseña y confirmación.
- Valida al menos 8 caracteres, letras y números, igualdad de ambas contraseñas y máximo de 72 bytes UTF-8.
- Comprueba que los argumentos de navegación incluyan código, nombre, correo y token de seguridad.
- Llama a `register(...)`, que envía a `POST /auth/registro`:

  ```json
  {
    "cod_user": "00001004",
    "nombre": "Ana Pérez",
    "tipo": "usuario",
    "contraseña": "contraseña-elegida",
    "correo_institucional": "persona@universidad.edu",
    "token_seguridad": "token-devuelto-por-verificar-codigo"
  }
  ```

- El servidor consume el token, crea la cuenta e inicializa los datos administrados por backend.
- La app llama después a `POST /auth/login` para crear una sesión automáticamente y navega a `/home`.
- Si el alta se completó pero el login automático falla, el servicio explica que la cuenta ya se creó y recomienda entrar desde el login.

### 5.3 Recuperación de contraseña

`RecoverPasswordScreen` administra internamente cuatro estados:

1. **Solicitar código:** valida el formato del correo y llama a `POST /auth/recuperar-contrasena`.
2. **Verificar código:** solicita el código de ocho dígitos y llama a `POST /auth/verificar-codigo` con `proposito: "recuperacion"`.
3. **Cambiar contraseña:** pide el código de usuario y la contraseña nueva. Envía `cod_user`, `nueva_contraseña` y `token_seguridad` a `POST /auth/modificar-contrasena`.
4. **Confirmación:** muestra que el cambio se completó y permite regresar al login.

La contraseña nueva debe satisfacer las mismas reglas de longitud, letras/números y máximo de 72 bytes. El backend valida que el código de usuario pertenezca a la cuenta vinculada al correo verificado y consume/invalida el token. Por privacidad, la solicitud de recuperación no confirma si el correo está registrado.

### 5.4 Panel autenticado

Al entrar a `/home`, `HomeShell` solicita el panel mediante `loadDashboard()`. El servicio consulta en paralelo:

- **`GET /usuarios`**: perfil del usuario autenticado.
- **`GET /usuarios/me/metricas`**: cantidad y peso total de residuos, más desgloses devueltos por la API.
- **`GET /ranking`**: posición del usuario y datos de ranking.
- **`GET /usuarios/me/historial?pagina=1&limite=10`**: entregas iniciales.

Los resultados se convierten en `AppUser`, `UserMetrics`, `Delivery` y `DashboardData`. `HomeShell` comparte el mismo `DashboardData` con las pestañas, evitando que cada una vuelva a consultar por separado los datos iniciales.

#### Pestaña Puntos (`PointsScreen`)

Presenta los puntos acumulados, el peso recuperado, el número de entregas y la entrega más reciente, si existe. Los puntos del usuario y las métricas provienen de los datos del panel. La pantalla no modifica puntos ni registra reciclajes.

#### Pestaña Historial (`HistoryScreen`)

Comienza con los registros recibidos en el panel. Cuando el usuario pide más, `_loadMore()` llama a `loadHistoryPage(_page + 1)`, añade los registros recibidos y actualiza el número de página. Los errores de una página se muestran en la propia pantalla y se puede reintentar.

#### Pestaña Mi perfil (`ProfileScreen`)

Muestra nombre, código, tipo y estado de cuenta, cantidad de entregas e impacto. Presenta el correo institucional si la respuesta del backend lo incluye. El botón de cerrar sesión solicita confirmación y después ejecuta el callback de cierre de sesión provisto por `HomeShell`.

## 6. Modelos y transformación de respuestas

### `AppUser` (`lib/models/app_user.dart`)

Representa el usuario autenticado o devuelto por la API:

- id, código, nombre, puntos, tipo y estado;
- correo institucional opcional, para preservar compatibilidad con cuentas/respuestas anteriores que no lo incluyan;
- `fromJson()` comprueba los tipos de los campos esenciales y arroja `FormatException` si la respuesta es inválida;
- `initials` genera las iniciales que se usan en la interfaz.

### `UserMetrics`, `DashboardData` e `HistoryPage` (`lib/models/dashboard_data.dart`)

- `UserMetrics.fromJson()` convierte `totalResiduos` y `pesoTotalKg` y valida que sean numéricos.
- `DashboardData` agrupa usuario, métricas, posición del ranking, registros iniciales y total del historial.
- `HistoryPage` empaqueta entregas y total para cargar páginas adicionales.

### `Delivery` (`lib/models/delivery.dart`)

`Delivery.fromJson()` espera `residuo.tipo`, `residuo.peso`, `fecha` e `idTacho`. Normaliza el material para mostrar nombres legibles, selecciona un icono según el tipo de material y presenta la fecha localmente. La propiedad calculada `points` multiplica los kilogramos por 10, que es la tarifa descrita por la guía del backend. El cliente usa este cálculo para presentar puntos estimados en el historial; los puntos oficiales son los registrados por el servidor.

## 7. Widgets y tema

Los widgets en `lib/widgets/` son elementos de interfaz reutilizados por pantallas:

- `app_button.dart`: botón principal de acción, con estado habilitado/deshabilitado.
- `app_text_field.dart`: campo de texto, contraseña oculta/revelada, teclado y formatters configurables.
- `brand_header.dart`: encabezado de marca.
- `icon_badge.dart`: icono decorativo de sección.
- `info_box.dart`: caja informativa y variante de advertencia.
- `link_text.dart`: texto con acción de navegación.
- `main_bottom_nav.dart`: navegación inferior entre Puntos, Historial y Mi perfil.
- `register_top_bar.dart`: indicador/encabezado de pasos del registro.

`app_colors.dart` centraliza colores de marca y `app_theme.dart` define el tema Material aplicado desde `main.dart`.

## 8. Pruebas y validación

- `test/models_test.dart` cubre el parseo de usuario (incluido el correo institucional), el parseo del historial y el parseo de métricas.
- `test/widget_test.dart` verifica que el login sea la pantalla de entrada sin sesión.

Comandos de validación:

```bash
flutter analyze
flutter test
```

Al ejecutar `flutter analyze` en todo el proyecto pueden aparecer avisos informativos ya existentes en widgets no relacionados con los flujos de autenticación. Para desarrollar, resuelve errores y avisos que pertenezcan a los archivos que estés modificando.

## 9. Configurar la conexión con el backend

1. Inicia el backend Tachín Verde en un host y puerto accesibles desde el dispositivo.
2. Define `API_BASE_URL` según el destino. Un emulador Android utiliza la dirección del host `10.0.2.2`; un teléfono físico debe usar la IP de red del equipo servidor, o un dominio HTTPS accesible.
3. Inicia la aplicación con, por ejemplo:

   ```bash
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
   ```

4. Para el envío de códigos, configura SMTP exclusivamente en el backend. La aplicación Flutter solo solicita al servidor que envíe el correo.

Para HTTP local, las restricciones de red dependen de la plataforma y del tipo de compilación. Para producción se debe usar HTTPS. No guardes secretos de servidor, claves SMTP ni credenciales de correo en `lib/`, `pubspec.yaml` ni en `--dart-define` del cliente.

## 10. Límites funcionales actuales

- No hay una pantalla para registrar un reciclaje con selección de tacho, material y peso, aunque la API documenta `POST /residuos`.
- No se conectaron las pantallas/endpoints administrativos de tachos, premios, logros y notificaciones.
- La UI no impone un dominio institucional concreto; únicamente valida un formato general de dirección de correo. El backend debe aplicar cualquier política de dominio/unicidad y verificar el código.
- El cliente no configura SMTP, no genera códigos y no decide si un correo está registrado; esas operaciones y reglas pertenecen al backend.

# ULima Recicla

Aplicación Flutter para la comunidad de la Universidad de Lima. Permite iniciar sesión y consultar puntos, entregas e información del perfil usando la API Tachín Verde.

## Estructura del proyecto

```text
FrontEndMovil/
├── android/                  # Configuración y código nativo para Android
├── ios/                      # Configuración y código nativo para iOS
├── linux/                    # Configuración para Linux
├── macos/                    # Configuración para macOS
├── web/                      # Archivos de inicio para Flutter Web
├── windows/                  # Configuración para Windows
├── lib/
│   ├── main.dart             # Punto de entrada, tema y rutas
│   ├── models/
│   │   ├── app_user.dart     # Usuario autenticado
│   │   ├── dashboard_data.dart # Métricas, ranking e información del panel
│   │   └── delivery.dart     # Registro del historial
│   ├── screens/
│   │   ├── home_shell.dart
│   │   ├── history_screen.dart
│   │   ├── login_screen.dart
│   │   ├── points_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── recover_password_screen.dart
│   │   ├── register_email_screen.dart
│   │   ├── register_password_screen.dart
│   │   └── register_verify_screen.dart
│   ├── services/
│   │   └── api_service.dart  # Cliente HTTP, autenticación y lectura de API
│   ├── theme/                # Colores y tema global
│   └── widgets/              # Componentes visuales reutilizables
├── analysis_options.yaml     # Reglas de análisis de Dart
├── pubspec.yaml              # Metadatos, dependencias y configuración Flutter
└── README.md
```

- **`screens/`** contiene las pantallas completas.
- **`widgets/`** reúne botones, campos, encabezados y navegación compartidos.
- **`theme/`** centraliza colores y estilos globales.
- **`models/`** define los modelos de usuario, métricas e historial.
- **`services/`** gestiona las solicitudes HTTP, los errores de API y el token JWT.
- Las carpetas de plataforma contienen configuración específica de cada destino.

## Navegación y pantallas

`lib/main.dart` inicializa `MaterialApp`, aplica el tema y registra las rutas de login, registro, recuperación y `/home`. Si hay un JWT guardado, valida la sesión antes de abrir la aplicación. `HomeShell` carga usuario, métricas, ranking e historial, y comparte los datos con sus pestañas:

- **Puntos:** puntos del usuario, impacto, posición en el ranking y última entrega.
- **Historial:** registros obtenidos en páginas desde el backend.
- **Mi perfil:** datos del usuario autenticado y cierre de sesión.

El login llama a `POST /api/auth/login`. El registro solicita un código de 8 dígitos para el correo institucional (`POST /api/auth/registro/codigo`), lo valida con `POST /api/auth/verificar-codigo` y crea la cuenta con el token de un solo uso devuelto por el servidor. Al completar el registro, la app inicia sesión automáticamente. La recuperación solicita y verifica un código por correo antes de actualizar la contraseña. Las solicitudes protegidas envían el JWT como `Authorization: Bearer <token>` y el token se guarda con `flutter_secure_storage`.

## Configurar y ejecutar

Inicia el backend Tachín Verde en el puerto `3000` y configura sus variables de entorno y base de datos según su guía. La app acepta la URL de la API mediante `--dart-define=API_BASE_URL=...`. Si no se especifica, usa `http://10.0.2.2:3000/api` en Android y `http://localhost:3000/api` en otros destinos.

Para Android Emulator:

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

Para un dispositivo físico en la misma red, usa la IP LAN del equipo que ejecuta el backend:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.20:3000/api
```

Reemplaza `192.168.1.20` con la IP correcta. Android permite tráfico HTTP sin cifrar solo en compilaciones `debug`; usa HTTPS para otras configuraciones. El dispositivo también debe poder alcanzar la base de datos/API a través de la red.

Para iOS utiliza un endpoint HTTPS o configura de forma explícita las excepciones ATS de desarrollo para el host local. En Windows, si `flutter pub get` avisa que no puede crear enlaces simbólicos para plugins de escritorio, habilita Developer Mode; la compilación Android no requiere cambiar ese ajuste.

Para verificar el código:

```bash
flutter analyze
flutter test
```

## Estado de integración

- **Registro y verificación por correo:** integrados con el flujo de solicitud, confirmación del código y token de seguridad de un solo uso.
- **Recuperación de contraseña:** integrada con solicitud de código, verificación y cambio de contraseña asociado al código de usuario. El backend no revela si el correo está asociado a una cuenta.
- **Registrar un reciclaje desde la app:** no hay todavía una pantalla de selección de tacho, material y peso. El backend documenta `POST /api/residuos`, pero hace falta esa interfaz para integrarlo adecuadamente.

El backend debe tener SMTP configurado para poder enviar los códigos. Los códigos vencen en 3 minutos, permiten hasta 5 intentos y el reenvío está limitado a una vez por minuto. Los endpoints administrativos, premios, logros, notificaciones y tachos no están conectados a pantallas del cliente actual.

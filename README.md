# Proyecto Taller de Software - Aplicación Flutter

Este es un proyecto de aplicación móvil desarrollado en Flutter como parte del Taller de Software. Hasta el Hito 2, la aplicación permite a los usuarios registrarse, iniciar sesión y crear perfiles, ya sea como usuario estándar o como empresa, interactuando con una base de datos en tiempo real a través de Firebase.

## ✨ Características Principales

- **Autenticación de Usuarios**: Sistema completo de registro e inicio de sesión utilizando **Firebase Authentication**.
- **Dos Roles de Usuario**: Los usuarios pueden registrarse como "Usuario" o "Empresa", con flujos y perfiles diferenciados.
- **Perfil de Usuario Estándar**:
  - Creación y edición de perfil con nombre, foto, ubicación e intereses.
  - Carga de imagen de perfil desde la galería del dispositivo o mediante una URL.
  - Selección de intereses y ubicación desde listas predefinidas.
- **Perfil de Empresa**:
  - Creación y edición de perfil con nombre de la empresa, logo, industria, ubicación, descripción y sitio web.
  - Carga de logo desde la galería o mediante una URL.
  - Gestión de una lista dinámica de certificaciones.
- **Interfaz de Usuario Moderna**:
  - Diseño consistente y moderno en todas las pantallas.
  - Uso de un tema global para colores, fuentes y estilos de componentes.
  - Indicadores de carga para mejorar la retroalimentación al usuario.
- **Navegación Protegida**: Flujo de autenticación que dirige a los usuarios a la pantalla principal si han iniciado sesión, o a la pantalla de login en caso contrario.

## 🛠️ Tecnologías y Dependencias

- **Framework**: [Flutter](https://flutter.dev/)
- **Lenguaje**: [Dart](https://dart.dev/)
- **Backend y Base de Datos**: [Firebase](https://firebase.google.com/)
  - `firebase_core`: Para inicializar la conexión con Firebase.
  - `firebase_auth`: Para la gestión de autenticación (email y contraseña).
  - `cloud_firestore`: Para el almacenamiento de datos de perfiles en una base de datos NoSQL.
  - `firebase_storage`: Para el almacenamiento de archivos (fotos de perfil y logos).
- **Gestión de Imágenes**:
  - `image_picker`: Para seleccionar imágenes de la galería del dispositivo.
- **Estilo y Componentes**:
  - `cupertino_icons`: Para el uso de iconografía de estilo iOS.
- **Análisis de Código**:
  - `flutter_lints`: Para asegurar un código limpio y seguir las mejores prácticas.

## 📂 Estructura del Proyecto

El código fuente está organizado en la carpeta `lib/` de la siguiente manera para mantener una arquitectura limpia y escalable:

```
lib/
├── models/
│   ├── user_profile.dart         # Modelo de datos para el perfil de usuario.
│   └── company_profile.dart      # Modelo de datos para el perfil de empresa.
│
├── screens/
│   ├── login_screen.dart         # Pantalla de inicio de sesión.
│   ├── register_screen.dart      # Pantalla de registro.
│   ├── home_screen.dart          # Pantalla principal post-login.
│   ├── profile_screen.dart       # Pantalla para ver/editar el perfil de usuario.
│   └── company_profile_screen.dart # Pantalla para ver/editar el perfil de empresa.
│
├── widgets/
│   └── (vacío)                   # Directorio para widgets reutilizables (a futuro).
│
├── firebase_options.dart         # Configuración de Firebase generada automáticamente.
└── main.dart                     # Punto de entrada de la aplicación, gestiona el tema y la navegación inicial.
```

## 🚀 Guía de Instalación y Ejecución

Sigue estos pasos para configurar y ejecutar el proyecto en tu entorno de desarrollo local.

### Pre-requisitos

1.  **Tener Flutter instalado**: Si no lo tienes, sigue la [guía oficial de instalación de Flutter](https://flutter.dev/docs/get-started/install).
2.  **Crear un proyecto en Firebase**:
    - Ve a la [consola de Firebase](https://console.firebase.google.com/).
    - Crea un nuevo proyecto.
    - Activa los siguientes servicios:
      - **Authentication**: Habilita el proveedor "Correo electrónico/Contraseña".
      - **Firestore Database**: Crea una base de datos en modo de producción (puedes ajustar las reglas de seguridad más adelante).
      - **Storage**: Crea un bucket de almacenamiento.

### Configuración del Proyecto

1.  **Clona el repositorio**:

    ```bash
    git clone https://github.com/raimundoosf/ProyectoTallerSoftware.git
    cd ProyectoTallerSoftware/flutter_app
    ```

2.  **Configura Firebase en la aplicación**:

    - Dentro de tu proyecto de Firebase, añade una nueva aplicación de **Android**.
    - Sigue los pasos indicados en la consola de Firebase:
      - Registra el nombre del paquete: `com.example.flutter_app` (o el que corresponda a tu configuración).
      - Descarga el archivo `google-services.json`.
      - **Mueve el archivo `google-services.json` a la carpeta `android/app/` de tu proyecto Flutter.**
    - Repite el proceso para **iOS** si planeas compilar para esa plataforma (descargando `GoogleService-Info.plist` y colocándolo en `ios/Runner/`).

3.  **Instala las dependencias**:
    Ejecuta el siguiente comando en la raíz del proyecto (`flutter_app`):
    ```bash
    flutter pub get
    ```

### Ejecución de la Aplicación

1.  **Abre un emulador** o conecta un dispositivo físico.
2.  **Ejecuta la aplicación** con el siguiente comando:
    ```bash
    flutter run
    ```

¡Listo! La aplicación debería compilarse e iniciarse en tu dispositivo/emulador.

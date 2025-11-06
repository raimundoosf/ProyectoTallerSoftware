# Guía de Contribución

¡Gracias por tu interés en contribuir a este proyecto! Toda contribución es bienvenida. Para asegurar un proceso ordenado y colaborativo, por favor sigue las siguientes directrices.

## 💬 Cómo Contribuir

- **Reporte de Bugs**: Si encuentras un error, por favor, abre un "Issue" en GitHub describiendo el problema en detalle. Incluye pasos para reproducirlo, la versión de la app y capturas de pantalla si es posible.
- **Sugerencia de Mejoras**: Si tienes una idea para una nueva funcionalidad o una mejora, abre un "Issue" para discutirla.
- **Pull Requests**: Si quieres contribuir con código, por favor, sigue el flujo de trabajo que se describe a continuación.

## 🚀 Flujo de Trabajo con Git y Pull Requests

Para mantener el repositorio organizado, seguimos un flujo de trabajo basado en ramas (`branching workflow`).

### 1. Fork y Clonar el Repositorio

- **Fork**: Haz un "Fork" de este repositorio a tu propia cuenta de GitHub.
- **Clonar**: Clona tu fork a tu máquina local.
  ```bash
  git clone https://github.com/TU_USUARIO/ProyectoTallerSoftware.git
  cd ProyectoTallerSoftware/flutter_app
  ```

### 2. Crear una Nueva Rama

Nunca trabajes directamente sobre la rama `main`. Crea siempre una nueva rama para cada funcionalidad o corrección en la que trabajes. Usa un nombre descriptivo y un prefijo según el tipo de tarea:

- `feature/`: Para nuevas funcionalidades (ej: `feature/agregar-chat`).
- `fix/`: Para correcciones de bugs (ej: `fix/error-login`).
- `docs/`: Para mejoras en la documentación (ej: `docs/actualizar-readme`).

```bash
# Asegúrate de estar en la rama principal y tener la última versión
git checkout main
git pull origin main

# Crea tu nueva rama
git checkout -b feature/nombre-de-la-funcionalidad
```

### 3. Realizar los Cambios y Commits

- Escribe tu código siguiendo las guías de estilo de Flutter y Dart.
- Realiza commits pequeños y atómicos con mensajes claros y descriptivos. Un buen mensaje de commit explica **qué** cambiaste y **por qué**.

```bash
# Añade los archivos que modificaste
git add .

# Haz commit de tus cambios
git commit -m "feat: Agrega la funcionalidad X al perfil de usuario"
# o
git commit -m "fix: Corrige el desbordamiento de píxeles en la pantalla de login"
```

### 4. Mantener la Rama Actualizada

Mientras trabajas, la rama `main` del repositorio original puede recibir actualizaciones. Es una buena práctica mantener tu rama sincronizada para evitar conflictos.

```bash
# Añade el repositorio original como un "remote" (solo necesitas hacerlo una vez)
git remote add upstream https://github.com/raimundoosf/ProyectoTallerSoftware.git

# Para sincronizar, actualiza tu rama main local y luego fusiona los cambios en tu rama de trabajo
git checkout main
git pull upstream main
git checkout feature/nombre-de-la-funcionalidad
git merge main
```

### 5. Enviar los Cambios (Push) y Crear un Pull Request

- Cuando hayas terminado tu trabajo, sube tu rama a tu fork en GitHub:
  ```bash
  git push origin feature/nombre-de-la-funcionalidad
  ```
- Ve a la página de tu fork en GitHub. Verás un botón para **"Compare & pull request"**.
- Haz clic en él, asegúrate de que la rama base sea `main` del repositorio original.
- Escribe un título claro y una descripción detallada de los cambios que realizaste.
- Crea el Pull Request.

### 6. Revisión de Código

- Una vez creado el Pull Request, será revisado. Pueden solicitarse cambios o mejoras.
- Participa en la discusión y realiza los ajustes necesarios.
- Una vez aprobado, tu código será fusionado a la rama `main`.

## 📝 Estándares de Código

- **Formato**: Asegúrate de que tu código esté formateado con `flutter format .`.
- **Lints**: El proyecto usa `flutter_lints`. Intenta resolver cualquier advertencia que el analizador de código te muestre.
- **Nomenclatura**: Sigue las convenciones de Dart (ej: `lowerCamelCase` para variables y funciones, `UpperCamelCase` para clases).

¡Gracias por ayudar a mejorar este proyecto!

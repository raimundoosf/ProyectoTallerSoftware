# Sistema de Onboarding - Primera Experiencia de Usuario

## 📱 Descripción

Se ha implementado un sistema completo de onboarding para mejorar la experiencia del primer uso de la aplicación. Los usuarios nuevos ahora verán una introducción guiada antes de acceder a la aplicación.

## ✨ Características Implementadas

### 1. **Splash Screen**

- Pantalla inicial con logo y loading
- Verifica si es el primer uso de la app
- Redirige al onboarding o al login según corresponda
- Duración: 1.5 segundos

### 2. **Onboarding Screen**

Presentación de 3 pantallas deslizables con las funcionalidades principales:

#### **Pantalla 1: Descubre Empresas Locales**

- 🏪 Icono: Storefront
- Color: Azul
- Descripción: "Explora un catálogo completo de empresas y negocios locales. Encuentra productos, servicios y profesionales cerca de ti."

#### **Pantalla 2: Publica tus Productos**

- 💼 Icono: Business Center
- Color: Púrpura
- Descripción: "¿Tienes un negocio? Crea tu perfil empresarial y publica tus productos o servicios para que más clientes te encuentren."

#### **Pantalla 3: Contacta Directamente**

- ✉️ Icono: Email
- Color: Verde
- Descripción: "Comunícate fácilmente con las empresas mediante correo electrónico. Consulta sobre productos, precios y disponibilidad."

### 3. **Navegación Intuitiva**

- Botón "Omitir" en la esquina superior derecha
- Indicadores de página (dots) en la parte inferior
- Botón "Atrás" (aparece desde la segunda pantalla)
- Botón "Siguiente" que cambia a "Comenzar" en la última pantalla
- Deslizamiento horizontal entre pantallas
- Animaciones suaves (300ms)

### 4. **Persistencia**

- Usa `SharedPreferences` para recordar que el usuario ya vio el onboarding
- Solo se muestra una vez (en el primer uso)
- Se puede resetear eliminando los datos de la app

## 🛠️ Archivos Creados

```
lib/src/features/
├── onboarding/
│   └── presentation/
│       └── views/
│           └── onboarding_screen.dart
└── splash/
    └── presentation/
        └── views/
            └── splash_screen.dart
```

## 🔄 Flujo de Navegación

```
App Launch
    ↓
Splash Screen (1.5s)
    ↓
¿Primera vez?
    ↓           ↓
   Sí          No
    ↓           ↓
Onboarding → Login/Home
    ↓
  Login
    ↓
  Home
```

## 🎨 Diseño y UX

- **Colores**: Uso de colores primarios de la app con variaciones para cada pantalla
- **Iconos**: Material Design icons grandes y llamativos
- **Tipografía**: Títulos grandes y descripciones legibles
- **Espaciado**: Generoso padding para mejor legibilidad
- **Animaciones**: Transiciones suaves entre pantallas
- **Responsive**: Se adapta a diferentes tamaños de pantalla

## 📦 Dependencias Agregadas

```yaml
dependencies:
  shared_preferences: ^2.3.3 # Persistencia local
```

## 🚀 Uso

El onboarding se ejecuta automáticamente en el primer uso. No requiere configuración adicional.

### Para Resetear el Onboarding (Testing)

```dart
// En tu código de pruebas o debug
final prefs = await SharedPreferences.getInstance();
await prefs.remove('onboarding_completed');
// Reiniciar la app
```

## 🔧 Personalización

Para modificar el contenido del onboarding, edita la lista `_pages` en `onboarding_screen.dart`:

```dart
final List<OnboardingPage> _pages = [
  OnboardingPage(
    icon: Icons.tu_icono,
    title: 'Tu Título',
    description: 'Tu descripción',
    color: Colors.tuColor,
  ),
  // Agrega más páginas...
];
```

## ✅ Checklist de Implementación

- ✅ Splash screen con verificación de primera vez
- ✅ 3 pantallas de onboarding con contenido relevante
- ✅ Navegación fluida con gestos y botones
- ✅ Indicadores visuales de progreso
- ✅ Botón para omitir el onboarding
- ✅ Persistencia con SharedPreferences
- ✅ Integración con el router de GoRouter
- ✅ Animaciones y transiciones suaves
- ✅ Diseño responsive y atractivo

## 🎯 Impacto en UX

Esta implementación mejora significativamente la experiencia del usuario al:

1. **Orientar**: Explicar las funcionalidades principales desde el inicio
2. **Reducir confusión**: Los usuarios saben qué esperar de la app
3. **Aumentar engagement**: Presenta valor desde el primer contacto
4. **Profesionalizar**: Da una impresión de app completa y pulida

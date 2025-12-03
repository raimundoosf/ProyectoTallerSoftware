# Búsqueda y Filtrado de Empresas

## Descripción

Se ha implementado un sistema completo de búsqueda y filtrado de empresas que permite a los usuarios encontrar empresas según múltiples criterios.

## Características Implementadas

### 1. Búsqueda por Texto

- Busca en nombre de empresa, industria, descripción y especialidades
- Búsqueda en tiempo real mientras se escribe
- Insensible a mayúsculas/minúsculas

### 2. Filtros Disponibles

#### Filtros Principales

- **Industria**: Filtra por sector industrial
- **Nivel de Cobertura**: Nacional, Regional o Comunal
- **Regiones**: Selección múltiple de regiones (cuando aplica)
- **Certificaciones**: Filtra por certificaciones específicas

#### Filtros Avanzados

- **Número de Empleados**: Rango mínimo y máximo
- **Año de Fundación**: Rango de años de fundación

### 3. Interfaz de Usuario

#### Barra de Búsqueda

- Campo de texto con ícono de búsqueda
- Botón de limpieza rápida
- Botón de filtros con contador de filtros activos

#### Chips de Filtros Activos

- Visualización de todos los filtros aplicados
- Posibilidad de remover filtros individualmente
- Indicador visual del número de filtros activos

#### Lista de Resultados

- Tarjetas de empresa con información relevante
- Logo, nombre, industria y descripción
- Indicadores de cobertura y certificaciones
- Contador de resultados encontrados

## Arquitectura

### Estructura de Archivos

```
lib/src/features/company_profile/
├── domain/
│   ├── entities/
│   │   └── company_filter.dart          # Modelo de filtros
│   └── repositories/
│       └── company_profile_repository.dart  # Interfaz actualizada
├── data/
│   └── repositories/
│       └── company_profile_repository_impl.dart  # Implementación
├── presentation/
│   ├── viewmodels/
│   │   └── companies_list_viewmodel.dart  # Lógica de negocio
│   ├── views/
│   │   └── companies_list_view.dart       # Vista principal
│   └── widgets/
│       ├── company_search_bar.dart        # Barra de búsqueda
│       ├── company_filter_sheet.dart      # Panel de filtros
│       └── company_card.dart              # Tarjeta de empresa
```

### Componentes Clave

#### CompanyFilter

Modelo inmutable que encapsula todos los filtros:

- `searchQuery`: Texto de búsqueda
- `industry`: Industria seleccionada
- `coverageLevel`: Nivel de cobertura
- `coverageRegions`: Lista de regiones
- `certifications`: Lista de certificaciones
- `minEmployees`, `maxEmployees`: Rango de empleados
- `minFoundedYear`, `maxFoundedYear`: Rango de años

#### CompaniesListViewModel

Gestiona el estado y la lógica de filtrado:

- Carga todas las empresas desde Firestore
- Aplica filtros localmente para rendimiento óptimo
- Mantiene lista original y lista filtrada separadas
- Proporciona métodos para actualizar búsqueda y filtros

#### CompanySearchBar

Widget de búsqueda con:

- Campo de texto responsivo
- Botón de filtros con badge de contador
- Integración con el sistema de filtros

#### CompanyFilterSheet

Bottom sheet con todos los filtros:

- Chips seleccionables para opciones categóricas
- Campos de texto para rangos numéricos
- Botón para limpiar todos los filtros
- Botón para aplicar filtros

## Uso

### Navegación

Para navegar a la vista de empresas desde cualquier parte de la app:

```dart
context.go('/companies');
```

### Desde el HomeScreen

Puedes agregar un botón o tile en el menú principal:

```dart
ListTile(
  leading: const Icon(Icons.business),
  title: const Text('Buscar Empresas'),
  onTap: () => context.go('/companies'),
),
```

### Consumo del ViewModel

El ViewModel está registrado globalmente en el DI, por lo que se puede consumir con Provider:

```dart
Consumer<CompaniesListViewModel>(
  builder: (context, viewModel, child) {
    return ListView.builder(
      itemCount: viewModel.companies.length,
      itemBuilder: (context, index) {
        final company = viewModel.companies[index];
        return CompanyCard(company: company);
      },
    );
  },
)
```

## Configuración de Firebase

### Índices de Firestore

Los índices necesarios están definidos en `firestore.indexes.json`:

```json
{
  "collectionGroup": "businesses",
  "queryScope": "COLLECTION",
  "fields": [
    {
      "fieldPath": "companyName",
      "order": "ASCENDING"
    }
  ]
}
```

Para desplegar los índices:

```bash
firebase deploy --only firestore:indexes
```

### Colección de Datos

La funcionalidad lee de la colección `businesses` en Firestore. Asegúrate de que:

1. La colección existe
2. Los documentos tienen la estructura correcta de `CompanyProfile`
3. Los permisos de lectura están configurados correctamente

## Extensiones Futuras

### Posibles Mejoras

1. **Ordenamiento**: Agregar opciones de ordenamiento (nombre, fecha, empleados)
2. **Paginación**: Implementar lazy loading para grandes cantidades de empresas
3. **Favoritos**: Permitir marcar empresas como favoritas
4. **Compartir**: Opción para compartir perfiles de empresa
5. **Mapa**: Vista de mapa con ubicaciones de empresas
6. **Búsqueda por ubicación**: Filtrar por proximidad geográfica
7. **Historial de búsqueda**: Guardar búsquedas recientes
8. **Filtros guardados**: Guardar combinaciones de filtros frecuentes

### Optimizaciones de Rendimiento

1. **Caché**: Implementar caché local con Hive o SharedPreferences
2. **Índices compuestos**: Agregar más índices en Firestore para queries complejas
3. **Búsqueda en servidor**: Mover filtrado complejo a Cloud Functions
4. **Algolia/ElasticSearch**: Para búsqueda full-text más avanzada

## Testing

### Para ejecutar tests (cuando se implementen):

```bash
flutter test test/features/company_profile/
```

### Tests sugeridos:

- Unit tests para `CompanyFilter` (copyWith, hasActiveFilters, etc.)
- Unit tests para `CompaniesListViewModel` (filtrado, búsqueda)
- Widget tests para `CompanySearchBar` y `CompanyFilterSheet`
- Integration tests para el flujo completo de búsqueda

## Dependencias

Las siguientes dependencias son utilizadas:

- `provider`: Gestión de estado
- `go_router`: Navegación
- `cloud_firestore`: Base de datos
- `firebase_storage`: Almacenamiento de logos

No se requieren dependencias adicionales.

## Navegación a Perfiles Públicos

### Vista de Perfil Público

Se creó `CompanyPublicProfileView` para mostrar el perfil completo de cualquier empresa de forma pública (solo lectura):

**Características**:

- Vista de solo lectura (no permite edición)
- Muestra toda la información del perfil de la empresa
- Incluye dos pestañas:
  - **Perfil**: Información completa de la empresa
  - **Publicaciones**: Productos publicados por la empresa
- Accesible desde la lista de búsqueda

**Ruta**: `/company/:companyId`

**Navegación**:
Al hacer clic en una tarjeta de empresa en la lista de búsqueda, se navega automáticamente al perfil público usando el ID de la empresa.

### CompanyWithId Entity

Para soportar la navegación, se creó la entidad `CompanyWithId`:

- Envuelve un `CompanyProfile` junto con su ID de Firestore
- Permite asociar cada empresa en la lista con su documento en Firestore
- Facilita la navegación al perfil específico

## Troubleshooting

### La lista está vacía

1. Verifica que existan documentos en la colección `businesses`
2. Revisa los permisos de Firestore
3. Comprueba que los documentos tengan el campo `companyName`

### Los filtros no funcionan

1. Verifica que los campos existan en los documentos
2. Revisa la consola de Flutter para errores
3. Asegúrate de que los valores de filtro coincidan con los datos

### Error de índices

Si ves un error de Firestore sobre índices faltantes:

1. Copia la URL del error (contiene la configuración del índice)
2. O ejecuta: `firebase deploy --only firestore:indexes`

## Contacto y Soporte

Para preguntas o problemas relacionados con esta funcionalidad, por favor:

1. Revisa este documento
2. Consulta los comentarios en el código
3. Revisa los logs de Flutter con `flutter logs`

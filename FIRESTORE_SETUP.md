# Configuración de Firestore

## Desplegar índices

Para desplegar los índices de Firestore necesarios para las consultas de productos:

```bash
firebase deploy --only firestore:indexes
```

## Índices configurados

1. **products - createdAt (DESC)**: Para obtener todos los productos ordenados por fecha de creación
2. **products - companyId + createdAt (DESC)**: Para obtener productos de una empresa específica ordenados por fecha

## Notas

Si encuentras un error de "índice no encontrado" al ejecutar la aplicación, Firebase te proporcionará un enlace directo en la consola para crear el índice automáticamente.

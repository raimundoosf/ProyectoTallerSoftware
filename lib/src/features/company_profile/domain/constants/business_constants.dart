/// Constantes relacionadas con el perfil de empresas
class BusinessConstants {
  // Industrias alineadas con modelo B2B de sostenibilidad corporativa
  // Categorías relevantes para compradores corporativos buscando proveedores sustentables
  static const List<String> industries = [
    'Manufactura e Industria',
    'Construcción y Arquitectura',
    'Logística y Transporte',
    'Energía y Medio Ambiente',
    'Tecnología y Software',
    'Consultoría Empresarial',
    'Agricultura y Ganadería',
    'Alimentación y Bebidas',
    'Textil y Confección',
    'Química y Farmacéutica',
    'Minería y Metalurgia',
    'Papel y Celulosa',
    'Plásticos y Empaques',
    'Servicios Profesionales',
    'Comercio y Distribución',
    'Gestión de Residuos',
    'Otros',
  ];

  // Niveles de cobertura
  static const String coverageNational = 'Nacional';
  static const String coverageRegional = 'Regional';
  static const String coverageCommunal = 'Comunal';

  static const List<String> coverageLevels = [
    coverageNational,
    coverageRegional,
    coverageCommunal,
  ];

  // Regiones de Chile
  static const List<String> regions = [
    'Arica y Parinacota',
    'Tarapacá',
    'Antofagasta',
    'Atacama',
    'Coquimbo',
    'Valparaíso',
    'Metropolitana de Santiago',
    'O\'Higgins',
    'Maule',
    'Ñuble',
    'Biobío',
    'La Araucanía',
    'Los Ríos',
    'Los Lagos',
    'Aysén',
    'Magallanes y de la Antártica Chilena',
  ];

  // Comunas de la Región Metropolitana (ejemplo para demostración)
  static const Map<String, List<String>> communesByRegion = {
    'Metropolitana de Santiago': [
      'Santiago',
      'Cerrillos',
      'Cerro Navia',
      'Conchalí',
      'El Bosque',
      'Estación Central',
      'Huechuraba',
      'Independencia',
      'La Cisterna',
      'La Florida',
      'La Granja',
      'La Pintana',
      'La Reina',
      'Las Condes',
      'Lo Barnechea',
      'Lo Espejo',
      'Lo Prado',
      'Macul',
      'Maipú',
      'Ñuñoa',
      'Pedro Aguirre Cerda',
      'Peñalolén',
      'Providencia',
      'Pudahuel',
      'Quilicura',
      'Quinta Normal',
      'Recoleta',
      'Renca',
      'San Joaquín',
      'San Miguel',
      'San Ramón',
      'Vitacura',
      'Puente Alto',
      'Pirque',
      'San José de Maipo',
      'Colina',
      'Lampa',
      'Tiltil',
      'San Bernardo',
      'Buin',
      'Calera de Tango',
      'Paine',
      'Melipilla',
      'Alhué',
      'Curacaví',
      'María Pinto',
      'San Pedro',
      'Talagante',
      'El Monte',
      'Isla de Maipo',
      'Padre Hurtado',
      'Peñaflor',
    ],
    // Agrega más regiones según sea necesario
    'Valparaíso': [
      'Valparaíso',
      'Viña del Mar',
      'Concón',
      'Quilpué',
      'Villa Alemana',
      'Casablanca',
      'Quintero',
      'Puchuncaví',
    ],
    'Biobío': [
      'Concepción',
      'Talcahuano',
      'Chiguayante',
      'San Pedro de la Paz',
      'Hualpén',
      'Penco',
      'Tomé',
      'Los Ángeles',
      'Coronel',
    ],
  };

  /// Obtiene las comunas de una región específica
  static List<String> getCommunesForRegion(String region) {
    return communesByRegion[region] ?? [];
  }

  /// Verifica si una región tiene comunas definidas
  static bool hasCommunes(String region) {
    return communesByRegion.containsKey(region) &&
        communesByRegion[region]!.isNotEmpty;
  }
}

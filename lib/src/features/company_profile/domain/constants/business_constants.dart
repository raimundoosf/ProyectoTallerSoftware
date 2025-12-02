/// Constantes relacionadas con el perfil de empresas
class BusinessConstants {
  // Industrias con categorías más específicas
  static const List<String> industries = [
    'Tecnología y Software',
    'Desarrollo Web y Móvil',
    'Diseño y Creatividad',
    'Marketing Digital',
    'Consultoría Empresarial',
    'Servicios Profesionales',
    'Construcción y Arquitectura',
    'Salud y Bienestar',
    'Educación y Capacitación',
    'Turismo y Hotelería',
    'Gastronomía y Alimentación',
    'Comercio y Retail',
    'Logística y Transporte',
    'Agricultura y Ganadería',
    'Energía y Medio Ambiente',
    'Finanzas y Seguros',
    'Inmobiliaria',
    'Manufactura e Industria',
    'Eventos y Entertainment',
    'Servicios del Hogar',
    'Belleza y Cuidado Personal',
    'Deportes y Fitness',
    'Otra',
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

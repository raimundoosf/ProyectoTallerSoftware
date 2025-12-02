class Product {
  final String id;
  final String companyId;
  final String name;
  final String description;
  final double price;
  final bool priceOnRequest; // "A convenir"
  final String brandLink; // link to company profile (non editable)
  final List<String> imageUrls;
  final List<String> certifications;
  final List<Map<String, dynamic>> repairLocations;
  final bool isService;

  // Campos para PRODUCTOS
  final String productCategory;
  final String condition; // Nuevo, Usado, Reacondicionado
  final int warrantyMonths; // Garantía en meses (0 = sin garantía)

  // Campos para SERVICIOS
  final String serviceCategory;
  final int serviceDurationMinutes; // Duración en minutos
  final String serviceModality; // Presencial, Online, A domicilio
  final List<String> serviceCoverage; // Regiones/comunas
  final String serviceSchedule; // Horarios disponibles

  // Campos comunes
  final List<String> tags;
  final String terms; // Condiciones y términos

  Product({
    required this.id,
    required this.companyId,
    required this.name,
    required this.description,
    required this.price,
    this.priceOnRequest = false,
    required this.brandLink,
    required this.imageUrls,
    this.certifications = const [],
    this.repairLocations = const [],
    this.isService = false,
    // Productos
    this.productCategory = '',
    this.condition = '',
    this.warrantyMonths = 0,
    // Servicios
    this.serviceCategory = '',
    this.serviceDurationMinutes = 0,
    this.serviceModality = '',
    this.serviceCoverage = const [],
    this.serviceSchedule = '',
    // Comunes
    this.tags = const [],
    this.terms = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'name': name,
      'description': description,
      'price': price,
      'priceOnRequest': priceOnRequest,
      'brandLink': brandLink,
      'imageUrls': imageUrls,
      'certifications': certifications,
      'repairLocations': repairLocations,
      'isService': isService,
      // Productos
      'productCategory': productCategory,
      'condition': condition,
      'warrantyMonths': warrantyMonths,
      // Servicios
      'serviceCategory': serviceCategory,
      'serviceDurationMinutes': serviceDurationMinutes,
      'serviceModality': serviceModality,
      'serviceCoverage': serviceCoverage,
      'serviceSchedule': serviceSchedule,
      // Comunes
      'tags': tags,
      'terms': terms,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      companyId: map['companyId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] is num) ? (map['price'] as num).toDouble() : 0.0,
      priceOnRequest: map['priceOnRequest'] ?? false,
      brandLink: map['brandLink'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      certifications: List<String>.from(map['certifications'] ?? []),
      repairLocations: List<Map<String, dynamic>>.from(
        map['repairLocations'] ?? [],
      ),
      isService: map['isService'] ?? false,
      // Productos
      productCategory: map['productCategory'] ?? '',
      condition: map['condition'] ?? '',
      warrantyMonths: map['warrantyMonths'] ?? 0,
      // Servicios
      serviceCategory: map['serviceCategory'] ?? '',
      serviceDurationMinutes: map['serviceDurationMinutes'] ?? 0,
      serviceModality: map['serviceModality'] ?? '',
      serviceCoverage: List<String>.from(map['serviceCoverage'] ?? []),
      serviceSchedule: map['serviceSchedule'] ?? '',
      // Comunes
      tags: List<String>.from(map['tags'] ?? []),
      terms: map['terms'] ?? '',
    );
  }
}

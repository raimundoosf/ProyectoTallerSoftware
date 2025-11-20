class Product {
  final String id;
  final String companyId;
  final String name;
  final String description;
  final double price;
  final String serviceCategory;
  final String serviceDuration;
  final String brandLink; // link to company profile (non editable)
  final List<String> imageUrls;
  final List<String> certifications;
  final List<Map<String, dynamic>> metrics;
  final List<Map<String, dynamic>> traceability; // points with media links
  final List<Map<String, dynamic>> repairLocations;
  final bool isService;

  Product({
    required this.id,
    required this.companyId,
    required this.name,
    required this.description,
    required this.price,
    this.serviceCategory = '',
    this.serviceDuration = '',
    required this.brandLink,
    required this.imageUrls,
    this.certifications = const [],
    this.metrics = const [],
    this.traceability = const [],
    this.repairLocations = const [],
    this.isService = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'name': name,
      'description': description,
      'price': price,
      'serviceCategory': serviceCategory,
      'serviceDuration': serviceDuration,
      'brandLink': brandLink,
      'imageUrls': imageUrls,
      'certifications': certifications,
      'metrics': metrics,
      'traceability': traceability,
      'repairLocations': repairLocations,
      'isService': isService,
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
      serviceCategory: map['serviceCategory'] ?? '',
      serviceDuration: map['serviceDuration'] ?? '',
      brandLink: map['brandLink'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      certifications: List<String>.from(map['certifications'] ?? []),
      metrics: List<Map<String, dynamic>>.from(map['metrics'] ?? []),
      traceability: List<Map<String, dynamic>>.from(map['traceability'] ?? []),
      repairLocations: List<Map<String, dynamic>>.from(
        map['repairLocations'] ?? [],
      ),
      isService: map['isService'] ?? false,
    );
  }
}

class AppUser {
  AppUser({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.role,
    required this.isVerified,
  });

  final int id;
  final String phone;
  final String fullName;
  final String role;
  final bool isVerified;

  bool get isMechanic => role == 'mechanic' || role == 'dealer';

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      phone: json['phone'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }
}

class Mechanic {
  Mechanic({
    required this.id,
    required this.garageName,
    required this.specialty,
    required this.services,
    required this.address,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.priceMin,
    required this.priceMax,
    required this.ratingAvg,
    required this.ratingCount,
    required this.isAvailable,
    required this.isVerified,
    required this.bio,
    required this.phone,
    this.distanceKm,
    this.garageType = 'standard',
    this.supportedVehicleTypes = const [],
    this.specialistApproved = false,
  });

  final int id;
  final String garageName;
  final String specialty;
  final List<String> services;
  final String address;
  final String area;
  final double latitude;
  final double longitude;
  final int priceMin;
  final int priceMax;
  final double ratingAvg;
  final int ratingCount;
  final bool isAvailable;
  final bool isVerified;
  final String bio;
  final String phone;
  final double? distanceKm;
  final String garageType;
  final List<String> supportedVehicleTypes;
  final bool specialistApproved;

  factory Mechanic.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    return Mechanic(
      id: json['id'] as int,
      garageName: json['garage_name'] as String? ?? '',
      specialty: json['specialty'] as String? ?? '',
      services: List<String>.from(json['services'] ?? const []),
      address: json['address'] as String? ?? '',
      area: json['area'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      priceMin: json['price_min'] as int? ?? 0,
      priceMax: json['price_max'] as int? ?? 0,
      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 0,
      ratingCount: json['rating_count'] as int? ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      bio: json['bio'] as String? ?? '',
      phone: user['phone'] as String? ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      garageType: json['garage_type'] as String? ?? 'standard',
      supportedVehicleTypes:
          List<String>.from(json['supported_vehicle_types'] ?? const []),
      specialistApproved: json['specialist_approved'] as bool? ?? false,
    );
  }
}

class JobRequest {
  JobRequest(this.raw);
  final Map<String, dynamic> raw;

  int get id => raw['id'] as int;
  String get kind => raw['kind'] as String;
  String get status => raw['status'] as String;
  String get description => raw['description'] as String? ?? '';
  String get address => raw['address'] as String? ?? '';
  int? get quoted => raw['quoted_amount'] as int?;
  String get customerName => raw['customer_name'] as String? ?? '';
  String get customerPhone => raw['customer_phone'] as String? ?? '';
  Map<String, dynamic>? get mechanic =>
      raw['mechanic_detail'] as Map<String, dynamic>?;
  Map<String, dynamic>? get rating => raw['rating'] as Map<String, dynamic>?;
  Map<String, dynamic>? get payment => raw['payment'] as Map<String, dynamic>?;
}

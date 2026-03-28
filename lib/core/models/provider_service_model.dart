class ProviderServiceModel {
  final String firstName;
  final String lastName;
  final String profileImage;
  final String email;
  final String phoneNumber;
  final String address;
  final String uid;
  final double latitude;
  final double longitude;
  final bool isOnline;
  final int? lastSeen;
    double? distanceFromUser; 
    bool isActive;
     final List<Map<String, String>> services;


  ProviderServiceModel({
    required this.firstName,
     required this.isOnline,
    required this.lastName,
    required this.profileImage,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.uid,
    required this.latitude,
    required this.longitude,
    this.lastSeen,
    this.distanceFromUser,
    this.isActive = true,
    this.services = const [],
  });
factory ProviderServiceModel.fromMap(Map<dynamic, dynamic> map) {
  return ProviderServiceModel(

    firstName: map['firstName']?.toString() ?? '',
    lastName: map['lastName']?.toString() ?? '',
    profileImage: map['profileImage']?.toString() ?? '',
    email: map['email']?.toString() ?? '',
       phoneNumber: map['phoneNumber']?.toString() ?? '',
    address: map['address']?.toString() ?? '',
    uid: map['uid']?.toString() ?? '',
  latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : 0.0,
    longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : 0.0,
    isOnline: map['isOnline'] ?? false,
    lastSeen: map['lastSeen'] ,
    distanceFromUser: map['distanceFromUser'],
    isActive: map['isActive'] ?? true,
     services: map['services'] != null
          ? List<Map<String, String>>.from(
              (map['services'] as List).map(
                (e) => Map<String, String>.from(e),
              ),
            )
          : [],
    );
  
}
  ProviderServiceModel copyWith({
    String? firstName,
    String? lastName,
    String? profileImage,
    String? email,
    String? phoneNumber,
    String? address,
    double? latitude,
    double? longitude,
    bool? isOnline,
    int? lastSeen,
    double? distanceFromUser,
    bool? isActive,
  }) {
    return ProviderServiceModel(
      uid: uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profileImage: profileImage ?? this.profileImage,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      distanceFromUser: distanceFromUser ?? this.distanceFromUser,
      isActive: isActive ?? this.isActive,
    );
  }

}

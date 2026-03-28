class BarberModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String profileImage;

  BarberModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.profileImage,
  });

  factory BarberModel.fromMap(Map<String, dynamic> map, String uid) {
    return BarberModel(
      uid: uid,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImage: map['profileImage'] ?? '',
    );
  }
}

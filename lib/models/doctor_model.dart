class DoctorModel {
  final String firstName;
  final String lastName;
  final String profileImage;
  final String email;
  final String phoneNumber;
  final String address;
  final String uid;
  final String category;
  final String qualification;
  final String yearsOfExperience;
  final double latitude;
  final double longitude;
  final int numberOfReviews;
  final int totalReviews;
  final bool isOnline;
  final int? lastSeen;

  DoctorModel({
    required this.firstName,
     required this.isOnline,
    required this.lastName,
    required this.profileImage,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.uid,
    required this.category,
    required this.qualification,
    required this.yearsOfExperience,
    required this.latitude,
    required this.longitude,
    required this.numberOfReviews,
    required this.totalReviews,
    this.lastSeen,
  });
factory DoctorModel.fromMap(Map<dynamic, dynamic> map) {
  return DoctorModel(

    firstName: map['firstName']?.toString() ?? '',
    lastName: map['lastName']?.toString() ?? '',
    profileImage: map['profileImage']?.toString() ?? '',
    email: map['email']?.toString() ?? '',
       phoneNumber: map['phoneNumber']?.toString() ?? '',
    address: map['address']?.toString() ?? '',
    uid: map['uid']?.toString() ?? '',
    category: map['category']?.toString() ?? '',
    qualification: map['qualification']?.toString() ?? '',
    yearsOfExperience: map['yearsOfExperience']?.toString() ?? '',
    latitude: map['latitude'] != null ? map['latitude'] * 1.0 : 0.0,
    longitude: map['longitude'] != null ? map['longitude'] * 1.0 : 0.0,
    numberOfReviews: map['numberOfReviews'] ?? 0,
    totalReviews: map['totalReviews'] ?? 0,
    isOnline: map['isOnline'] ?? false,
    lastSeen: map['lastSeen'] ,
  );
}

}

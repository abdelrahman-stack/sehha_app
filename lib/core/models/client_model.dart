class ClientModel {
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
  final String? lastMessage;
  final int? lastMessageTime; 
  final int? unreadMessages;

  ClientModel({
    required this.firstName,
    required this.lastName,
    required this.profileImage,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.uid,
    required this.latitude,
    required this.longitude,
    required this.isOnline,
    this.lastSeen,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadMessages,
  });

  factory ClientModel.fromMap(Map<String, dynamic> json) {
    return ClientModel(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profileImage: json['profileImage'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      uid: json['uid'] ?? '',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] ?? 0,
      lastMessage: json['lastMessage'] ,
      lastMessageTime: json['lastMessageTime'] ,
      unreadMessages: json['unreadMessages']  ,
    );
  }
  Map<String, dynamic> toMap() => {
        'firstName': firstName,
        'lastName': lastName,
        'profileImage': profileImage,
        'email': email,
        'phoneNumber': phoneNumber,
        'address': address,
        'uid': uid,
        'latitude': latitude,
        'longitude': longitude,
        'isOnline': isOnline,
        'lastSeen': lastSeen,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime,
        'unreadMessages': unreadMessages,
      };
}

// class BookingAppointmentModel {
//   final String date,
//       description,
//       id,
//       reciver,
//       sender,
//       status,
//       time,
//       senderName,
//       senderImage;
//   final int turnNumber;

//   BookingAppointmentModel({
//     required this.date,
//     required this.description,
//     required this.id,
//     required this.reciver,
//     required this.sender,
//     required this.status,
//     required this.time,
//     required this.senderName,
//     required this.senderImage,
//     required this.turnNumber,
//   });
//   factory BookingAppointmentModel.fromMap(Map<String, dynamic> json) {
//     return BookingAppointmentModel(
//       date: json['date'] ?? '',
//       description: json['description'] ?? '',
//       id: json['id'] ?? '',
//       reciver: json['reciver'] ?? '',
//       sender: json['sender'] ?? '',
//       status: json['status'] ?? 'pending',
//       time: json['time'] ?? '',
//       senderName: json['senderName'] ?? '',
//       senderImage: json['senderImage'] ?? '',
//       turnNumber: json['turnNumber'] ?? 0,
//     );
//   }
//   Map<String, dynamic> toMap() => {
//     'date': date,
//     'description': description,
//     'id': id,
//     'reciver': reciver,
//     'sender': sender,
//     'status': status,
//     'time': time,
//     'senderName': senderName,
//     'senderImage': senderImage,
//     'turnNumber': turnNumber,
//   };
// }


class BookingAppointmentModel {
  final String date,
      description,
      id,
      reciver,
      sender,
      status,
      time,
      senderName,
      senderImage,
      senderPhone,
      ratingStatus;
  final int turnNumber;
  final double? rating;

  BookingAppointmentModel({
    required this.date,
    required this.description,
    required this.id,
    required this.reciver,
    required this.sender,
    required this.status,
    required this.time,
    required this.senderName,
    required this.senderImage,
    required this.turnNumber,
    this.senderPhone = '',
    this.ratingStatus = 'انتظار التقييم',
    this.rating,
  });

  factory BookingAppointmentModel.fromMap(Map<String, dynamic> json) {
    return BookingAppointmentModel(
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      id: json['id'] ?? '',
      reciver: json['reciver'] ?? '',
      sender: json['sender'] ?? '',
      status: json['status'] ?? 'pending',
      time: json['time'] ?? '',
      senderName: json['senderName'] ?? '',
      senderImage: json['senderImage'] ?? '',
      senderPhone: json['senderPhone'] ?? '',
      turnNumber: json['turnNumber'] ?? 0,
      ratingStatus: json['ratingStatus'] ?? 'انتظار التقييم',
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'date': date,
        'description': description,
        'id': id,
        'reciver': reciver,
        'sender': sender,
        'status': status,
        'time': time,
        'senderName': senderName,
        'senderImage': senderImage,
        'senderPhone': senderPhone,
        'turnNumber': turnNumber,
        'ratingStatus': ratingStatus,
        'rating': rating,
      };
}
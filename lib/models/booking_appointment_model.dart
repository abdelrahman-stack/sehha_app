class BookingAppointmentModel {
  final String date, description, id, reciver, sender, status, time,senderName,senderImage;

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
  };
}

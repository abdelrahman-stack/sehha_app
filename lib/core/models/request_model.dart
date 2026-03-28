
class RequestModel {
  final String id;
  final String senderName;
  final String senderImage;
  final String phone;
  final String date;
  final String time;
  final String description;
  final String status;
  final String reciver;
  final String senderId; 
  final int? queueNumber; 

  RequestModel({
    required this.id,
    required this.senderName,
    required this.senderImage,
    required this.phone,
    required this.date,
    required this.time,
    required this.description,
    required this.status,
    required this.reciver,
    required this.senderId,
    this.queueNumber,
  });

  factory RequestModel.fromMap(Map<String, dynamic> map, String id) {
    return RequestModel(
      id: id,
      senderName: map['senderName'] ?? '',
      senderImage: map['senderImage'] ?? '',
      phone: map['phone'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'قيد الانتظار',
      reciver: map['reciver'] ?? '',
      senderId: map['senderId'] ?? '', // لازم يكون موجود في الـ Database
      queueNumber: map['queueNumber'] != null ? map['queueNumber'] as int : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderName': senderName,
      'senderImage': senderImage,
      'phone': phone,
      'date': date,
      'time': time,
      'description': description,
      'status': status,
      'reciver': reciver,
      'senderId': senderId,
      'queueNumber': queueNumber,
    };
  }
}

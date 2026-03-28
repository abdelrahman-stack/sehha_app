class CustomerModel {
  final String name;
  final String phone;
  final String address;

  CustomerModel({
    required this.name,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
    };
  }
}

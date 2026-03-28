class ProductsModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String code;

  ProductsModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.code,
  });

  factory ProductsModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductsModel(
      id: id,
      name: map['name'],
      description: map['description'],
      price: (map['price'] as num).toDouble(),
      image: map['image'],
      code: map['code'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'code': code,
    };
  }
}

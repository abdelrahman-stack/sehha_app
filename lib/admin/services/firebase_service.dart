import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final DatabaseReference productsRef =
      FirebaseDatabase.instance.ref().child('products');

  static Future<void> saveProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
  }) async {
    await productsRef.child(id).set({
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': imageUrl,
      'isActive': true,
      'createdAt': ServerValue.timestamp,
    });
  }

  static Future<void> deleteProduct(String id) async {
    await productsRef.child(id).remove();
  }
}

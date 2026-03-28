import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehha_app/core/models/cart_item.dart';

class CartCubit extends Cubit<List<CartItem>> {
  CartCubit() : super([]);

  void addToCart(Map<String, dynamic> product) {
    final index = state.indexWhere((e) => e.id == product['id']);
    if (index != -1) {
      state[index].quantity++;
      emit(List.from(state));
    } else {
      emit([
        ...state,
        CartItem(
          id: product['id'],
          name: product['name'],
          image: product['image'],
          price: product['price'].toDouble(),
        ),
      ]);
    }
  }

  void increase(CartItem item) {
    item.quantity++;
    emit(List.from(state));
  }

  void decrease(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
      emit(List.from(state));
    }
  }

  double get totalPrice =>
      state.fold(0, (sum, item) => sum + item.total);

  void clear() => emit([]);
}

part of 'cart_cubit.dart';

abstract class CartCubit {}

class CartInitial extends CartCubit {}

class CartLoading extends CartCubit {}

class CartSuccess extends CartCubit {}
class CartError extends CartCubit {
  final String message;
  CartError(this.message);
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehha_app/core/cubit/cart_cubit/cart_cubit.dart';
import 'package:sehha_app/store/widgets/cart_view.dart';
import 'package:sehha_app/store/widgets/product_card.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sehha_app/widgets/lottie_loading_Indicator.dart';

class StoreView extends StatelessWidget {
  const StoreView({super.key, this.onGoBackFromOrder});
  final VoidCallback? onGoBackFromOrder;
  @override
  Widget build(BuildContext context) {
    final productsRef = FirebaseDatabase.instance.ref('products');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'المتجر الالكتروني',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),

        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<CartCubit>(),
                    child: const CartView(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: productsRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CustomCircularProgressIndicator());
          }

          final productsMap =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
          if (productsMap == null) {
            return const Center(child: Text('لا يوجد منتجات'));
          }

          final products = productsMap.values
              .map((e) => Map<String, dynamic>.from(e))
              .toList();

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 17,
              childAspectRatio: 0.45,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return ProductCard(
                product: p,
                onAddToCart: () {
                  context.read<CartCubit>().addToCart(p);
                },
              );
            },
          );
        },
      ),
    );
  }
}

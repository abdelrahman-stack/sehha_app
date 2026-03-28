// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:sehha_app/core/cubit/cart_cubit/cart_cubit.dart';
// import 'package:sehha_app/widgets/custom_snack_bar.dart';

// class OrderSummaryView extends StatelessWidget {
//   final String paymentMethod;
//   final String name;
//   final String phone;
//   final String address;
//   final VoidCallback? onGoBackToStore;
//   const OrderSummaryView({
//     required this.paymentMethod,
//     required this.name,
//     required this.phone,
//     required this.address,
//     this.onGoBackToStore,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final cartCubit = context.read<CartCubit>();
//     final cartItems = context.watch<CartCubit>().state;
//     final total = cartCubit.totalPrice;
//     final shippingText = 'حسب العنوان أو الموقع';
//     final finalTotalText = '$total + الشحن';

//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       appBar: AppBar(
//         title: const Text(
//           'مراجعة الطلب',
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.green.shade700,
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: cartItems.length,
//                 itemBuilder: (context, index) {
//                   final item = cartItems[index];
//                   return Container(
//                     margin: const EdgeInsets.symmetric(vertical: 8),
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 8,
//                           offset: Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: Image.network(
//                             item.image,
//                             width: 60,
//                             height: 60,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 item.name,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'السعر: ${item.price} × ${item.quantity}',
//                                 style: const TextStyle(color: Colors.grey),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Text(
//                           '${item.price * item.quantity} ج.م',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 8,
//                     offset: Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'مصاريف الشحن',
//                         style: TextStyle(fontSize: 16),
//                       ),
//                       Text(
//                         shippingText,
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text('الإجمالي', style: TextStyle(fontSize: 16)),
//                       Text(
//                         finalTotalText,
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   backgroundColor: Colors.green.shade700,
//                   elevation: 6,
//                   shadowColor: Colors.green.shade300,
//                 ),
//                 onPressed: () async {
//                   final ref = FirebaseDatabase.instance.ref('orders').push();

//                   await ref.set({
//                     'customer': {
//                       'name': name,
//                       'phone': phone,
//                       'address': address,
//                     },
//                     'paymentMethod': paymentMethod,
//                     'items': cartItems.map((e) => e.toMap()).toList(),
//                     'total': total,
//                     'shipping': shippingText,
//                     'finalTotal': finalTotalText,
//                     'status': 'new',
//                     'createdAt': DateTime.now().millisecondsSinceEpoch,
//                   });

//                   cartCubit.clear();

//                   CustomSnackBar.show(
//                     context,
//                     message: 'تم تاكيد الطلب',
//                     backgroundColor: Colors.green.shade700,
//                   );

//                   if (onGoBackToStore != null) {
//                     onGoBackToStore!();
//                   } else {
//                     Navigator.popUntil(
//                       context,
//                       (route) => route.isFirst,
//                     );
//                   }
//                 },
//                 child: const Text(
//                   'تأكيد الطلب',
//                   style: TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sehha_app/core/cubit/cart_cubit/cart_cubit.dart';
import 'package:sehha_app/widgets/custom_snack_bar.dart';

class OrderSummaryView extends StatelessWidget {
  final String paymentMethod;
  final String name;
  final String phone;
  final String address;
  final VoidCallback? onGoBackToStore;

  const OrderSummaryView({
    required this.paymentMethod,
    required this.name,
    required this.phone,
    required this.address,
    this.onGoBackToStore,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cartCubit = context.read<CartCubit>();
    final cartItems = context.watch<CartCubit>().state;
    final total = cartCubit.totalPrice;
    final shippingText = 'حسب العنوان أو الموقع';
    final finalTotalText = '$total + الشحن';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'مراجعة الطلب',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item.image,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'السعر: ${item.price} × ${item.quantity}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${item.price * item.quantity} ج.م',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'مصاريف الشحن',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        shippingText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الإجمالي', style: TextStyle(fontSize: 16)),
                      Text(
                        finalTotalText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.green.shade700,
                  elevation: 6,
                  shadowColor: Colors.green.shade300,
                ),
                onPressed: () async {
                  final ref = FirebaseDatabase.instance.ref('orders').push();

                  await ref.set({
                    'customer': {
                      'name': name,
                      'phone': phone,
                      'address': address,
                    },
                    'paymentMethod': paymentMethod,
                    'items': cartItems.map((e) => e.toMap()).toList(),
                    'total': total,
                    'shipping': shippingText,
                    'finalTotal': finalTotalText,
                    'status': 'new',
                    'createdAt': DateTime.now().millisecondsSinceEpoch,
                  });

                  cartCubit.clear();

                  CustomSnackBar.show(
                    context,
                    message: 'تم تاكيد الطلب',
                    backgroundColor: Colors.green.shade700,
                  );

                  if (onGoBackToStore != null) {
                    onGoBackToStore!();
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                  }
                },

                child: const Text(
                  'تأكيد الطلب',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

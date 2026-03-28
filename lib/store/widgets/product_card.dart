import 'package:flutter/material.dart';
import 'package:sehha_app/store/widgets/product_details_view.dart';
import 'package:sehha_app/widgets/custom_snack_bar.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onAddToCart;

  const ProductCard({required this.product, this.onAddToCart, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsView(product: product),
      ),
    );
  },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 6,
        shadowColor: Colors.black26,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // الصورة
            SizedBox(
              height: 160, // 🔥 ارتفاع ثابت
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Stack(
                  children: [
                    Image.network(
                      product['image'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: .1),
                            Colors.black.withValues(alpha: .05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      
            // المحتوى
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم المنتج
                  Text(
                    product['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
      
                  const SizedBox(height: 4),
      
                  // وصف المنتج
                  Text(
                    product['description'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
      
                  const SizedBox(height: 6),
      
                  // السعر
                  Text(
                    '${product['price']} ج.م',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
      
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (onAddToCart != null) onAddToCart!();
      
                        CustomSnackBar.show(
                          context,
                          message: 'تم اضافة المنتج للسلة',
                          backgroundColor: Colors.green.shade700,
                          duration: const Duration(seconds: 2),
                          icon: Icons.check_circle_outline,
                        );
                      },
                      icon: const Icon(
                        Icons.add_shopping_cart,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'أضف للسلة',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

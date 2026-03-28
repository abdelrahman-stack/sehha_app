import 'package:flutter/material.dart';
import 'package:sehha_app/admin/services/firebase_service.dart';
import 'package:sehha_app/admin/views/widgets/add_edit_product_view.dart';
import 'package:sehha_app/widgets/lottie_loading_Indicator.dart';

const _kDark = Color(0xFF0A0E1A);
const _kDark2 = Color(0xFF121C30);
const _kBlue = Color(0xFF274BEF);

class ProductView extends StatelessWidget {
  const ProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kDark,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_kDark, _kDark2, _kDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, .5, 1],
              ),
            ),
          ),
          const Positioned(top: -50, left: -50, child: _Glow(180, _kBlue)),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'إدارة المنتجات',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddEditProductView(),
                          ),
                        ),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_kBlue, Color(0xFF1E3FCC)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _kBlue.withValues(alpha: .4),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseService.productsRef.onValue,
                    builder: (ctx, snap) {
                      if (!snap.hasData) {
                        return const Center(
                          child: CustomCircularProgressIndicator(),
                        );
                      }
                      final map =
                          snap.data!.snapshot.value as Map<dynamic, dynamic>?;
                      if (map == null) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .06),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.inventory_2_rounded,
                                  color: Colors.white30,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'لا يوجد منتجات',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: .4),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final products = map.values
                          .map((e) => Map<String, dynamic>.from(e))
                          .toList();
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: products.length,
                        itemBuilder: (ctx, i) => _ProductItem(
                          product: products[i],
                          context: context,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductItem extends StatelessWidget {
  final Map<String, dynamic> product;
  final BuildContext context;
  const _ProductItem({required this.product, required this.context});

  @override
  Widget build(BuildContext _) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product['image'] ?? '',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.image_not_supported_rounded,
                  color: Colors.white30,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF66BB6A).withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${product['price']} ج.م',
                    style: const TextStyle(
                      color: Color(0xFF66BB6A),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditProductView(product: product),
                  ),
                ),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.orangeAccent.withValues(alpha: .3),
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.orangeAccent,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              GestureDetector(
                onTap: () => _showDeleteDialog(context, product),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: .3),
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_rounded,
                    color: Colors.redAccent,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext ctx, Map<String, dynamic> p) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: .6),
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF141E30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.redAccent,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'حذف المنتج',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'هل أنت متأكد من حذف هذا المنتج؟ لن تتمكن من استرجاعه.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .5),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        FirebaseService.deleteProduct(p['id']);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: const Text('تم حذف المنتج'),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: .15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.redAccent.withValues(alpha: .5),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'حذف',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .07),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'إلغاء',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .6),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  const _Glow(this.size, this.color);
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: .12),
    ),
  );
}

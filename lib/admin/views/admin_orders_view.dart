import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:sehha_app/widgets/lottie_loading_Indicator.dart';

const _kDark = Color(0xFF0A0E1A);
const _kDark2 = Color(0xFF121C30);
const _kBlue = Color(0xFF274BEF);

class AdminOrdersView extends StatelessWidget {
  const AdminOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersRef = FirebaseDatabase.instance.ref('orders');

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
          const Positioned(top: -60, right: -50, child: _Glow(200, _kBlue)),

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
                          'الطلبات',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: StreamBuilder<DatabaseEvent>(
                    stream: ordersRef.onValue,
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Center(
                          child: CustomCircularProgressIndicator(),
                        );
                      }
                      final data = snap.data!.snapshot.value;
                      if (data == null) {
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
                                  Icons.receipt_long_rounded,
                                  color: Colors.white30,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'لا يوجد طلبات',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: .4),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final ordersMap = Map<String, dynamic>.from(data as Map);
                      final orders = ordersMap.entries
                          .toList()
                          .reversed
                          .toList();

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: orders.length,
                        itemBuilder: (ctx, i) {
                          final orderId = orders[i].key;
                          final order = Map<String, dynamic>.from(
                            orders[i].value,
                          );
                          final customer = order['customer'] ?? {};
                          final items =
                              (order['items'] as List<dynamic>?) ?? [];
                          final status = order['status'] ?? 'new';

                          return _OrderCard(
                            order: order,
                            orderId: orderId,
                            customer: customer,
                            items: items,
                            status: status,
                            ordersRef: ordersRef,
                          );
                        },
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

class _OrderCard extends StatelessWidget {
  final Map order, customer;
  final List items;
  final String orderId, status;
  final DatabaseReference ordersRef;
  const _OrderCard({
    required this.order,
    required this.orderId,
    required this.customer,
    required this.items,
    required this.status,
    required this.ordersRef,
  });

  Color get _statusColor => status == 'done'
      ? const Color(0xFF66BB6A)
      : status == 'preparing'
      ? const Color(0xFFFFB74D)
      : const Color(0xFF64B5F6);
  String get _statusLabel => status == 'done'
      ? 'تم التسليم'
      : status == 'preparing'
      ? 'جاري التجهيز'
      : 'جديد';
  IconData get _statusIcon => status == 'done'
      ? Icons.check_circle_rounded
      : status == 'preparing'
      ? Icons.hourglass_top_rounded
      : Icons.fiber_new_rounded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: .08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .04),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: .06)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer['name'] ?? 'بدون اسم',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_rounded,
                            color: Colors.white38,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            customer['phone'] ?? '',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .45),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _statusColor.withValues(alpha: .35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, color: _statusColor, size: 12),
                      const SizedBox(width: 5),
                      Text(
                        _statusLabel,
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Colors.redAccent,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        customer['address'] ?? '',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .06),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المنتجات',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .6),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...items.map((it) {
                        final item = Map<String, dynamic>.from(it);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item['name']} × ${item['quantity']}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                '${(item['price'] * item['quantity'])} ج.م',
                                style: const TextStyle(
                                  color: Color(0xFF66BB6A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF66BB6A).withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(
                              0xFF66BB6A,
                            ).withValues(alpha: .25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الإجمالي',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .5),
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${order['finalTotal']} ج.م',
                              style: const TextStyle(
                                color: Color(0xFF66BB6A),
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .04),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .07),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'طريقة الدفع',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .5),
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order['paymentMethod'] == 'cash'
                                  ? 'كاش 💵'
                                  : 'أونلاين 💳',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تغيير الحالة',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .5),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    PopupMenuButton<String>(
                      color: const Color(0xFF1A2540),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      onSelected: (val) =>
                          ordersRef.child(orderId).child('status').set(val),
                      itemBuilder: (_) => [
                        _menuItem('new', '🆕 جديد'),
                        _menuItem('preparing', '🔧 جاري التجهيز'),
                        _menuItem('done', '✅ تم التسليم'),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: _kBlue.withValues(alpha: .2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _kBlue.withValues(alpha: .5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'تعديل',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .8),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.expand_more_rounded,
                              color: Colors.white54,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String v, String t) => PopupMenuItem(
    value: v,
    child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 14)),
  );
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

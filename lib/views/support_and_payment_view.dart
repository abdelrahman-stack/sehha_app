import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportAndPaymentView extends StatefulWidget {
  const SupportAndPaymentView({super.key});
  @override
  State<SupportAndPaymentView> createState() => _SupportAndPaymentViewState();
}

class _SupportAndPaymentViewState extends State<SupportAndPaymentView>
    with SingleTickerProviderStateMixin {
  static const String paymentPhone = '01027658916';
  static const _purple = Color(0xFF4A148C);
  static const _purpleLight = Color(0xFF7B1FA2);

  final List<Map<String, String>> centers = const [
    {'name': 'مركز صيانة CURLY', 'phone': '+201027658916'},
  ];

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void callNumber(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void copyNumber(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: paymentPhone));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('تم نسخ الرقم بنجاح'),
          ],
        ),
        backgroundColor: _purple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF120A1E), Color(0xFF2D1B45)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const Positioned(
            top: -40,
            right: -40,
            child: _GlowCircle(size: 180, color: _purple),
          ),
          const Positioned(
            bottom: -60,
            left: -40,
            child: _GlowCircle(size: 160, color: _purpleLight),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'خدمة العملاء واستفسارات الدفع',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionHeader(
                            title: 'الدفع الإلكتروني',
                            icon: Icons.payment_rounded,
                          ),
                          const SizedBox(height: 12),

                          _DarkCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _purple.withValues(alpha: .2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.account_balance_wallet_rounded,
                                        color: Color(0xFFCE93D8),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'InstaPay أو Vodafone Cash',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'لدفع قيمة الاشتراك، يرجى إرسال المبلغ على الرقم التالي:',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: .6),
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: .06),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _purpleLight.withValues(alpha: .4),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.phone_android_rounded,
                                        color: Color(0xFFCE93D8),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      const Expanded(
                                        child: Text(
                                          paymentPhone,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => copyNumber(context),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: _purple.withValues(
                                              alpha: .3,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.copy_rounded,
                                            color: Color(0xFFCE93D8),
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          _DarkCard(
                            borderColor: const Color(
                              0xFF1565C0,
                            ).withValues(alpha: .5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF1565C0,
                                    ).withValues(alpha: .2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.info_outline_rounded,
                                    color: Color(0xFF90CAF9),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'بعد إتمام عملية الدفع:',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      _InfoRow(
                                        icon: Icons.camera_alt_rounded,
                                        text: 'التقط صورة واضحة لإيصال الدفع أو شاشة تأكيد العملية',
                                      ),
                                      SizedBox(height: 6),
                                      _InfoRow(
                                        icon: Icons.message_rounded,
                                        text:
                                            'أرسل صورة التحويل على واتساب لتأكيد الدفع',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          const _SectionHeader(
                            title: 'خدمة العملاء',
                            icon: Icons.support_agent_rounded,
                          ),
                          const SizedBox(height: 12),

                          ...centers.map(
                            (center) => _ContactCard(
                              name: center['name']!,
                              phone: center['phone']!,
                              onCall: () => callNumber(center['phone']!),
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: const Color(0xFFCE93D8), size: 20),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

class _DarkCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  const _DarkCard({required this.child, this.borderColor});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: borderColor ?? Colors.white.withValues(alpha: .1),
        width: 1,
      ),
    ),
    child: child,
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: const Color(0xFF90CAF9), size: 16),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .65),
            fontSize: 13,
          ),
        ),
      ),
    ],
  );
}

class _ContactCard extends StatelessWidget {
  final String name, phone;
  final VoidCallback onCall;
  const _ContactCard({
    required this.name,
    required this.phone,
    required this.onCall,
  });
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: .1)),
    ),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: .15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.orange.withValues(alpha: .3),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.support_agent_rounded,
            color: Colors.orangeAccent,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onCall,
                child: Row(
                  children: [
                    const Icon(
                      Icons.phone_rounded,
                      color: Colors.greenAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      phone,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onCall,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.greenAccent.withValues(alpha: .3),
              ),
            ),
            child: const Icon(
              Icons.call_rounded,
              color: Colors.greenAccent,
              size: 20,
            ),
          ),
        ),
      ],
    ),
  );
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowCircle({required this.size, required this.color});
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

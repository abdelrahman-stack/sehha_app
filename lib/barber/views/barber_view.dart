import 'package:flutter/material.dart';
import 'package:sehha_app/barber/views/barber_chat_list_view.dart';
import 'package:sehha_app/barber/views/barber_profile_view.dart';
import 'package:sehha_app/barber/views/barber_requests_view.dart';
import 'package:sehha_app/store/views/store_view.dart';
import 'package:sehha_app/views/support_and_payment_view.dart';
import '../../core/utils/app_colors.dart';

class BarberView extends StatefulWidget {
  const BarberView({super.key});
  @override
  State<BarberView> createState() => _BarberViewState();
}

class _BarberViewState extends State<BarberView> {
  int currentIndex = 0;
  void goToStore() => setState(() => currentIndex = 2);

  @override
  Widget build(BuildContext context) {
    final screens = [
      const BarberRequestsView(),
      const BarberChatListView(),
      StoreView(onGoBackFromOrder: goToStore),
      const SupportAndPaymentView(),
      const BarberProfileView(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: _AppNavBar(
        currentIndex: currentIndex,
        accentColor: AppColors.secondaryColor,
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          _NavItem(
            icon: Icons.home_rounded,
            activeIcon: Icons.home_rounded,
            label: 'الرئيسية',
          ),
          _NavItem(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble_rounded,
            label: 'الدردشة',
          ),
          _NavItem(
            icon: Icons.shopping_bag_outlined,
            activeIcon: Icons.shopping_bag_rounded,
            label: 'المتجر',
          ),
          _NavItem(
            icon: Icons.headset_mic_outlined,
            activeIcon: Icons.headset_mic_rounded,
            label: 'الدعم',
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'ملفي',
          ),
        ],
      ),
    );
  }
}

class _AppNavBar extends StatelessWidget {
  final int currentIndex;
  final Color accentColor;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  const _AppNavBar({
    required this.currentIndex,
    required this.accentColor,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 64 + bottom,
      decoration: BoxDecoration(
        color: const Color(0xFF0A1520),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: .06)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .5),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Row(
          children: List.generate(items.length, (i) {
            final active = i == currentIndex;
            final isCenter = i == 2;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: isCenter
                    ? _CenterNavBtn(
                        item: items[i],
                        active: active,
                        color: accentColor,
                      )
                    : _SideNavBtn(
                        item: items[i],
                        active: active,
                        color: accentColor,
                      ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _SideNavBtn extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final Color color;
  const _SideNavBtn({
    required this.item,
    required this.active,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 220),
    curve: Curves.easeOutCubic,
    height: 64,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: .18) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            active ? item.activeIcon : item.icon,
            color: active ? color : Colors.white.withValues(alpha: .3),
            size: 22,
          ),
        ),
        const SizedBox(height: 2),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'Cairo',
            color: active ? color : Colors.white.withValues(alpha: .3),
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          ),
          child: Text(item.label),
        ),
      ],
    ),
  );
}

class _CenterNavBtn extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final Color color;
  const _CenterNavBtn({
    required this.item,
    required this.active,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 48,
        height: 42,
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(colors: [color, color.withValues(alpha: .7)])
              : null,
          color: active ? null : Colors.white.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(14),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: .4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Icon(
          active ? item.activeIcon : item.icon,
          color: active ? Colors.white : Colors.white.withValues(alpha: .3),
          size: 22,
        ),
      ),
      const SizedBox(height: 2),
      AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: TextStyle(
          fontSize: 10,
          fontFamily: 'Cairo',
          color: active ? color : Colors.white.withValues(alpha: .3),
          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
        ),
        child: Text(item.label),
      ),
    ],
  );
}

class _NavItem {
  final IconData icon, activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sehha_app/beauty_center/views/beauty_center_profile_view.dart';
import 'package:sehha_app/beauty_center/views/beauty_center_requests_view.dart';
import 'package:sehha_app/beauty_center/views/customer_chat_list.dart';
import 'package:sehha_app/beauty_center/views/customer_list_view.dart';
import 'package:sehha_app/beauty_center/views/customer_profile_view.dart';
import 'package:sehha_app/store/views/store_view.dart';
import 'package:sehha_app/views/support_and_payment_view.dart';


const _kAccent = Color(0xFF7EDBD5);
const _kPink2 = Color(0xFF1A8A84);
const _kDark = Color(0xFF0C0810);
const _kDark2 = Color(0xFF160F1A);

class CustomerView extends StatefulWidget {
  const CustomerView({super.key});
  @override
  State<CustomerView> createState() => _CustomerViewState();
}

class _CustomerViewState extends State<CustomerView> {
  int currentIndex = 0;
  void goToStore() => setState(() => currentIndex = 2);

  @override
  Widget build(BuildContext context) {
    final screens = [
      const CustomerListView(),
      const CustomerChatList(),
      StoreView(onGoBackFromOrder: goToStore),
      const SupportAndPaymentView(),
      const CustomerProfileView(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kDark,
        body: IndexedStack(index: currentIndex, children: screens),
        bottomNavigationBar: _BeautyBottomNav(
          currentIndex: currentIndex,
          onTap: (i) {
            HapticFeedback.selectionClick();
            setState(() => currentIndex = i);
          },
          items: const [
            _NItem(Icons.home_rounded, Icons.home_outlined, 'الرئيسية'),
            _NItem(
              Icons.chat_bubble_rounded,
              Icons.chat_bubble_outline,
              'الدردشة',
            ),
            _NItem(
              Icons.shopping_bag_rounded,
              Icons.shopping_bag_outlined,
              'المتجر',
            ),
            _NItem(
              Icons.headset_mic_rounded,
              Icons.headset_mic_outlined,
              'دعم',
            ),
            _NItem(Icons.person_rounded, Icons.person_outline_rounded, 'حسابي'),
          ],
        ),
      ),
    );
  }
}

class BeautyCenterView extends StatefulWidget {
  const BeautyCenterView({super.key});
  @override
  State<BeautyCenterView> createState() => _BeautyCenterViewState();
}

class _BeautyCenterViewState extends State<BeautyCenterView> {
  int currentIndex = 0;
  void goToStore() => setState(() => currentIndex = 2);

  @override
  Widget build(BuildContext context) {
    final screens = [
      const BeautyCenterRequestsView(),
      const BeautyCenterChatListView(),
      StoreView(onGoBackFromOrder: goToStore),
      const SupportAndPaymentView(),
      const BeautyCenterProfileView(),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kDark,
        body: IndexedStack(index: currentIndex, children: screens),
        bottomNavigationBar: _BeautyBottomNav(
          currentIndex: currentIndex,
          onTap: (i) {
            HapticFeedback.selectionClick();
            setState(() => currentIndex = i);
          },
          items: const [
            _NItem(
              Icons.event_note_rounded,
              Icons.event_note_outlined,
              'الطلبات',
            ),
            _NItem(
              Icons.chat_bubble_rounded,
              Icons.chat_bubble_outline,
              'الدردشة',
            ),
            _NItem(
              Icons.shopping_bag_rounded,
              Icons.shopping_bag_outlined,
              'المتجر',
            ),
            _NItem(
              Icons.headset_mic_rounded,
              Icons.headset_mic_outlined,
              'دعم',
            ),
            _NItem(Icons.person_rounded, Icons.person_outline_rounded, 'حسابي'),
          ],
        ),
      ),
    );
  }
}

class _NItem {
  final IconData activeIcon, inactiveIcon;
  final String label;
  const _NItem(this.activeIcon, this.inactiveIcon, this.label);
}

class _BeautyBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NItem> items;
  final ValueChanged<int> onTap;
  const _BeautyBottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72 + MediaQuery.of(context).padding.bottom,
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: _kDark2,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: .06), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .35),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = currentIndex == i;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    width: active ? 46 : 34,
                    height: active ? 34 : 28,
                    decoration: active
                        ? BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_kAccent, _kPink2],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: _kAccent.withValues(alpha: .5),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          )
                        : null,
                    child: Icon(
                      active ? items[i].activeIcon : items[i].inactiveIcon,
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: .28),
                      size: active ? 20 : 17,
                    ),
                  ),
                  const SizedBox(height: 5),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: active
                          ? _kAccent
                          : Colors.white.withValues(alpha: .28),
                      fontSize: active ? 10.5 : 9.5,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                    ),
                    child: Text(items[i].label, textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

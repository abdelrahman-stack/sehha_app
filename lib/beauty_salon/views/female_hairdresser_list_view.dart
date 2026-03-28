import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/app_router.dart';
import '../../core/models/provider_service_model.dart';

const _kAccent = Color(0xFFE91E8C);
const _kPink2 = Color(0xFF880E4F);
const _kPink = Color(0xFFAD1457);
const _kDark = Color(0xFF0C0810);
const _kDark2 = Color(0xFF160F1A);
const _kSurf = Color(0xFF1C1020);

class FemaleHairdresserListView extends StatefulWidget {
  const FemaleHairdresserListView({super.key});
  @override
  State<FemaleHairdresserListView> createState() =>
      _FemaleHairdresserListViewState();
}

class _FemaleHairdresserListViewState extends State<FemaleHairdresserListView> {
  List<ProviderServiceModel> hairdressers = [];
  List<ProviderServiceModel> filtered = [];
  bool isLoading = true;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _fetchNearby(pos.latitude, pos.longitude);
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchNearby(double myLat, double myLng) async {
    final event = await FirebaseDatabase.instance.ref('Hairdressers').once();
    final temp = <ProviderServiceModel>[];
    if (event.snapshot.value != null) {
      (event.snapshot.value as Map).forEach((k, v) {
        final d = Map<String, dynamic>.from(v)..['uid'] = k;
        final h = ProviderServiceModel.fromMap(d);
        if (h.latitude == 0 || h.longitude == 0) return;
        final dist = Geolocator.distanceBetween(
          myLat,
          myLng,
          h.latitude,
          h.longitude,
        );
        h.distanceFromUser = dist;
        if (dist <= 10000) temp.add(h);
      });
    }
    temp.sort((a, b) => a.distanceFromUser!.compareTo(b.distanceFromUser!));
    setState(() {
      hairdressers = temp;
      filtered = temp;
      isLoading = false;
    });
  }

  void _search(String q) {
    setState(() {
      _query = q;
      filtered = q.isEmpty
          ? hairdressers
          : hairdressers
                .where(
                  (h) =>
                      h.firstName.toLowerCase().contains(q.toLowerCase()) ||
                      h.lastName.toLowerCase().contains(q.toLowerCase()),
                )
                .toList();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _kDark,
    body: Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_kDark, _kDark2, _kDark],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, .55, 1],
            ),
          ),
        ),
        const Positioned(top: -80, right: -60, child: _Glow(240, _kPink, .07)),
        const Positioned(
          bottom: -50,
          left: -40,
          child: _Glow(180, _kAccent, .05),
        ),

        SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'اكتشفي كوافيرتك 💅',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'الكوافيرات القريبة منك في 10 كم',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .33),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _load,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: .08),
                              ),
                            ),
                            child: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Search
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .08),
                        ),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        cursorColor: _kAccent,
                        onChanged: _search,
                        decoration: InputDecoration(
                          hintText: 'ابحثي عن كوافيرة...',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: .2),
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Colors.white.withValues(alpha: .28),
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: isLoading
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 34,
                              height: 34,
                              child: CircularProgressIndicator(
                                color: _kAccent,
                                strokeWidth: 2.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'جارٍ البحث...',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .28),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 78,
                              height: 78,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _kAccent.withValues(alpha: .06),
                                border: Border.all(
                                  color: _kAccent.withValues(alpha: .14),
                                ),
                              ),
                              child: Icon(
                                Icons.search_off_rounded,
                                color: _kAccent.withValues(alpha: .38),
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد نتائج',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .24),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final h = filtered[i];
                          return GestureDetector(
                            onTap: () {
                              if (!h.isActive) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'هذه الكوافيرة غير متاحة حالياً',
                                    ),
                                    backgroundColor: Colors.redAccent,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                                return;
                              }
                              HapticFeedback.lightImpact();
                              GoRouter.of(context).push(
                                AppRouter.kServiceFemaleDetailsView,
                                extra: h,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _kSurf.withValues(alpha: .78),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: h.isActive
                                      ? _kAccent.withValues(alpha: .12)
                                      : Colors.white.withValues(alpha: .05),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: .22),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              _kPink.withValues(alpha: .3),
                                              _kAccent.withValues(alpha: .2),
                                            ],
                                          ),
                                          border: Border.all(
                                            color: _kAccent.withValues(
                                              alpha: .38,
                                            ),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _kAccent.withValues(
                                                alpha: .18,
                                              ),
                                              blurRadius: 10,
                                            ),
                                          ],
                                        ),
                                        child: ClipOval(
                                          child:
                                              h.profileImage != null &&
                                                  h.profileImage!.isNotEmpty
                                              ? Image.network(
                                                  h.profileImage!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      _av(h.firstName),
                                                )
                                              : _av(h.firstName),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 2,
                                        right: 2,
                                        child: Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: h.isActive
                                                ? const Color(0xFF66BB6A)
                                                : Colors.redAccent,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: _kDark,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          h.firstName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          h.lastName,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: .38,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _badge(
                                              Icons.location_on_rounded,
                                              Colors.redAccent,
                                              h.distanceFromUser! >= 1000
                                                  ? '${(h.distanceFromUser! / 1000).toStringAsFixed(1)} كم'
                                                  : '${h.distanceFromUser!.toStringAsFixed(0)} م',
                                            ),
                                            const SizedBox(width: 8),
                                            _badge(
                                              h.isActive
                                                  ? Icons.check_circle_rounded
                                                  : Icons.cancel_rounded,
                                              h.isActive
                                                  ? const Color(0xFF66BB6A)
                                                  : Colors.redAccent,
                                              h.isActive
                                                  ? 'متاحة'
                                                  : 'غير متاحة',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: h.isActive
                                          ? _kAccent.withValues(alpha: .1)
                                          : Colors.white.withValues(alpha: .04),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: h.isActive
                                            ? _kAccent.withValues(alpha: .28)
                                            : Colors.white.withValues(
                                                alpha: .06,
                                              ),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: h.isActive
                                          ? _kAccent
                                          : Colors.white.withValues(alpha: .22),
                                      size: 13,
                                    ),
                                  ),
                                ],
                              ),
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

  Widget _av(String n) => Container(
    color: _kAccent.withValues(alpha: .1),
    child: Center(
      child: Text(
        n.isNotEmpty ? n[0].toUpperCase() : '?',
        style: const TextStyle(
          color: _kAccent,
          fontWeight: FontWeight.w900,
          fontSize: 22,
        ),
      ),
    ),
  );

  Widget _badge(IconData icon, Color color, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  const _Glow(this.size, this.color, this.opacity);
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: opacity),
    ),
  );
}

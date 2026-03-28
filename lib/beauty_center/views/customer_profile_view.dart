import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/lottie_loading_Indicator.dart';
import '../../core/utils/app_router.dart';
import '../../core/models/provider_service_model.dart';

class CustomerProfileView extends StatefulWidget {
  const CustomerProfileView({super.key});
  @override
  State<CustomerProfileView> createState() => _CustomerProfileViewState();
}

class _CustomerProfileViewState extends State<CustomerProfileView>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference customersDB = FirebaseDatabase.instance.ref(
    'Customers',
  );
  StreamSubscription<DatabaseEvent>? customersSub;
  ProviderServiceModel? customers;
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  File? pickedImage;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _blue = Color(0xFFEDD49A);
  static const _blue2 = Color(0xFF1A8A84);
  static const _kDark = Color(0xFF0C0810);
  static const _kAccent = Color(0xFF7EDBD5);
  static const _kDark2 = Color(0xFF160F1A);

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _listenToClient();
  }

  @override
  void dispose() {
    customersSub?.cancel();
    _fadeCtrl.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _listenToClient() {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;
    customersSub = customersDB.child(uid).onValue.listen((event) {
      if (event.snapshot.exists && mounted) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          customers = ProviderServiceModel.fromMap(data);
          firstNameController.text = customers!.firstName;
          lastNameController.text = customers!.lastName;
          emailController.text = customers!.email;
          phoneController.text = customers!.phoneNumber;
          addressController.text = customers!.address;
          isLoading = false;
        });
        _fadeCtrl.forward(from: 0);
      }
    });
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => pickedImage = File(picked.path));
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      await customersDB.child(auth.currentUser!.uid).update({
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'address': addressController.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context);
      _showSnack('تم تحديث الملف الشخصي بنجاح', Colors.green);
    } catch (_) {
      _showSnack('حدث خطأ أثناء التحديث', Colors.redAccent);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> updateLocation() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _showSnack('فعّل خدمة الموقع أولاً', Colors.redAccent);
        return;
      }
      LocationPermission p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
        if (p == LocationPermission.denied) return;
      }
      if (p == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await customersDB.child(customers!.uid).update({
        'latitude': pos.latitude,
        'longitude': pos.longitude,
      });
      setState(
        () => customers = customers!.copyWith(
          latitude: pos.latitude,
          longitude: pos.longitude,
        ),
      );
      _showSnack('تم تحديث الموقع بنجاح', Colors.green);
    } catch (e) {
      _showSnack('فشل تحديث الموقع: $e', Colors.redAccent);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

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
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const Positioned(
            top: -50,
            right: -50,
            child: _Glow(size: 200, color: _blue),
          ),
          const Positioned(
            bottom: -80,
            left: -50,
            child: _Glow(size: 180, color: _kAccent),
          ),

          SafeArea(
            child: isLoading
                ? const Center(child: CustomCircularProgressIndicator())
                : customers == null
                ? const Center(
                    child: Text(
                      'لا توجد بيانات',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                _InfoCard(
                                  children: [
                                    _InfoRow(
                                      icon: Icons.email_outlined,
                                      label: 'البريد',
                                      value: customers!.email,
                                      color: _blue2,
                                    ),
                                    _Divider(),
                                    _InfoRow(
                                      icon: Icons.phone_outlined,
                                      label: 'الهاتف',
                                      value: customers!.phoneNumber,
                                      color: _blue2,
                                    ),
                                    _Divider(),
                                    _InfoRow(
                                      icon: Icons.location_on_outlined,
                                      label: 'العنوان',
                                      value: customers!.address,
                                      color: _blue2,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                _ActionBtn(
                                  icon: Icons.my_location_rounded,
                                  label: 'تحديث الموقع الحالي',
                                  color: _blue,
                                  onTap: updateLocation,
                                ),
                                const SizedBox(height: 10),
                                _ActionBtn(
                                  icon: Icons.edit_rounded,
                                  label: 'تعديل الملف الشخصي',
                                  color: _blue2,
                                  onTap: () => showDialog(
                                    context: context,
                                    builder: (_) => _editProfileDialog(),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _ActionBtn(
                                  icon: Icons.logout_rounded,
                                  label: 'تسجيل الخروج',
                                  color: Colors.redAccent,
                                  onTap: _confirmLogout,
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(0, 20, 0, 28),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [_kDark2.withValues(alpha: .5), _kAccent.withValues(alpha: .3)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      border: Border(
        bottom: BorderSide(color: Colors.white.withValues(alpha: .06)),
      ),
    ),
    child: Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _blue2.withValues(alpha: .6),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(color: _blue.withValues(alpha: .4), blurRadius: 20),
                ],
              ),
              child: ClipOval(
                child: pickedImage != null
                    ? Image.file(pickedImage!, fit: BoxFit.cover)
                    : customers!.profileImage.isNotEmpty
                    ? Image.network(customers!.profileImage, fit: BoxFit.cover)
                    : Container(
                        color: Colors.white12,
                        child: const Icon(
                          Icons.person_rounded,
                          size: 46,
                          color: Colors.white38,
                        ),
                      ),
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: GestureDetector(
                onTap: pickImage,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _blue2,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0D1B2A),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          '${customers!.firstName} ${customers!.lastName}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          customers!.email,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .5),
            fontSize: 13,
          ),
        ),
      ],
    ),
  );

  Widget _editProfileDialog() => Dialog(
    backgroundColor: _kDark2,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: Colors.white.withValues(alpha: .15)),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: _blue2,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'تعديل الملف الشخصي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _DarkField(
                    ctrl: firstNameController,
                    label: 'الاسم الأول',
                    icon: Icons.person_outline_rounded,
                    accent: _blue2,
                  ),
                  const SizedBox(height: 10),
                  _DarkField(
                    ctrl: lastNameController,
                    label: 'اسم العائلة',
                    icon: Icons.person_outline_rounded,
                    accent: _blue2,
                  ),
                  const SizedBox(height: 10),
                  _DarkField(
                    ctrl: emailController,
                    label: 'البريد الإلكتروني',
                    icon: Icons.email_outlined,
                    accent: _blue2,
                    keyboard: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  _DarkField(
                    ctrl: phoneController,
                    label: 'رقم الهاتف',
                    icon: Icons.phone_outlined,
                    accent: _blue2,
                    keyboard: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  _DarkField(
                    ctrl: addressController,
                    label: 'العنوان',
                    icon: Icons.location_on_outlined,
                    accent: _blue2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .15),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: updateProfile,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(colors: [_blue, _blue2]),
                        boxShadow: [
                          BoxShadow(
                            color: _blue.withValues(alpha: .4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'حفظ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
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

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: _kDark2,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: .15)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'هل تريد تسجيل الخروج؟',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .55),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .12),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'إلغاء',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.redAccent,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withValues(alpha: .4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'تسجيل الخروج',
                            style: TextStyle(
                              color: Colors.white,
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
    if (ok == true) {
      await auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        GoRouter.of(context).pushReplacement(AppRouter.kServicesSelectionView);
      }
    }
  }
}

// ─── Shared Widgets ───
class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: .08)),
    ),
    child: Column(children: children),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Text(
          '$label:  ',
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Divider(color: Colors.white.withValues(alpha: .07), height: 1);
}

class _ActionBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _s = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _c.forward(),
    onTapUp: (_) {
      _c.reverse();
      widget.onTap();
    },
    onTapCancel: () => _c.reverse(),
    child: ScaleTransition(
      scale: _s,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: widget.color.withValues(alpha: .12),
          border: Border.all(
            color: widget.color.withValues(alpha: .3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: widget.color, size: 18),
            const SizedBox(width: 10),
            Text(
              widget.label,
              style: TextStyle(
                color: widget.color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DarkField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final Color accent;
  final TextInputType keyboard;
  const _DarkField({
    required this.ctrl,
    required this.label,
    required this.icon,
    required this.accent,
    this.keyboard = TextInputType.text,
  });
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl,
    keyboardType: keyboard,
    style: const TextStyle(color: Colors.white, fontSize: 14),
    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white.withValues(alpha: .45),
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: Colors.white38, size: 18),
      filled: true,
      fillColor: Colors.white.withValues(alpha: .07),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accent.withValues(alpha: .7), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    ),
  );
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  const _Glow({required this.size, required this.color});
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

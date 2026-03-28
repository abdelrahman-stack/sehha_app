import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sehha_app/auth/map_picker_view.dart';
import 'package:sehha_app/core/services/shared_prefs.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

const _kPink = Color(0xFFAD1457);
const _kPink2 = Color(0xFF880E4F);
const _kAccent = Color(0xFFE91E8C);
const _kDark = Color(0xFF0C0810);
const _kDark2 = Color(0xFF160F1A);
const _kSurface = Color(0xFF1C1020);

class BeautyCenterSignup extends StatefulWidget {
  const BeautyCenterSignup({super.key});
  @override
  State<BeautyCenterSignup> createState() => _BeautyCenterSignupState();
}

class _BeautyCenterSignupState extends State<BeautyCenterSignup>
    with SingleTickerProviderStateMixin {
  final auth = FirebaseAuth.instance;
  final ref = FirebaseDatabase.instance.ref();
  final supabase = supa.Supabase.instance.client;
  final formKey = GlobalKey<FormState>();

  String userType = 'Customers';
  String email = '';
  String password = '';
  String phoneNumber = '';
  String firstName = '';
  String lastName = '';
  String address = '';
  String profileImage = '';
  double latitude = 0.0;
  double longitude = 0.0;

  final picker = ImagePicker();
  XFile? imageFile;
  final location = Location();
  bool isLoading = false;
  bool isPasswordVisible = false;
  List<Map<String, String>> services = [];

  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
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
              const Positioned(top: -80, right: -70, child: _Glow(250, _kPink, .07)),
              const Positioned(
                bottom: -60,
                left: -50,
                child: _Glow(200, _kAccent, .05),
              ),
              Positioned.fill(child: CustomPaint(painter: _DotGrid(_kAccent))),

              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 10, 20, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
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
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'إنشاء حساب',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    Expanded(
                      child: FadeTransition(
                        opacity: _fade,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  ResponsiveBreakpoints.of(context).isMobile
                                  ? double.infinity
                                  : 520,
                            ),
                            child: Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: imageUpload,
                                    child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        Container(
                                          width: 90,
                                          height: 90,
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
                                                alpha: .4,
                                              ),
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _kAccent.withValues(
                                                  alpha: .3,
                                                ),
                                                blurRadius: 20,
                                              ),
                                            ],
                                          ),
                                          child: imageFile != null
                                              ? ClipOval(
                                                  child: Image.file(
                                                    File(imageFile!.path),
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.person_rounded,
                                                  color: Colors.white38,
                                                  size: 38,
                                                ),
                                        ),
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [_kAccent, _kPink2],
                                            ),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: _kDark,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _kAccent.withValues(
                                                  alpha: .5,
                                                ),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_rounded,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: .05,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: .06,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        _TypeTab(
                                          label: 'عميلة',
                                          icon: Icons.person_rounded,
                                          active: userType == 'Customers',
                                          onTap: () => setState(
                                            () => userType = 'Customers',
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        _TypeTab(
                                          label: 'مركز التجميل',
                                          icon: Icons.store_rounded,
                                          active: userType == 'BeautyCenter',
                                          onTap: () => setState(
                                            () => userType = 'BeautyCenter',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  _fieldCard([
                                    _F(
                                      label: 'البريد الإلكتروني',
                                      icon: Icons.email_outlined,
                                      keyboard: TextInputType.emailAddress,
                                      onChanged: (v) => email = v,
                                    ),
                                    const SizedBox(height: 12),
                                    _F(
                                      label: 'كلمة المرور',
                                      icon: Icons.lock_outline_rounded,
                                      onChanged: (v) => password = v,
                                      obscure: !isPasswordVisible,
                                      suffix: GestureDetector(
                                        onTap: () => setState(
                                          () => isPasswordVisible =
                                              !isPasswordVisible,
                                        ),
                                        child: Icon(
                                          isPasswordVisible
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: Colors.white30,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _F(
                                      label: 'رقم الهاتف',
                                      icon: Icons.phone_outlined,
                                      keyboard: TextInputType.phone,
                                      onChanged: (v) => phoneNumber = v,
                                    ),
                                  ]),
                                  const SizedBox(height: 12),

                                  _fieldCard([
                                    _F(
                                      label: userType == 'BeautyCenter'
                                          ? 'اسم مركز التجميل'
                                          : 'الاسم الأول',
                                      icon: userType == 'BeautyCenter'
                                          ? Icons.store_outlined
                                          : Icons.person_outline_rounded,
                                      onChanged: (v) => firstName = v,
                                    ),
                                    const SizedBox(height: 12),
                                    _F(
                                      label: userType == 'BeautyCenter'
                                          ? 'اسم المالك'
                                          : 'الاسم الأخير',
                                      icon: Icons.person_outline_rounded,
                                      onChanged: (v) => lastName = v,
                                    ),
                                    const SizedBox(height: 12),
                                    _F(
                                      label: 'العنوان',
                                      icon: Icons.location_on_outlined,
                                      onChanged: (v) => address = v,
                                    ),
                                  ]),
                                  const SizedBox(height: 12),

                                  if (userType == 'BeautyCenter') ...[
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: _kSurface.withValues(alpha: .7),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: .07,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'الخدمات والأسعار',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: .8),
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => setState(
                                                  () => services.add({
                                                    'name': '',
                                                    'price': '',
                                                  }),
                                                ),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 5,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: _kAccent.withValues(
                                                      alpha: .12,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    border: Border.all(
                                                      color: _kAccent
                                                          .withValues(
                                                            alpha: .3,
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.add_rounded,
                                                        color: _kAccent,
                                                        size: 14,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'إضافة',
                                                        style: TextStyle(
                                                          color: _kAccent,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (services.isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            ...List.generate(
                                              services.length,
                                              (i) => Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 10,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: _SvcField(
                                                        hint: 'اسم الخدمة',
                                                        init:
                                                            services[i]['name'],
                                                        onChanged: (v) =>
                                                            services[i]['name'] =
                                                                v,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    SizedBox(
                                                      width: 90,
                                                      child: _SvcField(
                                                        hint: 'السعر',
                                                        init:
                                                            services[i]['price'],
                                                        keyboard: TextInputType
                                                            .number,
                                                        onChanged: (v) =>
                                                            services[i]['price'] =
                                                                v,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    GestureDetector(
                                                      onTap: () => setState(
                                                        () => services.removeAt(
                                                          i,
                                                        ),
                                                      ),
                                                      child: Container(
                                                        width: 34,
                                                        height: 34,
                                                        decoration: BoxDecoration(
                                                          color: Colors
                                                              .redAccent
                                                              .withValues(
                                                                alpha: .1,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          border: Border.all(
                                                            color: Colors
                                                                .redAccent
                                                                .withValues(
                                                                  alpha: .3,
                                                                ),
                                                          ),
                                                        ),
                                                        child: const Icon(
                                                          Icons
                                                              .delete_outline_rounded,
                                                          color:
                                                              Colors.redAccent,
                                                          size: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],

                                  GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const MapPickerScreen(),
                                        ),
                                      );
                                      if (result != null) {
                                        setState(() {
                                          latitude = result.latitude;
                                          longitude = result.longitude;
                                        });
                                      }
                                    },
                                    child: Container(
                                      height: 52,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: .06,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: latitude != 0
                                              ? _kAccent.withValues(alpha: .5)
                                              : Colors.white.withValues(
                                                  alpha: .09,
                                                ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_on_rounded,
                                            color: latitude != 0
                                                ? _kAccent
                                                : Colors.white38,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            latitude != 0
                                                ? 'تم تحديد الموقع ✓'
                                                : 'اختر موقعك على الخريطة',
                                            style: TextStyle(
                                              color: latitude != 0
                                                  ? _kAccent
                                                  : Colors.white38,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  GestureDetector(
                                    onTap: isLoading ? null : register,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 220,
                                      ),
                                      height: 56,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isLoading
                                              ? [Colors.white10, Colors.white10]
                                              : [_kAccent, _kPink2],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: isLoading
                                            ? []
                                            : [
                                                BoxShadow(
                                                  color: _kAccent.withValues(
                                                    alpha: .5,
                                                  ),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                      ),
                                      child: Center(
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.5,
                                                    ),
                                              )
                                            : const Text(
                                                'إنشاء الحساب',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 16,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldCard(List<Widget> children) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _kSurface.withValues(alpha: .7),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: .07)),
    ),
    child: Column(children: children),
  );

  Future<void> saveFCMToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    if (token != null) {
      await FirebaseDatabase.instance.ref('users/$uid/fcmToken').set(token);
    }
  }

  Future<void> imageUpload() async {
    final f = await picker.pickImage(source: ImageSource.gallery);
    if (f != null) setState(() => imageFile = f);
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      final cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user != null) {
        if (imageFile != null) {
          profileImage = await _uploadImage(imageFile!) ?? '';
        }
        final path = userType == 'BeautyCenter' ? 'BeautyCenter' : 'Customers';
        await ref.child(path).child(user.uid).set({
          'uid': user.uid,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
          'firstName': firstName,
          'lastName': lastName,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'profileImage': profileImage,
          if (userType == 'BeautyCenter') 'services': services,
        });
        await saveUserLoginState(user.uid, userType);
        if (mounted) {
          GoRouter.of(context).pushReplacement(
            userType == 'BeautyCenter'
                ? AppRouter.kBeautyCenterView
                : AppRouter.kCustomerView,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل التسجيل: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
    if (mounted) setState(() => isLoading = false);
  }

  Future<String?> _uploadImage(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final response = await supabase.storage
          .from('curly_images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const supa.FileOptions(contentType: 'image/jpeg'),
          );
      if (response.isNotEmpty) {
        return supabase.storage.from('curly_images').getPublicUrl(fileName);
      }
    } catch (_) {}
    return null;
  }
}

// ── تاب نوع المستخدم ──
class _TypeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _TypeTab({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 44,
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: [_kAccent, _kPink2])
              : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _kAccent.withValues(alpha: .4),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? Colors.white : Colors.white38, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.white38,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _F extends StatelessWidget {
  final String label;
  final IconData icon;
  final Function(String) onChanged;
  final TextInputType keyboard;
  final bool obscure;
  final Widget? suffix;
  const _F({
    required this.label,
    required this.icon,
    required this.onChanged,
    this.keyboard = TextInputType.text,
    this.obscure = false,
    this.suffix,
  });
  @override
  Widget build(BuildContext context) => TextFormField(
    keyboardType: keyboard,
    onChanged: onChanged,
    obscureText: obscure,
    style: const TextStyle(color: Colors.white, fontSize: 14),
    cursorColor: _kAccent,
    validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white.withValues(alpha: .35),
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: Colors.white24, size: 18),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: .06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: _kAccent.withValues(alpha: .6),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF5350)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF5350), width: 1.5),
      ),
    ),
  );
}

class _SvcField extends StatelessWidget {
  final String hint;
  final String? init;
  final Function(String) onChanged;
  final TextInputType keyboard;
  const _SvcField({
    required this.hint,
    required this.onChanged,
    this.init,
    this.keyboard = TextInputType.text,
  });
  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: init,
    keyboardType: keyboard,
    onChanged: onChanged,
    style: const TextStyle(color: Colors.white, fontSize: 13),
    cursorColor: _kAccent,
    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: .25),
        fontSize: 12,
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: .05),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .07)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .07)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _kAccent.withValues(alpha: .5)),
      ),
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

class _DotGrid extends CustomPainter {
  final Color c;
  _DotGrid(this.c);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = c.withValues(alpha: .016)
      ..style = PaintingStyle.fill;
    for (double x = 20; x < s.width; x += 28)
      for (double y = 20; y < s.height; y += 28) {
        canvas.drawCircle(Offset(x, y), 1.4, p);
      }
  }

  @override
  bool shouldRepaint(_) => false;
}

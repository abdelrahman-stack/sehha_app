import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sehha_app/auth/map_picker_view.dart';
import 'package:sehha_app/core/services/shared_prefs.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class FemaleSignUpView extends StatefulWidget {
  const FemaleSignUpView({super.key});
  @override
  State<FemaleSignUpView> createState() => _FemaleSignUpViewState();
}

class _FemaleSignUpViewState extends State<FemaleSignUpView>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  final supabase = supa.Supabase.instance.client;
  final formKey = GlobalKey<FormState>();

  String userType = 'ClientFemale';
  String email = '', password = '', phoneNumber = '';
  String firstName = '', lastName = '', address = '', profileImage = '';
  double latitude = 0.0, longitude = 0.0;

  final ImagePicker picker = ImagePicker();
  XFile? imageFile;
  final Location location = Location();
  bool isLoading = false, isPasswordVisible = false;
  List<Map<String, String>> services = [];

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _primary = Color(0xFF880E4F);
  static const _accent = Color(0xFFE91E8C);

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

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A0A10), Color(0xFF3D1A2A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const Positioned(
            top: -40,
            right: -40,
            child: _GlowCircle(size: 180, color: _primary),
          ),
          const Positioned(
            bottom: -60,
            left: -40,
            child: _GlowCircle(size: 160, color: Color(0xFF880E4F)),
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
                          'إنشاء حساب',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
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
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: ResponsiveBreakpoints.of(context).isMobile
                                ? double.infinity
                                : 520,
                          ),
                          child: Form(
                            key: formKey,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                16,
                                24,
                                32,
                              ),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: imageUpload,
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withValues(
                                              alpha: .1,
                                            ),
                                            border: Border.all(
                                              color: _accent.withValues(
                                                alpha: .5,
                                              ),
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _accent.withValues(
                                                  alpha: .3,
                                                ),
                                                blurRadius: 16,
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
                                                  size: 48,
                                                  color: Colors.white54,
                                                ),
                                        ),
                                        Positioned(
                                          bottom: 2,
                                          right: 2,
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _accent,
                                              border: Border.all(
                                                color: const Color(0xFF1A0A10),
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
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: .06,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: .1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        _TypeTab(
                                          label: 'عميلة',
                                          value: 'ClientFemale',
                                          selected: userType == 'ClientFemale',
                                          primary: _primary,
                                          accent: _accent,
                                          onTap: () => setState(
                                            () => userType = 'ClientFemale',
                                          ),
                                        ),
                                        _TypeTab(
                                          label: 'كوافير حريمي',
                                          value: 'Hairdresser',
                                          selected: userType == 'Hairdresser',
                                          primary: _primary,
                                          accent: _accent,
                                          onTap: () => setState(
                                            () => userType = 'Hairdresser',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  _DarkTextField(
                                    label: 'البريد الإلكتروني',
                                    icon: Icons.email_outlined,
                                    accentColor: _accent,
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (v) => email = v,
                                    validator: (v) =>
                                        v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                                  ),
                                  const SizedBox(height: 12),
                                  _DarkTextField(
                                    label: 'كلمة المرور',
                                    icon: Icons.lock_outline_rounded,
                                    accentColor: _accent,
                                    obscureText: !isPasswordVisible,
                                    onChanged: (v) => password = v,
                                    validator: (v) =>
                                        v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        isPasswordVisible
                                            ? Icons.visibility_rounded
                                            : Icons.visibility_off_rounded,
                                        color: Colors.white54,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(
                                        () => isPasswordVisible =
                                            !isPasswordVisible,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _DarkTextField(
                                    label: 'رقم الهاتف',
                                    icon: Icons.phone_outlined,
                                    accentColor: _accent,
                                    keyboardType: TextInputType.phone,
                                    onChanged: (v) => phoneNumber = v,
                                    validator: (v) =>
                                        v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                                  ),
                                  const SizedBox(height: 12),

                                  if (userType == 'ClientFemale') ...[
                                    _DarkTextField(
                                      label: 'الاسم الأول',
                                      icon: Icons.person_outline_rounded,
                                      accentColor: _accent,
                                      onChanged: (v) => firstName = v,
                                      validator: (v) =>
                                          v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                                    ),
                                    const SizedBox(height: 12),
                                    _DarkTextField(
                                      label: 'الاسم الأخير',
                                      icon: Icons.person_outline_rounded,
                                      accentColor: _accent,
                                      onChanged: (v) => lastName = v,
                                      validator: (v) =>
                                          v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                                    ),
                                  ] else ...[
                                    _DarkTextField(
                                      label: 'اسم المحل',
                                      icon: Icons.store_outlined,
                                      accentColor: _accent,
                                      onChanged: (v) => firstName = v,
                                      validator: (v) =>
                                          v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                                    ),
                                    const SizedBox(height: 12),
                                    _DarkTextField(
                                      label: 'اسم المالك',
                                      icon: Icons.person_outline_rounded,
                                      accentColor: _accent,
                                      onChanged: (v) => lastName = v,
                                      validator: (v) =>
                                          v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  _DarkTextField(
                                    label: 'العنوان',
                                    icon: Icons.location_on_outlined,
                                    accentColor: _accent,
                                    onChanged: (v) => address = v,
                                    validator: (v) =>
                                        v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                                  ),

                                  if (userType == 'Hairdresser') ...[
                                    const SizedBox(height: 20),
                                    const _SectionTitle(
                                      title: 'أسعار الخدمات',
                                      icon: Icons.attach_money_rounded,
                                      color: _accent,
                                    ),
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
                                              child: _DarkTextField(
                                                label: 'اسم الخدمة',
                                                icon: Icons.cut_rounded,
                                                accentColor: _accent,
                                                initialValue:
                                                    services[i]['name'],
                                                onChanged: (v) =>
                                                    services[i]['name'] = v,
                                                validator: (v) =>
                                                    v!.isEmpty ? 'مطلوب' : null,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            SizedBox(
                                              width: 95,
                                              child: _DarkTextField(
                                                label: 'السعر',
                                                icon: Icons.money,
                                                accentColor: _accent,
                                                initialValue:
                                                    services[i]['price'],
                                                keyboardType:
                                                    TextInputType.number,
                                                onChanged: (v) =>
                                                    services[i]['price'] = v,
                                                validator: (v) =>
                                                    v!.isEmpty ? 'مطلوب' : null,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red.withValues(
                                                  alpha: .15,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline_rounded,
                                                  color: Colors.redAccent,
                                                  size: 20,
                                                ),
                                                onPressed: () => setState(
                                                  () => services.removeAt(i),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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
                                        width: double.infinity,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          color: Colors.white.withValues(
                                            alpha: .06,
                                          ),
                                          border: Border.all(
                                            color: _accent.withValues(
                                              alpha: .4,
                                            ),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_circle_outline_rounded,
                                              color: _accent,
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'إضافة خدمة جديدة',
                                              style: TextStyle(
                                                color: _accent,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 20),

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
                                      height: 54,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: _primary.withValues(alpha: .2),
                                        border: Border.all(
                                          color: _primary.withValues(alpha: .5),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            latitude != 0
                                                ? Icons.location_on_rounded
                                                : Icons
                                                      .location_searching_rounded,
                                            color: latitude != 0
                                                ? Colors.greenAccent
                                                : Colors.white70,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            latitude != 0
                                                ? 'تم تحديد الموقع ✓'
                                                : 'اختر موقعك على الخريطة',
                                            style: TextStyle(
                                              color: latitude != 0
                                                  ? Colors.greenAccent
                                                  : Colors.white70,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  _GradientButton(
                                    label: 'إنشاء الحساب',
                                    isLoading: isLoading,
                                    primary: _primary,
                                    accent: _accent,
                                    onTap: isLoading ? null : register,
                                  ),
                                ],
                              ),
                            ),
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
    );
  }

  Future<void> imageUpload() async {
    final f = await picker.pickImage(source: ImageSource.gallery);
    setState(() => imageFile = f);
  }

  Future<void> saveFCMToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    if (token != null) {
      await FirebaseDatabase.instance.ref('users/$uid/fcmToken').set(token);
    }
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
          profileImage = await uploadImageToSupabase(imageFile!) ?? '';
        }
        final userPath = userType == 'Hairdresser'
            ? 'Hairdressers'
            : 'ClientFemales';
        await ref.child(userPath).child(user.uid).set({
          'uid': user.uid,
          'email': email,
          'phoneNumber': phoneNumber,
          'firstName': firstName,
          'lastName': lastName,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'profileImage': profileImage,
          if (userType == 'Hairdresser') 'services': services,
        });
        await saveUserLoginState(user.uid, userType);
        await saveFCMToken();
        GoRouter.of(context).pushReplacement(
          userType == 'Hairdresser'
              ? AppRouter.kHairdresserView
              : AppRouter.kFemaleCustomerView,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    }
    setState(() => isLoading = false);
  }

  Future<String?> uploadImageToSupabase(XFile image) async {
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

// ─── shared widgets ───
class _TypeTab extends StatelessWidget {
  final String label, value;
  final bool selected;
  final Color primary, accent;
  final VoidCallback onTap;
  const _TypeTab({
    required this.label,
    required this.value,
    required this.selected,
    required this.primary,
    required this.accent,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: selected ? LinearGradient(colors: [primary, accent]) : null,
          color: selected ? null : Colors.transparent,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: .4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white54,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _SectionTitle({
    required this.title,
    required this.icon,
    required this.color,
  });
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      const Expanded(child: SizedBox()),
      Container(
        height: 1,
        width: 60,
        color: Colors.white.withValues(alpha: .1),
      ),
    ],
  );
}

class _DarkTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool obscureText;
  final TextInputType keyboardType;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final String? initialValue;
  const _DarkTextField({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.onChanged,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.initialValue,
  });
  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: initialValue,
    obscureText: obscureText,
    keyboardType: keyboardType,
    onChanged: onChanged,
    validator: validator,
    style: const TextStyle(color: Colors.white, fontSize: 15),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white.withValues(alpha: .5),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: Colors.white38, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: .07),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: accentColor.withValues(alpha: .7),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
    ),
  );
}

class _GradientButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final Color primary, accent;
  final VoidCallback? onTap;
  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.primary,
    required this.accent,
    this.onTap,
  });
  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
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
    onTapDown: widget.onTap != null ? (_) => _c.forward() : null,
    onTapUp: widget.onTap != null
        ? (_) {
            _c.reverse();
            widget.onTap!();
          }
        : null,
    onTapCancel: () => _c.reverse(),
    child: ScaleTransition(
      scale: _s,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: widget.onTap != null
              ? LinearGradient(
                  colors: [widget.primary, widget.accent],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                )
              : null,
          color: widget.onTap == null ? Colors.white12 : null,
          boxShadow: widget.onTap != null
              ? [
                  BoxShadow(
                    color: widget.primary.withValues(alpha: .45),
                    blurRadius: 16,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: widget.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
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

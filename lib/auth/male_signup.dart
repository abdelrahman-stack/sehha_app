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
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:sehha_app/core/utils/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class MaleSignUpView extends StatefulWidget {
  const MaleSignUpView({super.key});
  @override State<MaleSignUpView> createState() => _MaleSignUpViewState();
}

class _MaleSignUpViewState extends State<MaleSignUpView>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  final supabase = supa.Supabase.instance.client;
  final formKey = GlobalKey<FormState>();

  String userType = 'Client';
  String email = '', password = '', phoneNumber = '';
  String firstName = '', lastName = '', address = '', profileImage = '';
  double latitude = 0.0, longitude = 0.0;

  final ImagePicker picker = ImagePicker();
  XFile? imageFile;
  final Location location = Location();
  bool isLoading = false;
  bool isPasswordVisible = false;
  List<Map<String, String>> services = [];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override void dispose() { _fadeController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D1B2A), Color(0xFF1B3A5C)],
                begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
          ),
          const Positioned(top: -40, right: -40,
            child: _GlowCircle(size: 180, color: AppColors.secondaryColor)),
          const Positioned(bottom: -60, left: -40,
            child: _GlowCircle(size: 160, color: Color(0xFF0D47A1))),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text('إنشاء حساب',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
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
                                ? double.infinity : 520),
                          child: Form(
                            key: formKey,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: imageUpload,
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 100, height: 100,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withValues(alpha: .1),
                                            border: Border.all(
                                              color: AppColors.secondaryColor.withValues(alpha: .5), width: 2),
                                            boxShadow: [BoxShadow(
                                              color: AppColors.secondaryColor.withValues(alpha: .3),
                                              blurRadius: 16)],
                                          ),
                                          child: imageFile != null
                                              ? ClipOval(child: Image.file(File(imageFile!.path), fit: BoxFit.cover))
                                              : const Icon(Icons.person_rounded, size: 48, color: Colors.white54),
                                        ),
                                        Positioned(
                                          bottom: 2, right: 2,
                                          child: Container(
                                            width: 30, height: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.accentColor,
                                              border: Border.all(color: const Color(0xFF0D1B2A), width: 2)),
                                            child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: .06),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.white.withValues(alpha: .1)),
                                    ),
                                    child: Row(
                                      children: [
                                        _UserTypeTab(label: 'عميل', value: 'Client',
                                          selected: userType == 'Client',
                                          onTap: () => setState(() => userType = 'Client')),
                                        _UserTypeTab(label: 'مصفف شعر', value: 'Barber',
                                          selected: userType == 'Barber',
                                          onTap: () => setState(() => userType = 'Barber')),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  _DarkTextField(
                                    label: local.translate('email'),
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (v) => email = v,
                                    validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                                  ),
                                  const SizedBox(height: 12),
                                  _DarkTextField(
                                    label: local.translate('password'),
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: !isPasswordVisible,
                                    onChanged: (v) => password = v,
                                    validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                        color: Colors.white54, size: 20),
                                      onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _DarkTextField(
                                    label: local.translate('phone_number'),
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    onChanged: (v) => phoneNumber = v,
                                    validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                                  ),
                                  const SizedBox(height: 12),

                                  if (userType == 'Client') ...[
                                    _DarkTextField(
                                      label: local.translate('first_name'),
                                      icon: Icons.person_outline_rounded,
                                      onChanged: (v) => firstName = v,
                                      validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                                    ),
                                    const SizedBox(height: 12),
                                    _DarkTextField(
                                      label: local.translate('last_name'),
                                      icon: Icons.person_outline_rounded,
                                      onChanged: (v) => lastName = v,
                                      validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                                    ),
                                  ] else ...[
                                    _DarkTextField(
                                      label: local.translate('shop_name'),
                                      icon: Icons.store_outlined,
                                      onChanged: (v) => firstName = v,
                                      validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                                    ),
                                    const SizedBox(height: 12),
                                    _DarkTextField(
                                      label: local.translate('owner_name'),
                                      icon: Icons.person_outline_rounded,
                                      onChanged: (v) => lastName = v,
                                      validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                                    ),
                                  ],

                                  const SizedBox(height: 12),
                                  _DarkTextField(
                                    label: local.translate('address'),
                                    icon: Icons.location_on_outlined,
                                    onChanged: (v) => address = v,
                                    validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
                                  ),

                                  if (userType == 'Barber') ...[
                                    const SizedBox(height: 20),
                                    const _SectionTitle(title: 'أسعار الخدمات', icon: Icons.attach_money_rounded),
                                    const SizedBox(height: 12),
                                    ...List.generate(services.length, (i) => Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _DarkTextField(
                                              label: 'اسم الخدمة',
                                              icon: Icons.cut_rounded,
                                              initialValue: services[i]['name'],
                                              onChanged: (v) => services[i]['name'] = v,
                                              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          SizedBox(
                                            width: 95,
                                            child: _DarkTextField(
                                              label: 'السعر',
                                              icon: Icons.money,
                                              initialValue: services[i]['price'],
                                              keyboardType: TextInputType.number,
                                              onChanged: (v) => services[i]['price'] = v,
                                              validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.red.withValues(alpha: .15),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: IconButton(
                                              icon: const Icon(Icons.delete_outline_rounded,
                                                color: Colors.redAccent, size: 20),
                                              onPressed: () => setState(() => services.removeAt(i)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                    GestureDetector(
                                      onTap: () => setState(() => services.add({'name': '', 'price': ''})),
                                      child: Container(
                                        width: double.infinity, height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(14),
                                          color: Colors.white.withValues(alpha: .06),
                                          border: Border.all(
                                            color: AppColors.accentColor.withValues(alpha: .4),
                                            width: 1.5, style: BorderStyle.solid),
                                        ),
                                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                          Icon(Icons.add_circle_outline_rounded,
                                            color: AppColors.accentColor, size: 20),
                                          SizedBox(width: 8),
                                          Text('إضافة خدمة جديدة',
                                            style: TextStyle(color: AppColors.accentColor,
                                              fontWeight: FontWeight.w600)),
                                        ]),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 20),

                                  GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.push(context,
                                        MaterialPageRoute(builder: (_) => const MapPickerScreen()));
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
                                        color: AppColors.secondaryColor.withValues(alpha: .2),
                                        border: Border.all(
                                          color: AppColors.secondaryColor.withValues(alpha: .5), width: 1.5),
                                      ),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                        Icon(latitude != 0 ? Icons.location_on_rounded : Icons.location_searching_rounded,
                                          color: latitude != 0 ? Colors.greenAccent : Colors.white70, size: 20),
                                        const SizedBox(width: 10),
                                        Text(
                                          latitude != 0 ? 'تم تحديد الموقع ✓' : 'اختر موقعك على الخريطة',
                                          style: TextStyle(
                                            color: latitude != 0 ? Colors.greenAccent : Colors.white70,
                                            fontWeight: FontWeight.w600, fontSize: 15)),
                                      ]),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  _GradientButton(
                                    label: 'إنشاء الحساب',
                                    isLoading: isLoading,
                                    primaryColor: AppColors.primaryColor,
                                    accentColor: AppColors.secondaryColor,
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
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() => imageFile = pickedFile);
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
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        if (imageFile != null) profileImage = await uploadImageToSupabase(imageFile!) ?? '';
        final userPath = userType == 'Barber' ? 'Barbers' : 'Clients';
        await ref.child(userPath).child(user.uid).set({
          'uid': user.uid, 'email': email, 'phoneNumber': phoneNumber,
          'firstName': firstName, 'lastName': lastName, 'address': address,
          'latitude': latitude, 'longitude': longitude, 'profileImage': profileImage,
          if (userType == 'Barber') 'services': services,
        });
        await saveUserLoginState(user.uid, userType);
        await saveFCMToken();
        GoRouter.of(context).pushReplacement(
          userType == 'Barber' ? AppRouter.kBarberView : AppRouter.kMaleCustomerView);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')));
    }
    setState(() => isLoading = false);
  }

  Future<String?> uploadImageToSupabase(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final response = await supabase.storage.from('curly_images').uploadBinary(
        fileName, bytes,
        fileOptions: const supa.FileOptions(contentType: 'image/jpeg'));
      if (response.isNotEmpty) {
        return supabase.storage.from('curly_images').getPublicUrl(fileName);
      }
    } catch (e) {}
    return null;
  }
}

class _UserTypeTab extends StatelessWidget {
  final String label, value;
  final bool selected;
  final VoidCallback onTap;
  const _UserTypeTab({required this.label, required this.value,
    required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: selected ? const LinearGradient(
            colors: [AppColors.primaryColor, AppColors.secondaryColor]) : null,
          color: selected ? null : Colors.transparent,
          boxShadow: selected ? [BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: .4),
            blurRadius: 10, offset: const Offset(0, 3))] : [],
        ),
        child: Center(
          child: Text(label, style: TextStyle(
            color: selected ? Colors.white : Colors.white54,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14)),
        ),
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title; final IconData icon;
  const _SectionTitle({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: AppColors.accentColor, size: 18),
    const SizedBox(width: 8),
    Text(title, style: const TextStyle(color: Colors.white,
      fontWeight: FontWeight.w700, fontSize: 15)),
    const Expanded(child: SizedBox()),
    Container(height: 1, width: 60,
      color: Colors.white.withValues(alpha: .1)),
  ]);
}



class _DarkTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final String? initialValue;

  const _DarkTextField({
    required this.label,
    required this.icon,
    required this.onChanged,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: .5), fontSize: 14),
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
          borderSide: BorderSide(color: AppColors.accentColor.withValues(alpha: .7), width: 1.5),
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
}

class _GradientButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final Color primaryColor;
  final Color accentColor;
  final VoidCallback? onTap;
  const _GradientButton({required this.label, required this.isLoading,
    required this.primaryColor, required this.accentColor, this.onTap});
  @override State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _ctrl.forward() : null,
      onTapUp: widget.onTap != null ? (_) { _ctrl.reverse(); widget.onTap!(); } : null,
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity, height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: widget.onTap != null ? LinearGradient(
              colors: [widget.primaryColor, widget.accentColor],
              begin: Alignment.centerRight, end: Alignment.centerLeft) : null,
            color: widget.onTap == null ? Colors.white12 : null,
            boxShadow: widget.onTap != null ? [BoxShadow(
              color: widget.primaryColor.withValues(alpha: .45),
              blurRadius: 16, offset: const Offset(0, 5))] : [],
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(width: 24, height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Text(widget.label, style: const TextStyle(
                    color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size; final Color color;
  const _GlowCircle({required this.size, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: .12)),
  );
}
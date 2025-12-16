import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sehha_app/widgets/lottie_loading_Indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:sehha_app/core/utils/app_router.dart';
import 'package:sehha_app/models/doctor_model.dart';
import 'package:sehha_app/widgets/lang_button.dart';

class DoctorProfileView extends StatefulWidget {
  const DoctorProfileView({super.key});

  @override
  State<DoctorProfileView> createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference doctorDB = FirebaseDatabase.instance.ref('Doctors');
  final supabase = Supabase.instance.client;

  DoctorModel? doctor;
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController categoryController;
  late TextEditingController qualificationController;
  late TextEditingController yearsController;

  File? pickedImage;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    categoryController = TextEditingController();
    qualificationController = TextEditingController();
    yearsController = TextEditingController();

    fetchDoctorData();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    categoryController.dispose();
    qualificationController.dispose();
    yearsController.dispose();
    super.dispose();
  }

  Future<void> fetchDoctorData() async {
    setState(() => isLoading = true);
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) return setState(() => isLoading = false);

      final DatabaseEvent event = await doctorDB.child(currentUser.uid).once();
      final snapshot = event.snapshot;

      if (snapshot.value != null) {
        final map = Map<String, dynamic>.from(snapshot.value as Map);
        doctor = DoctorModel.fromMap(map);

        firstNameController.text = doctor!.firstName;
        lastNameController.text = doctor!.lastName;
        emailController.text = doctor!.email;
        phoneController.text = doctor!.phoneNumber;
        addressController.text = doctor!.address;
        categoryController.text = doctor!.category;
        qualificationController.text = doctor!.qualification;
        yearsController.text = doctor!.yearsOfExperience;
      }
    } catch (e) {
      debugPrint('Error fetching doctor data: $e');
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => pickedImage = File(picked.path));

      final fileName =
          'patient_${auth.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await supabase.storage
          .from('gallery_images')
          .upload(fileName, pickedImage!);

      final uploadedUrl = supabase.storage
          .from('gallery_images')
          .getPublicUrl(fileName);

      await doctorDB.child(auth.currentUser!.uid).update({
        'profileImage': uploadedUrl,
      });

      if (!mounted) return;
      await fetchDoctorData();
    }
  }

  Future<void> updateProfile() async {
    final local = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      String? uploadedUrl;

      if (pickedImage != null) {
        final fileName =
            'doctor_${auth.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage
            .from('gallery_images')
            .upload(fileName, pickedImage!);
        uploadedUrl = supabase.storage
            .from('gallery_images')
            .getPublicUrl(fileName);
      }

      final updatedData = {
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'category': categoryController.text.trim(),
        'qualification': qualificationController.text.trim(),
        'yearsOfExperience': yearsController.text.trim(),
      };
      if (uploadedUrl != null) updatedData['profileImage'] = uploadedUrl;

      await doctorDB.child(auth.currentUser!.uid).update(updatedData);

      await fetchDoctorData();

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(local.translate('profile_updated_successfully')),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(local.translate('error_updating_profile')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.translate('doctor_profile'),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.scondaryColor,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CustomCircularProgressIndicator())
          : doctor == null
          ? Center(child: Text(t.translate('doctor_data_not_found')))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile header
                  Container(
                    width: double.infinity,
                    color: AppColors.scondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: pickedImage != null
                                  ? FileImage(pickedImage!)
                                  : (doctor!.profileImage.isNotEmpty
                                            ? NetworkImage(
                                                '${doctor!.profileImage}?t=${DateTime.now().millisecondsSinceEpoch}',
                                              )
                                            : null)
                                        as ImageProvider?,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: pickImage,
                                child: const CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.edit,
                                    color: AppColors.scondaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${doctor!.firstName} ${doctor!.lastName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          doctor!.category,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        profileItem(
                          Icons.email,
                          t.translate('email'),
                          doctor!.email,
                        ),
                        profileItem(
                          Icons.phone,
                          t.translate('phone'),
                          doctor!.phoneNumber,
                        ),
                        profileItem(
                          Icons.location_on,
                          t.translate('address'),
                          doctor!.address,
                        ),
                        profileItem(
                          Icons.school,
                          t.translate('qualification'),
                          doctor!.qualification,
                        ),
                        profileItem(
                          Icons.work,
                          t.translate('experience'),
                          '${doctor!.yearsOfExperience} ${t.translate('years')}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const LangButton(),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => editProfileDialog(t),
                      ),
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: Text(
                        t.translate('edit_profile'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.scondaryColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(
                              t.translate('logout'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.scondaryColor,
                              ),
                            ),
                            content: Text(
                              t.translate('logout_confirmation'),
                              style: const TextStyle(
                                color: AppColors.scondaryColor,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  t.translate('cancel'),
                                  style: const TextStyle(
                                    color: AppColors.scondaryColor,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  t.translate('logout'),
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogout == true) {
                          await auth.signOut();
                          if (mounted)
                            GoRouter.of(
                              context,
                            ).pushReplacement(AppRouter.kSigninView);
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        t.translate('logout'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget profileItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.scondaryColor),
          const SizedBox(width: 16),
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget editProfileDialog(AppLocalizations t) {
    return AlertDialog(
      title: Text(t.translate('edit_profile')),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              textField(firstNameController, t.translate('first_name')),
              textField(lastNameController, t.translate('last_name')),
              textField(emailController, t.translate('email')),
              textField(phoneController, t.translate('phone')),
              textField(addressController, t.translate('address')),
              textField(categoryController, t.translate('category')),
              textField(qualificationController, t.translate('qualification')),
              textField(
                yearsController,
                t.translate('years_of_experience'),
                isNumber: true,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.translate('cancel')),
        ),
        TextButton(onPressed: updateProfile, child: Text(t.translate('save'))),
      ],
    );
  }

  Widget textField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? t.translate('required') : null,
      ),
    );
  }
}

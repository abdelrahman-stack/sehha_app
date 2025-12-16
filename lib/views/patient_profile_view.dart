import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:sehha_app/core/utils/app_router.dart';
import 'package:sehha_app/widgets/lang_button.dart';
import 'package:sehha_app/widgets/lottie_loading_Indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sehha_app/models/patient_model.dart';

class PatientProfileView extends StatefulWidget {
  const PatientProfileView({super.key});

  @override
  State<PatientProfileView> createState() => _PatientProfileViewState();
}

class _PatientProfileViewState extends State<PatientProfileView> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference patientDB = FirebaseDatabase.instance.ref('Patients');
  final supabase = Supabase.instance.client;

  PatientModel? patient;
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  File? pickedImage;

  @override
  void initState() {
    super.initState();
    fetchPatientData();
  }

  Future<void> fetchPatientData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        if (!mounted) return;
        setState(() => isLoading = false);
        return;
      }

      // Stream to listen to real-time changes
      patientDB.child(currentUser.uid).onValue.listen((event) {
        final snapshot = event.snapshot;
        if (snapshot.value != null) {
          final map = Map<String, dynamic>.from(snapshot.value as Map);
          if (!mounted) return;
          setState(() {
            patient = PatientModel.fromMap(map);
            isLoading = false;

            firstNameController = TextEditingController(
              text: patient!.firstName,
            );
            lastNameController = TextEditingController(text: patient!.lastName);
            emailController = TextEditingController(text: patient!.email);
            phoneController = TextEditingController(text: patient!.phoneNumber);
            addressController = TextEditingController(text: patient!.address);
          });
        } else {
          if (!mounted) return;
          setState(() => isLoading = false);
        }
      });
    } catch (e) {
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

      await patientDB.child(auth.currentUser!.uid).update({
        'profileImage': uploadedUrl,
      });

      if (!mounted) return;
      await fetchPatientData();
    }
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      String? uploadedUrl;

      if (pickedImage != null) {
        final fileName =
            'patient_${auth.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await supabase.storage
            .from('gallery_images')
            .upload(fileName, pickedImage!);
        uploadedUrl = supabase.storage
            .from('gallery_images')
            .getPublicUrl(fileName);
      }

      final Map<String, dynamic> updatedData = {
        'firstName': firstNameController.text.trim(),
        'lastName': lastNameController.text.trim(),
        'email': emailController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'address': addressController.text.trim(),
      };

      if (uploadedUrl != null) updatedData['profileImage'] = uploadedUrl;

      await patientDB.child(auth.currentUser!.uid).update(updatedData);

      await fetchPatientData();
      Navigator.pop(context);
    } catch (e) {
      // ignore: avoid_print
      print('Error updating profile: $e');
    }
    setState(() => isLoading = false);
  }

  void logout() async {
    final local = AppLocalizations.of(context);
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          local.translate('logout'),
          style: const TextStyle(color: AppColors.scondaryColor),
        ),
        content: Text(
          local.translate('logout_confirmation'),
          style: const TextStyle(color: AppColors.scondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              local.translate('cancel'),
              style: const TextStyle(color: AppColors.scondaryColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              local.translate('logout'),
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await auth.signOut();
      if (mounted) {
        GoRouter.of(context).pushReplacement(AppRouter.kSigninView);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          local.translate('patient_profile'),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.scondaryColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CustomCircularProgressIndicator())
          : patient == null
          ? Center(child: Text(local.translate('patient_data_not_found')))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header
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
                                  : NetworkImage(
                                          '${patient!.profileImage}?t=${DateTime.now().millisecondsSinceEpoch}',
                                        )
                                        as ImageProvider,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: pickImage,
                                child: const CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.white,
                                  child:  Icon(
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
                          '${patient!.firstName} ${patient!.lastName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
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
                          local.translate('email'),
                          patient!.email,
                        ),
                        profileItem(
                          Icons.phone,
                          local.translate('phone'),
                          patient!.phoneNumber,
                        ),
                        profileItem(
                          Icons.location_on,
                          local.translate('address'),
                          patient!.address,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                 const  LangButton(),
                 const  SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => editProfileDialog(),
                        );
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: Text(
                        local.translate('edit_profile'),
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

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        GoRouter.of(context).push(AppRouter.kMyBookingsView);
                      },
                      icon: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                      ),
                      label: Text(
                        local.translate('my_bookings'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightBlue,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  // Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: logout,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        local.translate('logout'),
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

  Widget editProfileDialog() {
    final local = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(local.translate('edit_profile')),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              textField(firstNameController, local.translate('first_name')),
              textField(lastNameController, local.translate('last_name')),
              textField(emailController, local.translate('email')),
              textField(phoneController, local.translate('phone')),
              textField(addressController, local.translate('address')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(local.translate('cancel')),
        ),
        TextButton(
          onPressed: updateProfile,
          child: Text(local.translate('save')),
        ),
      ],
    );
  }

  Widget textField(TextEditingController controller, String label) {
    final local = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? local.translate('required') : null,
      ),
    );
  }
}

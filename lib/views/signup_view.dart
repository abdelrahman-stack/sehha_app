import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:sehha_app/core/utils/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  final supabase = supa.Supabase.instance.client;
  final formKey = GlobalKey<FormState>();
  String userType = 'Patient';
  String email = '';
  String password = '';
  String phoneNumber = '';
  String fristName = '';
  String lastName = '';
  String address = '';
  String profileImage = '';
  String qualification = '';
  String yearOfExperience = '';
  double latitude = 0.0;
  double longitude = 0.0;
  final ImagePicker picker = ImagePicker();
  XFile? imageFile;
  String category = 'طبيب أسنان';
  final Location location = Location();
  bool isLoading = false;
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(local.translate('sign_up'))),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: imageFile != null
                          ? FileImage(File(imageFile!.path))
                          : null,
                      child: imageFile == null
                          ? const Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: imageUpload,
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.lightBlue,
                          child: Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const  SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ChoiceChip(
                      label: Text(local.translate('patient')),
                      selected: userType == 'Patient',
                      onSelected: (selected) {
                        setState(() {
                          userType = 'Patient';
                        });
                      },
                      selectedColor: AppColors.lightBlue,
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: userType == 'Patient'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    ChoiceChip(
                      label: Text(local.translate('doctor')),
                      selected: userType == 'Doctor',
                      onSelected: (selected) {
                        setState(() {
                          userType = 'Doctor';
                        });
                      },
                      selectedColor: AppColors.lightBlue,
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: userType == 'Doctor'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              const  SizedBox(height: 24),

                // Email
                TextFormField(
                  decoration: InputDecoration(
                    labelText: local.translate('email'),
                    labelStyle:const TextStyle(color: AppColors.lightBlue),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:const BorderSide(color: AppColors.lightBlue),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    prefixIcon:const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (val) => email = val,
                  validator: (value) => value!.isEmpty
                      ? local.translate('enter_your_email')
                      : null,
                ),
              const  SizedBox(height: 16),

                TextFormField(
                  decoration: InputDecoration(
                    labelText: local.translate('password'),
                    labelStyle:const TextStyle(color: AppColors.lightBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:const BorderSide(color: AppColors.lightBlue),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    prefixIcon:const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !isPasswordVisible,
                  onChanged: (val) => password = val,
                  validator: (value) => value!.isEmpty
                      ? local.translate('enter_a_password')
                      : null,
                ),

              const  SizedBox(height: 16),

                TextFormField(
                  decoration: InputDecoration(
                    labelText: local.translate('phone_number'),
                    labelStyle:const TextStyle(color: AppColors.lightBlue),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:const BorderSide(color: AppColors.lightBlue),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    prefixIcon:const Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (val) => phoneNumber = val,
                  validator: (value) => value!.isEmpty
                      ? local.translate('enter_your_phone_number')
                      : null,
                ),
              const  SizedBox(height: 16),

                TextFormField(
                  decoration: InputDecoration(
                    labelText: local.translate('first_name'),
                    labelStyle:const TextStyle(color: AppColors.lightBlue),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:const BorderSide(color: AppColors.lightBlue),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    prefixIcon:const Icon(Icons.person),
                  ),
                  onChanged: (val) => fristName = val,
                  validator: (value) => value!.isEmpty
                      ? local.translate('enter_your_first_name')
                      : null,
                ),
              const  SizedBox(height: 16),

                TextFormField(
                  decoration: InputDecoration(
                    labelText: local.translate('last_name'),
                    labelStyle:const TextStyle(color: AppColors.lightBlue),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:const BorderSide(color: AppColors.lightBlue),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    prefixIcon:const Icon(Icons.person_outline),
                  ),
                  onChanged: (val) => lastName = val,
                  validator: (value) => value!.isEmpty
                      ? local.translate('enter_your_last_name')
                      : null,
                ),
              const  SizedBox(height: 16),

                TextFormField(
                  decoration: InputDecoration(
                    labelText: local.translate('address'),
                    labelStyle:const TextStyle(color: AppColors.lightBlue),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:const BorderSide(color: AppColors.lightBlue),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    prefixIcon:const Icon(Icons.location_on),
                  ),
                  onChanged: (val) => address = val,
                  validator: (value) => value!.isEmpty
                      ? local.translate('enter_your_address')
                      : null,
                ),
              const  SizedBox(height: 16),

                if (userType == 'Doctor') ...[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: local.translate('qualification'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (val) => qualification = val,
                    validator: (value) => value!.isEmpty
                        ? local.translate('enter_your_qualification')
                        : null,
                  ),
                const  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    items:
                        [
                              'طبيب أسنان',
                              'أمراض قلب',
                              'أطفال',
                              'مخ وأعصاب',
                              'جلدية',
                              'عظام',
                              'نساء وتوليد',
                              'أمراض الجهاز الهضمي',
                              'عيون',
                            ]
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                    onChanged: (val) {
                      setState(() {
                        category = val!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: local.translate('category'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                const  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: local.translate('year_of_experience'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (val) => yearOfExperience = val,
                    validator: (value) => value!.isEmpty
                        ? local.translate('enter_a_year_of_experience')
                        : null,
                  ),
                const  SizedBox(height: 16),
                ],

                ElevatedButton.icon(
                  onPressed: getLocation,
                  icon:const Icon(Icons.my_location, size: 24),
                  label: Text(
                    local.translate('click_to_get_current_location'),
                    style:const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.scondaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                if (latitude != 0.0 && longitude != 0.0) ...[
                const  SizedBox(height: 8),
                  Text('Latitude: $latitude', textAlign: TextAlign.center),
                  Text('Longitude: $longitude', textAlign: TextAlign.center),
                const  SizedBox(height: 16),
                ],

              const  SizedBox(height: 16),
                ElevatedButton(
                  onPressed: register,

                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    local.translate('sign_up'),
                    style:const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> imageUpload() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = pickedFile;
    });
  }

  Future<void> getLocation() async {
    final LocationData locationData = await location.getLocation();
    setState(() {
      latitude = locationData.latitude!;
      longitude = locationData.longitude!;
    });
  }

  Future<String?> uploadImageToSupabase(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      final response = await supabase.storage
          .from('gallery_images')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const supa.FileOptions(contentType: 'image/jpeg'),
          );

      if (response.isNotEmpty) {
        final imageUrl = supabase.storage
            .from('gallery_images')
            .getPublicUrl(fileName);

        return imageUrl;
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
    return null;
  }

  Future<void> register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        UserCredential userCredential = await auth
            .createUserWithEmailAndPassword(email: email, password: password);

        User? user = userCredential.user;

        if (user != null) {
          if (imageFile != null) {
            profileImage = await uploadImageToSupabase(imageFile!) ?? '';
          }

          String userTypePath = userType == 'Doctor' ? 'Doctors' : 'Patients';

          Map<String, dynamic> userData = {
            'uid': user.uid,
            'email': email,
            'password': password,
            'phoneNumber': phoneNumber,
            'firstName': fristName,
            'lastName': lastName,
            'address': address,
            'latitude': latitude,
            'longitude': longitude,
            'profileImage': profileImage,
          };

          if (userType == 'Doctor') {
            userData['qualification'] = qualification;
            userData['category'] = category;
            userData['yearsOfExperience'] = yearOfExperience;
            userData['totalReviews'] = 0;
            userData['averageRating'] = 0.0;
            userData['numberOfReviews'] = 0;
          }

          await ref.child(userTypePath).child(user.uid).set(userData);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );

          GoRouter.of(context).push(
            userType == 'Doctor'
                ? AppRouter.kDoctorView
                : AppRouter.kPatientView,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
      }

      setState(() {
        isLoading = false;
      });
    }
  }
}

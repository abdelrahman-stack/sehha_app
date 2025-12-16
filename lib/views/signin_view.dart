import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sehha_app/core/tools/app_localizations%20.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:sehha_app/core/utils/app_router.dart';
import 'package:sehha_app/core/utils/assets.dart';

import 'package:sehha_app/widgets/custom_text_form_field.dart';

class SigninView extends StatefulWidget {
  const SigninView({super.key});

  @override
  State<SigninView> createState() => _SigninViewState();
}

class _SigninViewState extends State<SigninView> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isNavigator = false;

  String email = '';
  String password = '';
  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                 const  SizedBox(height: 100),
                  Column(
                    children: [
                      Image.asset(
                        Assets.assetsImagesDoctor1,
                        fit: BoxFit.cover,
                        // height: MediaQuery.of(context).size.height * 0.3,
                        // width: MediaQuery.of(context).size.width * 0.4,
                      ),

                     const  SizedBox(height: 20),

                      Text(
                        local.translate('welcome'),
                        style: const TextStyle(
                          fontSize: 20,
                          color: AppColors.lightBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                     const  SizedBox(height: 10),
                      Text(
                        local.translate('sign_in_to_continue_your_journey'),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                 const  SizedBox(height: 30),
                  Form(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomTextFormField(
                          validator: (val) => val!.isEmpty
                              ? local.translate('enter_your_email')
                              : null,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (val) => email = val,
                          text: local.translate('email'),
                          icon: Icons.email,
                        ),
                       const  SizedBox(height: 10),
                        CustomTextFormField(
                          validator: (val) {
                            if (val!.length < 6) {
                              return local.translate(
                                'password_must_be_at_least_6_characters',
                              );
                            }
                            return null;
                          },
                          keyboardType: TextInputType.visiblePassword,
                          onChanged: (val) => password = val,
                          text: local.translate('password'),
                          icon: Icons.lock,
                        ),
                      const  SizedBox(height: 10),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: sigin,
                          child: Text(
                            local.translate('sign_in'),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(local.translate('don_t_have_an_account')),
                            TextButton(
                              onPressed: () {
                                GoRouter.of(
                                  context,
                                ).push(AppRouter.kSignupView);
                              },
                              child: Text(
                                local.translate('sign_up'),
                                style: const TextStyle(color: AppColors.lightBlue),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> sigin() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      try {
        UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        User? user = userCredential.user;

        if (user != null) {
          DatabaseReference userRef = ref.child('Doctors').child(user.uid);
          DataSnapshot snapshot = await userRef.get();
          if (snapshot.exists) {
            navigateToDoctorView();
          } else {
            userRef = ref.child('Patients').child(user.uid);
            snapshot = await userRef.get();
            if (snapshot.exists) {
              navigateToPatientView();
            } else {
              setState(() {
                isLoading = false;
              });
              GoRouter.of(context).push(AppRouter.kSigninView);
            }
          }
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void navigateToDoctorView() {
    if (!isNavigator) {
      isNavigator = true;
      GoRouter.of(context).push(AppRouter.kDoctorView);
    }
  }

  void navigateToPatientView() {
    if (!isNavigator) {
      isNavigator = true;
      GoRouter.of(context).push(AppRouter.kPatientView);
    }
  }
  
}

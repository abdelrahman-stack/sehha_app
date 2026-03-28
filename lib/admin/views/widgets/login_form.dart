import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehha_app/admin/cubit/cubit/admin_cubit.dart';

class AdminLoginForm extends StatefulWidget {
  const AdminLoginForm({super.key});

  @override
  State<AdminLoginForm> createState() => _AdminLoginFormState();
}

class _AdminLoginFormState extends State<AdminLoginForm> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController),
            TextField(
              controller: passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<AdminAuthCubit>().login(
                      email: emailController.text,
                      password: passwordController.text,
                    );
              },
              child: const Text('دخول'),
            ),
          ],
        ),
      ),
    );
  }
}

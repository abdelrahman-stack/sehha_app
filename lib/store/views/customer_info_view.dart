import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:sehha_app/core/utils/app_router.dart';
import 'package:sehha_app/widgets/custom_snack_bar.dart';

class CustomerInfoView extends StatefulWidget {
  final String paymentMethod;
  const CustomerInfoView({required this.paymentMethod, super.key});

  @override
  State<CustomerInfoView> createState() => _CustomerInfoViewState();
}

class _CustomerInfoViewState extends State<CustomerInfoView> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  Widget customTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.green.shade700),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.green),
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'بيانات العميل',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            customTextField(
              controller: nameController,
              label: 'الاسم',
              icon: Icons.person,
            ),
            customTextField(
              controller: phoneController,
              label: 'رقم الهاتف',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            customTextField(
              controller: addressController,
              label: 'العنوان',
              icon: Icons.location_on,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.green.shade700,
                  elevation: 6,
                  shadowColor: Colors.green.shade300,
                ),
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      phoneController.text.isEmpty ||
                      addressController.text.isEmpty) {
                    CustomSnackBar.show(
                      context,
                      message: 'من فضلك ادخل جميع البيانات',
                      backgroundColor: StoreAppColors.accent,
                    );
                    return;
                  }

                  context.push(
                    AppRouter.kOrderSummaryView,
                    extra: {
                      'paymentMethod': widget.paymentMethod,
                      'name': nameController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'address': addressController.text.trim(),
                    },
                  );
                },
                child: const Text(
                  'التالي',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

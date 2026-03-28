import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sehha_app/admin/services/firebase_service.dart';
import 'package:sehha_app/admin/services/supabase_service.dart';
import 'package:sehha_app/widgets/custom_snack_bar.dart';
import 'package:uuid/uuid.dart';

const _kDark = Color(0xFF0A0E1A);
const _kDark2 = Color(0xFF121C30);
const _kBlue = Color(0xFF274BEF);

class AddEditProductView extends StatefulWidget {
  final Map<String, dynamic>? product;
  const AddEditProductView({this.product, super.key});
  @override
  State<AddEditProductView> createState() => _AddEditProductViewState();
}

class _AddEditProductViewState extends State<AddEditProductView>
    with SingleTickerProviderStateMixin {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  XFile? imageFile;
  String? imageUrl;
  final supaService = SupaService();
  bool isLoading = false;

  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    if (widget.product != null) {
      nameCtrl.text = widget.product!['name'] ?? '';
      descCtrl.text = widget.product!['description'] ?? '';
      priceCtrl.text = widget.product!['price'].toString();
      imageUrl = widget.product!['image'];
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => imageFile = picked);
  }

  Future<void> save() async {
    if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) {
      CustomSnackBar.show(
        context,
        message: 'اسم المنتج والسعر مطلوبين',
        backgroundColor: Colors.redAccent,
      );
      return;
    }
    setState(() => isLoading = true);
    try {
      final id = widget.product != null
          ? widget.product!['id']
          : const Uuid().v4();
      String finalUrl = imageUrl ?? '';
      if (imageFile != null) {
        final up = await supaService.uploadImage(imageFile!);
        if (up != null) finalUrl = up;
      }
      await FirebaseService.saveProduct(
        id: id,
        name: nameCtrl.text,
        description: descCtrl.text,
        price: double.parse(priceCtrl.text),
        imageUrl: finalUrl,
      );
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'تم حفظ المنتج بنجاح ✓',
          backgroundColor: const Color(0xFF2E7D32),
        );
        await Future.delayed(const Duration(milliseconds: 1500));
        Navigator.pop(context);
      }
    } catch (_) {
      CustomSnackBar.show(
        context,
        message: 'حدث خطأ، حاول مرة أخرى',
        backgroundColor: Colors.redAccent,
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Scaffold(
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
          const Positioned(top: -50, right: -50, child: _Glow(180, _kBlue)),
          const Positioned(bottom: -60, left: -40, child: _Glow(150, _kBlue)),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          isEdit ? 'تعديل المنتج' : 'إضافة منتج',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: FadeTransition(
                    opacity: _fade,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: pickImage,
                            child: Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .06),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: imageFile != null || imageUrl != null
                                      ? _kBlue.withValues(alpha: .5)
                                      : Colors.white.withValues(alpha: .1),
                                  width: imageFile != null || imageUrl != null
                                      ? 1.5
                                      : 1,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: imageFile != null
                                  ? Image.file(
                                      File(imageFile!.path),
                                      fit: BoxFit.cover,
                                    )
                                  : imageUrl != null
                                  ? Image.network(
                                      imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _ImagePlaceholder(),
                                    )
                                  : _ImagePlaceholder(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          _DarkField(
                            ctrl: nameCtrl,
                            label: 'اسم المنتج',
                            icon: Icons.inventory_2_outlined,
                          ),
                          const SizedBox(height: 12),
                          _DarkField(
                            ctrl: descCtrl,
                            label: 'الوصف',
                            icon: Icons.description_outlined,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 12),
                          _DarkField(
                            ctrl: priceCtrl,
                            label: 'السعر (ج.م)',
                            icon: Icons.attach_money_rounded,
                            keyboard: TextInputType.number,
                          ),

                          const SizedBox(height: 28),

                          GestureDetector(
                            onTap: isLoading ? null : save,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 56,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isLoading
                                      ? [Colors.white10, Colors.white10]
                                      : [_kBlue, _kBlue.withValues(alpha: .75)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: isLoading
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: _kBlue.withValues(alpha: .5),
                                          blurRadius: 18,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isEdit
                                                ? Icons.save_rounded
                                                : Icons
                                                      .add_circle_outline_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            isEdit
                                                ? 'حفظ التعديلات'
                                                : 'إضافة المنتج',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ],
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
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: _kBlue.withValues(alpha: .12),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.add_a_photo_rounded,
          color: Color(0xFF274BEF),
          size: 24,
        ),
      ),
      const SizedBox(height: 10),
      const Text(
        'اضغط لإضافة صورة',
        style: TextStyle(color: Colors.white38, fontSize: 13),
      ),
      const SizedBox(height: 4),
      Text(
        'PNG, JPG مقبول',
        style: TextStyle(
          color: Colors.white.withValues(alpha: .2),
          fontSize: 11,
        ),
      ),
    ],
  );
}

class _DarkField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType keyboard;
  final int maxLines;
  const _DarkField({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.keyboard = TextInputType.text,
    this.maxLines = 1,
  });
  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    keyboardType: keyboard,
    maxLines: maxLines,
    style: const TextStyle(color: Colors.white, fontSize: 14),
    cursorColor: _kBlue,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white.withValues(alpha: .4),
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: Colors.white30, size: 18),
      filled: true,
      fillColor: Colors.white.withValues(alpha: .07),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _kBlue.withValues(alpha: .7), width: 1.5),
      ),
    ),
  );
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  const _Glow(this.size, this.color);
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

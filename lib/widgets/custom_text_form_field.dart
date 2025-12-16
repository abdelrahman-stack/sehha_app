import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.text,
    this.icon,
    this.textColor = Colors.black,
    this.borderColor = Colors.black,
    this.textController,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.isPassword = false,
  });
  final String text;
  final IconData? icon;
  final Color textColor;
  final Color borderColor;
  final TextEditingController? textController;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool isPassword ;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword && !isPasswordVisible ,
      onChanged: widget.onChanged,
      validator: widget.validator,
      controller: widget.textController,
      cursorColor: Colors.blue,
      decoration: InputDecoration(
        isDense: true,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.borderColor),
        ),
        border:const OutlineInputBorder(),

        hintText: widget.text,
        hintStyle: TextStyle(color: widget.textColor),

        prefixIcon: Icon(widget.icon),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.text,
    this.icon,
    this.textColor = Colors.black,
    this.borderColor = Colors.black,
  });
  final String text;
  final IconData? icon;
  final Color textColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Colors.blue,
      decoration: InputDecoration(
        isDense: true,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
        border:const OutlineInputBorder(),

        hintText: text,
        hintStyle: TextStyle(color: textColor),

        prefixIcon: Icon(icon),
      ),
    );
  }
}

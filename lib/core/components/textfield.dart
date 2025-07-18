import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final bool isReadOnly;
  final Function? ontap;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool isHorizontallyPadded;
  final TextStyle labelStyle;
  final int minLines;
  final int maxLines;

  const CustomInputField(
      {super.key,
      required this.controller,
      required this.label,
      this.keyboardType,
      this.isReadOnly = false,
      this.ontap,
      this.suffixIcon,
      this.prefixIcon,
      this.isHorizontallyPadded = true,
      this.isPassword = false,
      this.minLines = 1,
      this.maxLines = 1,
      this.labelStyle = const TextStyle(fontSize: 14)});

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.isHorizontallyPadded
          ? const EdgeInsets.symmetric(horizontal: 20, vertical: 5)
          : null,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        onTap: () {
          if (widget.ontap != null) {
            widget.ontap!();
          }
        },
        keyboardType: widget.keyboardType,
        readOnly: widget.isReadOnly,
        controller: widget.controller,
        obscureText: widget.isPassword,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        decoration: InputDecoration(
          prefixIcon: widget.prefixIcon,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          label: Text(widget.label, style: widget.labelStyle),
          contentPadding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
          suffixIcon: widget.suffixIcon,
        ),
      ),
    );
  }
}

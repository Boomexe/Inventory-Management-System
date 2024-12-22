import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController textController;
  final String Function(String)? validator;
  final String? errorMsg;
  final TextInputType? keyboardType;
  const MyTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    required this.textController,
    this.validator,
    this.errorMsg,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType ?? TextInputType.text,
      cursorColor: Theme.of(context).colorScheme.surfaceContainerLow,
      controller: textController,
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            // color: Theme.of(context).colorScheme.primary,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
              // color: Theme.of(context).colorScheme.secondary,
              ),
        ),
        hintText: hintText,
        // hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
        errorText: errorMsg,
        filled: true,
        // fillColor: Theme.of(context).colorScheme.secondary,
      ),
      obscureText: obscureText,
      validator: (value) => validator!(value!),
    );
  }
}

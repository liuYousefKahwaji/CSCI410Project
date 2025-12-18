import 'package:flutter/material.dart';

class AuthField extends StatefulWidget { 
  final String label;
  final String hint;
  final TextEditingController controller;
  final Icon icon;
  final bool isPassword;

  const AuthField({
    super.key, 
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    this.isPassword = false,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) { 
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        prefixIcon: widget.icon,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
        labelText: widget.label,
        hintText: widget.hint,
      ),
      obscureText: widget.isPassword ? _obscureText : false,
    );
  }
}
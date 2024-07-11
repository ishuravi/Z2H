import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final TextInputType? keyboardType; // Add keyboardType parameter
  final int? maxLength; // Add maxLength parameter
  final bool? readOnly; // Add readOnly parameter
  final VoidCallback? onTap; // Add onTap parameter



  const CustomTextField(
      {Key? key, required this.label, this.controller, this.validator, this.onChanged,
        this.keyboardType,    this.maxLength,  this.readOnly,
        this.onTap,
      })
      : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(

      controller: widget.controller,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength, // Use maxLength here
      readOnly: widget.readOnly ?? false,
      onTap: widget.onTap, // Use onTap here
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        errorText: errorText,
      ),
      onChanged: (value) {
        setState(() {
          errorText = widget.validator!(value);
    if (widget.onChanged != null) {
      widget.onChanged!(value);
    }
        });
      },
    );
  }
}

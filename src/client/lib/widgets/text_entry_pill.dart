import 'package:flutter/material.dart';

class TextEntryPill extends StatelessWidget {
  const TextEntryPill({
    required this.icon,
    required this.hintText,
    required this.obscured
  }) : super();

  final Icon icon;
  final String hintText;
  final bool obscured;

  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlignVertical: TextAlignVertical.center,
      obscureText: obscured,
      style: TextStyle(
          fontStyle: Theme.of(context).textTheme.labelLarge?.fontStyle,
          fontSize: Theme.of(context).textTheme.labelLarge?.fontSize
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontStyle: Theme.of(context).textTheme.labelMedium?.fontStyle,
          fontSize: Theme.of(context).textTheme.labelLarge?.fontSize,
          color: Theme.of(context).colorScheme.outline
        ),
        // errorText: "must provide an email",
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondaryContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1000.0),
          borderSide: BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
        prefixIcon: icon,
      ),
    );
  }
}
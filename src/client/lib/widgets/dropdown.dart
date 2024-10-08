import 'package:flutter/material.dart';

class Themed_DropdownButton extends StatefulWidget {
  Themed_DropdownButton({
    required this.icon,
    required this.hintText,
    required this.list,
    required this.controller,
  }) : super();

  final Icon icon;
  final String hintText;
  final List<String> list;
  String? controller;

  @override
  State<Themed_DropdownButton> createState() => Themed_DropdownButtonState();
}

class Themed_DropdownButtonState extends State<Themed_DropdownButton> {
  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      initialSelection: widget.controller,
      // Similar to `value` in DropdownButton
      dropdownMenuEntries: widget.list.map((String value) {
        return DropdownMenuEntry<String>(
          value: value,
          label: value,
        );
      }).toList(),
      onSelected: (String? value) {
        setState(() {
          widget.controller = value;
        });
      },
      textStyle: TextStyle(
        fontStyle: Theme.of(context).textTheme.labelLarge?.fontStyle,
        fontSize: Theme.of(context).textTheme.labelLarge?.fontSize,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Theme.of(context).colorScheme.secondaryContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(1000.0),
          borderSide: BorderSide(
            width: 0,
            style: BorderStyle.none,
          ),
        ),
      ),
      leadingIcon: widget.icon,
      hintText: widget.hintText,
    );
  }
}

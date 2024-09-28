import 'package:flutter/material.dart';

class Themed_DropdownButton extends StatefulWidget {
  Themed_DropdownButton({
    required this.icon,
    required this.hintText,
    required this.obscured,
    required this.list,
  }) : super();

  final Icon icon;
  final String hintText;
  final bool obscured;
  final List<String> list;

  @override
  State<Themed_DropdownButton> createState() => Themed_DropdownButtonState();
}

class Themed_DropdownButtonState extends State<Themed_DropdownButton> {
  String? dropdownValue;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(1000.0),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.icon,
            DropdownButton<String>(
              value: dropdownValue,
              underline: Container(
                height: 0,
              ),
              elevation: 8,
              style: TextStyle(
                  fontStyle: Theme.of(context).textTheme.labelLarge?.fontStyle,
                  fontSize: Theme.of(context).textTheme.labelLarge?.fontSize,
                  color: Theme.of(context).colorScheme.outline
              ),
              onChanged: (String? value) {
                // This is called when the user selects an item.
                setState(() {
                  dropdownValue = value!;
                });
              },
              items: widget.list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ]
        ),
      ),
    );
  }
}
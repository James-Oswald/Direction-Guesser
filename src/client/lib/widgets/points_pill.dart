import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final NumberFormat formatter = NumberFormat.decimalPatternDigits(
  locale: 'en_us',
  decimalDigits: 0,
);

class PointsPill extends StatelessWidget {
  const PointsPill({required this.points}) : super();

  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(100.0)),
        child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars_rounded,
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
                SizedBox(width: 4),
                Text(
                  formatter.format(points),
                  style: TextStyle(
                      fontStyle:
                          Theme.of(context).textTheme.labelLarge?.fontStyle,
                      fontSize:
                          Theme.of(context).textTheme.labelLarge?.fontSize,
                      color: Theme.of(context).colorScheme.onTertiaryContainer),
                ),
                SizedBox(width: 4),
              ],
            )));
  }
}

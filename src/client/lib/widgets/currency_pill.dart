import 'package:flutter/material.dart';

enum Rank { first, second, third, other }

class CurrencyPill extends StatelessWidget {
  const CurrencyPill({required this.funds}) : super();

  final int funds;

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
                  Icons.attach_money_rounded,
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
                SizedBox(width: 4),
                Text(
                  "$funds",
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

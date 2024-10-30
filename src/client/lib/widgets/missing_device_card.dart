import 'package:flutter/material.dart';

class MissingDeviceCard extends StatelessWidget {
  const MissingDeviceCard({required this.mainText, required this.subText})
      : super();

  final String mainText;
  final String subText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
            child: Card(
                elevation: 6,
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.75),
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(height: 16),
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            mainText,
                            style: TextStyle(
                                fontStyle: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.fontStyle,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.fontSize),
                            selectionColor: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            textAlign: TextAlign.center,
                          )),
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            subText,
                            style: TextStyle(
                                fontStyle: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.fontStyle,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.fontSize),
                            selectionColor: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            textAlign: TextAlign.center,
                          )),
                      SizedBox(height: 16),
                    ])))));
  }
}

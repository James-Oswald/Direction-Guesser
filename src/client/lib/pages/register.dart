import 'package:direction_guesser/widgets/text_entry_pill.dart';
import 'package:direction_guesser/widgets/dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatelessWidget {

  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).brightness == Brightness.light ? Color(0xFFFAF8FF) : Color(0xFF121318),
                    Theme.of(context).brightness == Brightness.light ? Color(0xFF495D92) : Color(0xFF151B2C)
                  ]
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Spacer(),
                    Image.asset(
                      "assets/logo.png",
                      width: 300,
                      height: 300,
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 64,
                    child: TextEntryPill(
                      icon: Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      hintText: "username",
                      obscured: false,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 64,
                    child: TextEntryPill(
                      icon: Icon(
                        Icons.email_rounded,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      hintText: "email",
                      obscured: false,
                    )
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 64,
                    child: TextEntryPill(
                      icon: Icon(
                        Icons.key_rounded,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      hintText: "password",
                      obscured: true
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Text(
                      "Optional demographic information is collected for research purposes.",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontStyle: Theme.of(context).textTheme.bodySmall?.fontStyle,
                        fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                        color: Theme.of(context).brightness == Brightness.light ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.outline
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("age:", style: TextStyle(
                              fontStyle: Theme.of(context).textTheme.bodySmall?.fontStyle,
                              fontSize: 22,
                              color: Theme.of(context).brightness == Brightness.light ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surfaceTint
                            )),
                            SizedBox(width: 12),
                            SizedBox(
                              width: 128,
                              height: 64,
                              child: TextField(
                                textAlignVertical: TextAlignVertical.center,
                                style: TextStyle(
                                  fontStyle: Theme.of(context).textTheme.labelLarge?.fontStyle,
                                  fontSize: Theme.of(context).textTheme.labelLarge?.fontSize
                                ),
                                decoration: InputDecoration(
                                  hintText: "age",
                                  hintStyle: TextStyle(
                                    fontStyle: Theme.of(context).textTheme.labelMedium?.fontStyle,
                                    fontSize: Theme.of(context).textTheme.labelLarge?.fontSize,
                                    color: Theme.of(context).colorScheme.outline
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.secondaryContainer,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(1000.0),
                                    borderSide: BorderSide(
                                      width: 0,
                                      style: BorderStyle.none,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.cake_rounded,
                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("gender:", style: TextStyle(
                              fontStyle: Theme.of(context).textTheme.labelLarge?.fontStyle,
                              fontSize: 22,
                              color: Theme.of(context).brightness == Brightness.light ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surfaceTint
                            )),
                            SizedBox(width: 12),
                            SizedBox(
                              height: 64,
                              width: 128,
                              child: Themed_DropdownButton(
                                icon: Icon(
                                Icons.wc_rounded,
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                                list: const ["M","F","O"],
                                  hintText: ""
                              )
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FilledButton(
                        onPressed: (){Navigator.pushReplacementNamed(context, '/login');}, // TODO: REST API signup call
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                              fontStyle: Theme.of(context).textTheme.labelLarge?.fontStyle,
                              fontSize: Theme.of(context).textTheme.labelLarge?.fontSize
                          ),
                          selectionColor: Theme.of(context).colorScheme.onPrimaryContainer,
                        )
                      ),
                      SizedBox(width: 24),
                      FilledButton(
                        onPressed: (){Navigator.pushReplacementNamed(context, '/register');}, // TODO: REST API signup call
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontStyle: Theme.of(context).textTheme.labelLarge?.fontStyle,
                              fontSize: Theme.of(context).textTheme.labelLarge?.fontSize
                          ),
                          selectionColor: Theme.of(context).colorScheme.onPrimaryContainer,
                        )
                      ),
                    ],
                  ),
                  Spacer()],
                ),
              ),
            ),
          );}
      )
    );
  }
}
import 'package:direction_guesser/theme.dart';
import 'package:direction_guesser/widgets/text_entry_pill.dart';
import 'package:direction_guesser/widgets/dropdown.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {

  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: MaterialTheme(Theme.of(context).textTheme).theme(MaterialTheme.lightScheme()),
      darkTheme: MaterialTheme(Theme.of(context).textTheme).theme(MaterialTheme.darkScheme()),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Builder(
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
                    Spacer(),
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
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(
                      "Optional demographic information is collected for research purposes.",
                      textAlign: TextAlign.left,
                      style: TextStyle( 
                          fontStyle: Theme.of(context).textTheme.labelLarge?.fontStyle,
                          fontSize: Theme.of(context).textTheme.labelLarge?.fontSize,
                          color: Theme.of(context).brightness == Brightness.light ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surfaceTint
                      ),
                    ),
                  ),
                  SizedBox(height: 32,),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("age:", style: TextStyle(
                                fontStyle: Theme.of(context).textTheme.headlineSmall?.fontStyle,
                                fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
                                color: Theme.of(context).brightness == Brightness.light ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surfaceTint
                            )),
                            SizedBox(width: 12,),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.45,
                              height: 64,
                              child: TextEntryPill(
                                  icon: Icon(
                                    Icons.cake_rounded,
                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  ),
                                  hintText: "age",
                                  obscured: false
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("gender:", style: TextStyle(
                                fontStyle: Theme.of(context).textTheme.headlineSmall?.fontStyle,
                                fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
                                color: Theme.of(context).brightness == Brightness.light ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surfaceTint
                            )),
                            SizedBox(width: 12,),
                            SizedBox(
                              height: 64,
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: Themed_DropdownButton(
                                icon: Icon(
                                Icons.wc_rounded,
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                                list: ["M","F","O"],
                                  hintText: "gender",
                                  obscured: false,
                              )
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 64),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Poop?",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontStyle: Theme.of(context).textTheme.headlineSmall?.fontStyle,
                          fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
                          color: Theme.of(context).brightness == Brightness.light ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surfaceTint
                        ),
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
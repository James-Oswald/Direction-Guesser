import 'package:direction_guesser/controllers/user_services.dart';
import 'package:direction_guesser/widgets/dropdown.dart';
import 'package:direction_guesser/widgets/text_entry_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String? genderController;

  @override
  Widget build(BuildContext context) {
    TextStyle bodySmallStyle = TextStyle(
        fontStyle: Theme.of(context).textTheme.bodySmall?.fontStyle,
        fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
        color: Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.outline);

    TextStyle bodyStyle = TextStyle(
        fontStyle: Theme.of(context).textTheme.bodySmall?.fontStyle,
        fontSize: 22,
        color: Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.surfaceTint);

    TextStyle labelLargeStyle = TextStyle(
        fontStyle: Theme.of(context).textTheme.labelLarge?.fontStyle,
        fontSize: Theme.of(context).textTheme.labelLarge?.fontSize);

    return Scaffold(body: Builder(builder: (context) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).brightness == Brightness.light
                    ? Color(0xFFFAF8FF)
                    : Color(0xFF121318),
                Theme.of(context).brightness == Brightness.light
                    ? Color(0xFF495D92)
                    : Color(0xFF151B2C)
              ]),
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
                    controller: usernameController,
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
                      controller: emailController,
                      icon: Icon(
                        Icons.email_rounded,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      hintText: "email",
                      obscured: false,
                    )),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 64,
                  child: TextEntryPill(
                      controller: passwordController,
                      icon: Icon(
                        Icons.key_rounded,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      hintText: "password",
                      obscured: true),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Text(
                    "Optional demographic information is collected for research purposes.",
                    textAlign: TextAlign.left,
                    style: bodySmallStyle,
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
                          Text("age:", style: bodyStyle),
                          SizedBox(width: 12),
                          SizedBox(
                            width: 128,
                            height: 64,
                            child: TextField(
                              controller: ageController,
                              textAlignVertical: TextAlignVertical.center,
                              style: labelLargeStyle,
                              decoration: InputDecoration(
                                hintText: "age",
                                hintStyle: TextStyle(
                                    fontStyle: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.fontStyle,
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.fontSize,
                                    color:
                                        Theme.of(context).colorScheme.outline),
                                filled: true,
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(1000.0),
                                  borderSide: BorderSide(
                                    width: 0,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.cake_rounded,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("gender:", style: bodyStyle),
                          SizedBox(width: 12),
                          SizedBox(
                              height: 64,
                              width: 128,
                              child: Themed_DropdownButton(
                                  controller: genderController,
                                  icon: Icon(
                                    Icons.wc_rounded,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                  ),
                                  list: const ["M", "F", "O"],
                                  hintText: "")),
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        child: Text(
                          "Login",
                          style: labelLargeStyle,
                          selectionColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        )),
                    SizedBox(width: 24),
                    FilledButton(
                        onPressed: () => submit(context),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        child: Text(
                          "Sign Up",
                          style: labelLargeStyle,
                          selectionColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        )),
                  ],
                ),
                Spacer()
              ],
            ),
          ),
        ),
      );
    }));
  }

  Future<void> submit(BuildContext context) async {
    // Use async/await for better readability and error handling
    bool isRegistered = await context.read<UsersServices>().registerUser(
        usernameController.text, emailController.text, passwordController.text
        // TODO: REST API signup call
        // TODO: Add age, gender
        );

    // Check the result of registration
    if (isRegistered) {
      if (context.mounted) {
        // Show success message and navigate back to login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to login page
        Navigator.pop(context);
      }
    } else {
      // Show failure message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

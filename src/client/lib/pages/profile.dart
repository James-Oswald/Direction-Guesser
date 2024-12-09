import 'package:direction_guesser/controllers/user_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // TODO: set these to empty once backend is hooked up
  String username = "default-user";
  String email = "myemail@email.com";
  AssetImage profilePicture = AssetImage("assets/default_profile_picture.png");
  bool success = false;

  @override
  Widget build(BuildContext context) {
    getUserData(context);
    if (success) {
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
              body: Row(children: [
                SizedBox(width: 64),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 128),
                    SizedBox(
                        height: 128,
                        width: 128,
                        child: CircleAvatar(
                            foregroundImage: profilePicture,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer)),
                    SizedBox(height: 16),
                    Text("username: $username",
                        style: TextStyle(
                            fontStyle: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.fontStyle,
                            fontSize: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.fontSize,
                            color: Theme.of(context).colorScheme.primary),
                        textAlign: TextAlign.center),
                    SizedBox(height: 16),
                    Text("email: $email",
                        style: TextStyle(
                            fontStyle: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.fontStyle,
                            fontSize: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.fontSize,
                            color: Theme.of(context).colorScheme.primary),
                        textAlign: TextAlign.center),
                    Spacer(),
                    FilledButton.tonal(
                        onPressed: () {
                          Navigator.pushNamed(context, '/home');
                        },
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        )),
                    SizedBox(height: 32)
                  ],
                ),
              ]),
            ));
      }));
    } else {
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Failed to load user data! Please try again.",
                      style: TextStyle(
                          fontStyle:
                              Theme.of(context).textTheme.titleLarge?.fontStyle,
                          fontSize:
                              Theme.of(context).textTheme.titleLarge?.fontSize,
                          color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center),
                  Spacer(),
                  FilledButton.tonal(
                      onPressed: () {
                        Navigator.pushNamed(context, '/home');
                      },
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      )),
                  SizedBox(height: 32)
                ],
              ),
            ),
          ),
        );
      }));
    }
  }

  Future<void> getUserData(BuildContext context) async {
    // TODO: remove this once backend is hooked up, is for testing only
    success = true;

    success = await context.read<UsersServices>().getUserData(username);

    // TODO: get the data from shared preferences? user model?
  }
}

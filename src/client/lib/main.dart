import 'package:flutter/material.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 224, 193, 107),
                Color.fromARGB(255, 161, 117, 226)
              ]),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: Center(
              child: Container(
            alignment: Alignment.center,
            decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                gradient: LinearGradient(begin: Alignment.topCenter, colors: [
                  Color.fromARGB(255, 161, 117, 226),
                  Color.fromARGB(255, 206, 165, 78)
                ]),
                shadows: [
                  BoxShadow(
                      color: const Color.fromARGB(255, 88, 88, 88),
                      offset: Offset(0, 2),
                      blurRadius: 4)
                ]),
            height: double.infinity,
            margin: EdgeInsets.all(40),
            padding: EdgeInsets.all(10),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Image.asset(
                      "assets/logo.png",
                      width: 300,
                      height: 300,
                    ),
                  ),
                  Center(
                    child: Text(
                      "Direction Guesser",
                      style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                      child: Text("Directables!",
                          style: TextStyle(color: Colors.white))),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 226, 241, 252).withOpacity(.9),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 88, 88, 88),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Container(
                      height: 20,
                      child: TextField(
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Email",
                            hintStyle: TextStyle(
                                color: const Color.fromARGB(255, 0, 0, 0)),
                            icon: Icon(
                              Icons.email,
                              color: const Color.fromARGB(255, 0, 0, 0),
                              size: 20,
                            )),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 226, 241, 252).withOpacity(.9),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 88, 88, 88),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Container(
                      height: 20,
                      child: TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.grey),
                            icon: Icon(
                              Icons.lock,
                              color: const Color.fromARGB(255, 0, 0, 0),
                              size: 20,
                            )),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: () {},
                            child: Text("Login", style: TextStyle(color: Colors.white)),
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                    Color.fromARGB(255, 161, 117, 226))),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.white),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text("Sign Up", style: TextStyle(color: Colors.white)),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color.fromARGB(255, 161, 117, 226))),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }
}

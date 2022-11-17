import 'package:activity_app/screens/home_screen.dart';
import 'package:activity_app/screens/login_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _showLoginPage = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Activity App',
      theme: ThemeData(
          fontFamily: 'Montserrat',
          primarySwatch: Colors.indigo,
          bottomAppBarColor: Colors.black),
      home: _isLoading ? const LoginScreen() : const Text("Home"),
    );
  }
}

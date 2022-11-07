import 'package:activity_app/screens/home_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Activity App",
      theme: ThemeData(
          fontFamily: 'Montserrat',
          primarySwatch: Colors.indigo,
          bottomAppBarColor: Colors.black),
      home: const HomePage(),
    );
  }
}

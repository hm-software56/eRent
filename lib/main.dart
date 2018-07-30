import 'package:erent/verifycode.dart';
import 'package:flutter/material.dart';
import 'package:erent/login.dart';
import 'package:erent/home.dart';
import 'package:erent/register.dart';
import 'package:erent/newpassword.dart';
void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

 final routes = <String, WidgetBuilder>{
    '/login': (context) => Login(),
    '/home': (context) => Home(),
    '/register':(context) =>Register(),
  };
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'eRent',
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      home:Login(),
      routes: routes,
    );
  }
}

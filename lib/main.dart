import 'package:erent/forms/getmap.dart';
import 'package:erent/forms/listhouse_user.dart';
import 'package:erent/profile.dart';
import 'package:flutter/material.dart';
import 'package:erent/login.dart';
import 'package:erent/home.dart';
import 'package:erent/register.dart';
import 'package:erent/test.dart';
//import 'package:map_view/map_view.dart';
void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {

 final routes = <String, WidgetBuilder>{
    '/login': (context) => Login(),
    '/home': (context) => Home(),
    '/register':(context) =>Register(),
    '/listhouseuser':(context) =>ListhouseUser(),
    '/profile':(context)=>Profile(),
    
  };
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eRent',
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      home:Login(),  
      routes: routes, 
    );
  }
}

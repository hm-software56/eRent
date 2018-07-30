import 'package:erent/home.dart';
import 'package:flutter/material.dart';
import 'package:erent/url_api.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  TextEditingController ctrlUsername = TextEditingController();
  TextEditingController ctrlPassword = TextEditingController();

  final GlobalKey<ScaffoldState> _scoffoldKey = new GlobalKey<ScaffoldState>();

  bool isLoading = false;
  

  
  Future<Null> checkLoginged() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await prefs.get('token');
    if (token != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Home()));
    }
  }

  @override
  void initState() {
    super.initState();
    checkLoginged();
  }

  Future<Null> doLogin() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.post('${UrlApi().url}/index.php/api/login',
        body: {'email': ctrlUsername.text, 'password': ctrlPassword.text});
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print(jsonResponse);
      setState(() {
        isLoading = false;
      });
      if (jsonResponse['id'] != null) {
        // set token to session
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('token', jsonResponse['id']);
        prefs.setString('username', jsonResponse['username']);
        prefs.setString('first_name', jsonResponse['first_name']);

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      } else {
        _scoffoldKey.currentState.showSnackBar(new SnackBar(
          backgroundColor: Colors.red,
          content: new Row(
            children: <Widget>[Text('ອິ​ເມວຫຼື​ລະ​ຫັດ​ຜ່ານ​ບໍ​ຖືກ​ຕ້ອງ​.....')],
          ),
        ));
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print('Error cooneted.....');
      showDialog<Null>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text('ອີນ​ເຕີ​ເນັດຜິດ​ພາດ'),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  new Text('ກວດ​ການ​ເຊື່ອມ​ຕໍ່​ເນັດ​ທ່ານ........'),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text(
                  '​ຕົ​ກ​ລົງ',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  /*void _doLogin() {
    print(ctrlUsername.text);
    print(ctrlPassword.text);

    if (ctrlUsername.text == "admin" && ctrlPassword.text == 'admin') {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Home()));
    }
  }*/

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/img/logo.jpg'),
      ),
    );

    final email = TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return '​ທ່ານ​ຕ້ອງ​ປ້ອນ​ອິ​ເມວ';
        }
      },
      controller: ctrlUsername,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: "Email Address",
        prefixIcon: Icon(Icons.email),
        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );

    final password = TextFormField(
      controller: ctrlPassword,
      obscureText: true,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.vpn_key),
        labelText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );

    final loginButton = Material(
      borderRadius: BorderRadius.circular(10.0),
      shadowColor: Colors.lightBlueAccent.shade100,
      elevation: 5.0,
      child: MaterialButton(
        minWidth: 200.0,
        height: 42.0,
        onPressed: () {
          doLogin();
        },
        color: Colors.lightBlueAccent,
        child: Text('​ເຂົ້າ​ລະ​ບົບ', style: TextStyle(color: Colors.white)),
      ),
    );

    final forgotLabel = Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: FlatButton(
                child: Text(
                  '​ລົງ​ທະ​ບຽນ',
                  style: TextStyle(color: Colors.black54),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/register');
                },
              ),
            ),
            Expanded(
              child: FlatButton(
                child: Text(
                  'ລືມ​ລະ​ຫັດ​ຜ່ານ.?',
                  style: TextStyle(color: Colors.black54),
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );

    return Form(
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scoffoldKey,
        body: Center(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            children: <Widget>[
              logo,
              email,
              Padding(
                padding: EdgeInsets.only(top: 15.0),
              ),
              password,
              Padding(
                padding: EdgeInsets.only(top: 15.0),
              ),
              loginButton,
              Padding(
                padding: EdgeInsets.only(top: 15.0),
              ),
              forgotLabel,
              Padding(
                padding: EdgeInsets.only(top: 15.0),
              ),
              Center(child: isLoading ? CircularProgressIndicator() : null),
            ],
          ),
        ),
      ),
    );
  }
}

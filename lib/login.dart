import 'package:erent/home.dart';
import 'package:erent/translations.dart';
import 'package:flutter/material.dart';
import 'package:erent/url_api.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  Translations localized = Translations();
  Future loadlang() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    localized.getlang = await prefs.get('lang');
    if (localized.lang != null && localized.getlang != localized.lang) {
      prefs.setString('lang', localized.lang);
      print('aaaaa');
      setState(() {
        localized.getlang = localized.lang;
      });
    } else {
      print('ddddd');
      if (localized.getlang == null) {
        prefs.setString('lang', localized.lanngdefault);
        setState(() {
          localized.getlang = localized.lanngdefault;
        });
      }
    }

    print(localized.getlang);
    String jsonContent =
        await rootBundle.loadString("locale/${localized.getlang}.json");
    setState(() {
      localized.translate = json.decode(jsonContent);
    });
  }

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
    loadlang();
  }

  Future<Null> doLogin() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.post('${UrlApi().url}/index.php/api/login',
        body: {'email': ctrlUsername.text, 'password': ctrlPassword.text});
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      //print(jsonResponse);
      setState(() {
        isLoading = false;
      });
      if (jsonResponse['id'] != null) {
        // set token to session
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('token', jsonResponse['id']);
        prefs.setString('username', jsonResponse['username']);
        prefs.setString('first_name', jsonResponse['first_name']);
        prefs.setString('photo_profile', jsonResponse['photo_profile']);
        prefs.setString('photo_bg', jsonResponse['photo_bg']);

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
            title: Center(child: new Text('ອີນ​ເຕີ​ເນັດຜິດ​ພາດ')),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  Center(child: new Text('ກວດ​ເບີ່ງການ​ເຊື່ອມ​ຕໍ່​ເນັດ​ທ່ານ')),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text(
                  'ປິດ>>',
                  style: TextStyle(color: Colors.red, fontSize: 20.0),
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

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/img/logo.png'),
      ),
    );

    final email = TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return localized.list(localized.translate, 'Input your email');
        }
      },
      controller: ctrlUsername,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: localized.list(localized.translate, 'Email or Phome'),
        ////prefixIcon: Icon(Icons.email),
        //contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        // border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );

    final password = TextFormField(
      controller: ctrlPassword,
      obscureText: true,
      decoration: InputDecoration(
        // prefixIcon: Icon(Icons.vpn_key),
        labelText: localized.list(localized.translate, 'Password'),
        // contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
        // border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
    );

    final loginButton = Material(
      borderRadius: BorderRadius.circular(5.0),
      //shadowColor: Colors.red,
      elevation: 5.0,
      child: MaterialButton(
        minWidth: 200.0,
        height: 42.0,
        onPressed: () {
          doLogin();
        },
        color: Colors.red,
        child: Text(localized.list(localized.translate, 'Login'),
            style: TextStyle(color: Colors.white)),
      ),
    );

    final forgotLabel = Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: FlatButton(
                child: Text(
                  localized.list(localized.translate, 'Register'),
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
                  localized.list(localized.translate, 'Forget password.?'),
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
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: localized.lang,
                  isDense: true,
                  onChanged: (String newValue) {
                    setState(() {
                      localized.lang = newValue;
                    });

                    loadlang();
                  },
                  items: ['la', 'en'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
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

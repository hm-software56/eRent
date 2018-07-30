import 'dart:async';
import 'package:erent/login.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  var gettoken;
  var getusername;
  var getfirstname;

  Future<Null> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await prefs.get('token');
    var datauser = await prefs.get('username');
    var firstname = await prefs.get('first_name');

    setState(() {
      gettoken = token;
      getusername = datauser;
      getfirstname = firstname;
    });
  }

  @override
  void initState() {
    super.initState();
    getToken();
  }

  Future<Null> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    // Navigator.of(context).pushNamed('/login');
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Login()));
  }

  @override
  Widget build(BuildContext context) {
    Widget appBar = AppBar(
      title: Text('ໜ້າ​ຫຼັກ'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.settings_power),
          onPressed: () {
            logOut();
          },
        )
      ],
    );

    Widget drawer = Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/img/bg.jpg'), fit: BoxFit.fill),
            ),
            currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/img/user.jpg')),
            accountName: Text(
              '$getfirstname',
              style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            accountEmail: Text(
              '$getusername',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.store,
              color: Colors.blue,
            ),
            title: Text(
              '​ໂຄ​ສະ​ນາ​ເຮືອ​ນ',
              style: TextStyle(fontSize: 20.0),
            ),
            subtitle: Text(
              'ຈັດ​ການ​ໂຄ​ສະ​ນາເຮຶອນຂອງ​ຕົ້ນ​ເອງ',
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.account_circle,
              color: Colors.blue,
            ),
            title: Text(
              'ໂປ​ຣ​ໄຟ',
              style: TextStyle(fontSize: 20.0),
            ),
            subtitle: Text(
              'ຈັດ​ການໂປ​ຣ​ໄຟຂອງ​ຕົ້ນ​ເອງ',
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.assessment,
              color: Colors.blue,
            ),
            title: Text(
              'ຜົນ​ທີ​ໄດ້​ຮັບ',
              style: TextStyle(fontSize: 20.0),
            ),
            subtitle: Text(
              '​ອະ​ທີ​ບາຍ​ຜົນ​ທີ​ໄດ້​ຮັບ',
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.settings_applications,
              color: Colors.blue,
            ),
            title: Text(
              'ຕັ້​ງ​ຄ່າ',
              style: TextStyle(fontSize: 20.0),
            ),
            subtitle: Text(
              '​ຈັດ​ການ​ການ​ຕັ້ງ​ຄ່າ​ຕ່າງ​',
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            trailing: Icon(
              Icons.exit_to_app,
              color: Colors.red,
            ),
            title: Text('ປິດ'),
            onTap: () {
              exit(0);
            },
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: Text('$gettoken'),
      drawer: drawer,
    );
  }
}

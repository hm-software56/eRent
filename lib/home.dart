import 'dart:async';
import 'dart:convert';
import 'package:erent/login.dart';
import 'package:erent/url_api.dart';
import 'package:erent/viewhouse.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
    getlisthouses();
  }

  Future<Null> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    // Navigator.of(context).pushNamed('/login');
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Login()));
  }

  /// get List house
  var listhouses;
  bool isLoading = true;

  Future<Null> getlisthouses() async {
    final response = await http.get('${UrlApi().url}/index.php/api/listhouse');

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      //print(jsonResponse);

      setState(() {
        isLoading = false;
        listhouses = jsonResponse['rows'];
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Error cooneted.');
      showDialog<Null>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Center(
                child: new Text(
              'ອີນ​ເຕີ​ເນັດຜິດ​ພາດ',
            )),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  Center(
                      child:
                          new Text('ກວດເບີ່ງ​ການ​​ເຊື່ອມ​ຕໍ່​ເນັດ​ຂອງ​ທ່ານ')),
                  FlatButton(
                    child: Center(
                      child: new Text(
                        '​ປິດ>>',
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
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
            onTap: () {
               Navigator.of(context).pushNamed('/listhouseuser');
            },
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: getlisthouses,
              child: ListView.builder(
                itemBuilder: (context, int index) {
                  var per = (listhouses[index]['per'] == "m") ? "ເດືອນ" : "ປີ";
                  return Column(
                    children: <Widget>[
                      ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ViewHouse(listhouses[index]['id'],listhouses[index]['did'])));
                        },
                        leading: Image(
                          image: NetworkImage(
                            '${UrlApi().url}/images/'
                                '${listhouses[index]['photo_name']}',
                          ),
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                        ),
                        title: Text('${listhouses[index]['type_name']}'),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${listhouses[index]['details']}',
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                maxLines: 2,
                              ),
                              (listhouses[index]['dstatus'] == '1')
                                  ? Text(
                                      'ຫວ່າງ',
                                      style: TextStyle(color: Colors.green),
                                    )
                                  : Text(
                                      '​ບໍ່ຫວ່າງ',
                                      style: TextStyle(color: Colors.red),
                                    ),
                              Text('ລາ​ຄາ:${listhouses[index]['fee']}/$per')
                            ]),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      ),
                      Divider()
                    ],
                  );
                },
                itemCount: listhouses != null ? listhouses.length : 0,
              ),
            ),
      drawer: drawer,
    );
  }
}

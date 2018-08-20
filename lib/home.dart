import 'dart:async';
import 'dart:convert';
import 'package:erent/login.dart';
import 'package:erent/url_api.dart';
import 'package:erent/viewhouse.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_one_signal/flutter_one_signal.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Home extends StatefulWidget {
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  var gettoken;
  var getusername;
  var getfirstname;

/* ====================== Onsigal Push notifycation ============================= */
  _initOneSignal() async {
    var notificationsPermissionGranted = await FlutterOneSignal.startInit(
        appId: '321b77aa-e8ff-4922-a91f-c6a9ed89bffe',
        // todo Replace with your own, this won't work for you
        notificationOpenedHandler: (notification) {
          print('opened notification: $notification');
          Navigator.of(context).pushNamed('/home');
        },
        notificationReceivedHandler: (notification) {
          print('received notification: $notification');
        });
    FlutterOneSignal.sendTag('userId', 'demoUserId');
    var payerID = await FlutterOneSignal.getUserId();

    Dio dio = new Dio();
    dio.options.connectTimeout = 5000; //5s
    dio.options.receiveTimeout = 3000;

    FormData formData = new FormData.from({
      'payerID': payerID,
    });
    var response = await dio.post(
        "${UrlApi().url}/index.php/api/userpayer?id=${gettoken}",
        data: formData);
    //print(response);
  }

  /*======================Get User Login ========================*/
  Future<Null> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await prefs.get('token');
    var datauser = await prefs.get('username');
    var firstname = await prefs.get('first_name');

    setState(() {
      gettoken = token;
      getusername = datauser;
      getfirstname = firstname;
      _initOneSignal();
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

  /*======================= get List house =========================*/
  var listhouses;
  bool isLoading = true;
  var listhousesApi;
  int alertcount = 0;
  Future<Null> getlisthouses() async {
    final response = await http.get('${UrlApi().url}/index.php/api/listhouse');

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      Dio dio = new Dio();
      dio.options.connectTimeout = 5000; //5s
      dio.options.receiveTimeout = 3000;
      var responsecountalert = await dio
          .post("${UrlApi().url}/index.php/api/countalert?userid=${gettoken}");
      //print(responsecountalert.data);
      setState(() {
        isLoading = false;
        listhouses = jsonResponse['rows'];
        listhousesApi = jsonResponse['rows'];
        alertcount = int.parse(responsecountalert.data);
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

//============== Search Appbar ================
  Widget appBarTitle = new Text("ໜ້າ​ຫຼັກ");
  Icon actionIcon = new Icon(Icons.search);
  final TextEditingController _searchQuery = new TextEditingController();
  var listsearchhouse;
  bool ischeaching = false;
  _SearchListState() {
    if (_searchQuery.text.isEmpty) {
      setState(() {
        print('Search text empyt');
        if (ischeaching == true) {
          listhouses = listhousesApi;
        }
      });
    } else {
      setState(() {
        List _listsearch = new List();
        for (var item in listhousesApi) {
          if (item['details']
                  .toLowerCase()
                  .contains(_searchQuery.text.toLowerCase()) ||
              item['fee']
                  .toLowerCase()
                  .contains(_searchQuery.text.toLowerCase()) ||
              item['type_name']
                  .toLowerCase()
                  .contains(_searchQuery.text.toLowerCase())) {
            _listsearch.add(item);
          }
        }
        listhouses = _listsearch.toSet().toList();
        //print(listsearchhouse);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget appBar = AppBar(
      title: appBarTitle,
      actions: <Widget>[
        /*  ===============  Search ===============*/
        IconButton(
          icon: actionIcon,
          onPressed: () {
            setState(() {
              if (this.actionIcon.icon == Icons.search) {
                this.actionIcon = new Icon(Icons.close);
                this.appBarTitle = new TextField(
                  onChanged: (text) {
                    _SearchListState();
                  },
                  controller: _searchQuery,
                  style: new TextStyle(
                    color: Colors.white,
                  ),
                  decoration: new InputDecoration(
                      fillColor: Colors.greenAccent,
                      prefixIcon: new Icon(Icons.search, color: Colors.white),
                      hintText: "​ຄົ້ນ​ຫາ...",
                      hintStyle: new TextStyle(color: Colors.white)),
                );
                _SearchListState();
                ischeaching = true;
              } else {
                ischeaching = false;
                _searchQuery.clear();
                this.actionIcon = new Icon(Icons.search);
                this.appBarTitle = new Text("ໜ້າ​ຫຼັກ");
              }
            });
          },
        ),
        /*==================Alert Push ===============*/
        (alertcount != 0)
            ? IconButton(
                icon: new Stack(
                  children: <Widget>[
                    new Icon(
                      Icons.add_alert,
                      size: 30.0,
                    ),
                    new Positioned(
                      height: 20.0,
                      width: 20.0,
                      top: 1.0,
                      right: 0.0,
                      child: new Stack(
                        children: <Widget>[
                          new Icon(Icons.brightness_1,
                              // size: 15.0,
                              color: Colors.green[800]),
                          new Positioned(
                            top: 5.0,
                            right: 2.0,
                            child: new Text('${alertcount}',
                                style: new TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w500)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/listhouseuser');
                },
              )
            : Text(''),
      ],
    );

//================== menu left ========================
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
              Icons.settings_power,
              color: Colors.red,
            ),
            title: Text(
              'ອອກ​ຈາກ​ລະ​ບົບ',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            onTap: () {
              logOut();
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
                                  builder: (context) => ViewHouse(
                                      listhouses[index]['id'],
                                      listhouses[index]['did'])));
                        },
                        leading: CachedNetworkImage(
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                          imageUrl: '${UrlApi().url}/images/small/'
                              '${listhouses[index]['photo_name']}',
                          placeholder: new CircularProgressIndicator(),
                          errorWidget: new Icon(Icons.error),
                        ),
                        /* Image(
                          image: (listhouses[index]['photo_name'] == null)
                              ? AssetImage('assets/img/logo.jpg')
                              : NetworkImage(
                                  '${UrlApi().url}/images/small/'
                                      '${listhouses[index]['photo_name']}',
                                ),
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                        ),*/
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

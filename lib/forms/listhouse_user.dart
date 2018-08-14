import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:erent/forms/properties_form.dart';
import 'package:erent/forms/properties_formedit.dart';
import 'package:erent/forms/viewproperties.dart';
import 'package:http/http.dart' as http;

import 'package:erent/url_api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListhouseUser extends StatefulWidget {
  ListhouseUserState createState() => ListhouseUserState();
}

class ListhouseUserState extends State<ListhouseUser> {
  bool isLoading = true;
  var listhouse;

  final GlobalKey<ScaffoldState> _scoffoldKey = new GlobalKey<ScaffoldState>();
  Future<Null> getlisthouses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = await prefs.get('token');
    final response = await http
        .get('${UrlApi().url}/index.php/api/listhouseuser?id=${userid}');

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      //print(jsonResponse);

      setState(() {
        isLoading = false;
        listhouse = jsonResponse['rows'];
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Error cooneted.ddd....');
      showDialog<Null>(
        context: context,
        barrierDismissible: true, // user must tap button!
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

  Future getdelete(var houseID) async {
    Dio dio = new Dio();
    Response response = await dio
        .delete("${UrlApi().url}/index.php/api/propertiesdelet?id=${houseID}");

    _scoffoldKey.currentState.showSnackBar(new SnackBar(
      backgroundColor: Colors.red,
      content: new Row(
        children: <Widget>[Text('ລາຍ​ກາ​ນ​ຖືກ​ລືບ​ແລ້ວ.....')],
      ),
    ));
    setState(() {
      getlisthouses();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getlisthouses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scoffoldKey,
      appBar: AppBar(
        title: Text('ໂຄ​ສະ​ນາ​ເຮືອ​ນ'),
        actions: <Widget>[
          IconButton(
            color: Colors.white,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => PropertiesForm()));
            },
            icon: Icon(Icons.add_box),
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: getlisthouses,
              child: ListView.builder(
                itemBuilder: (context, int index) {
                  var per = (listhouse[index]['per'] == "m") ? "ເດືອນ" : "ປີ";
                  return Column(
                    children: <Widget>[
                      ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  fullscreenDialog: true,
                                  builder: (context) => ViewProperties(
                                      listhouse[index]['id'],
                                      listhouse[index]['did'])));
                        },
                        leading: Image(
                          image: (listhouse[index]['photo_name'] == null)
                              ? AssetImage('assets/img/logo.jpg')
                              : NetworkImage(
                                  '${UrlApi().url}/images/small/'
                                      '${listhouse[index]['photo_name']}',
                                ),
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                        ),
                        title: Text('${listhouse[index]['type_name']}'),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${listhouse[index]['details']}',
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                maxLines: 2,
                              ),
                              (listhouse[index]['dstatus'] == '1')
                                  ? Text(
                                      'ຫວ່າງ',
                                      style: TextStyle(color: Colors.green),
                                    )
                                  : Text(
                                      '​ບໍ່ຫວ່າງ',
                                      style: TextStyle(color: Colors.red),
                                    ),
                              Text('ລາ​ຄາ:${listhouse[index]['fee']}/$per'),
                            ]),
                        trailing: Column(children: <Widget>[
                          IconButton(
                            color: Colors.red,
                            icon: Icon(Icons.delete_forever),
                            onPressed: () {
                              getdelete(listhouse[index]['id']);
                            },
                          ),
                          Text(''),
                          IconButton(
                            color: Colors.blue,
                            icon: Icon(Icons.border_color),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      fullscreenDialog: true,
                                      builder: (context) => PropertiesFormedit(
                                          listhouse[index]['id'],
                                          listhouse[index]['did'])));
                            },
                          ),
                        ]),
                      ),
                      Divider()
                    ],
                  );
                },
                itemCount: listhouse != null ? listhouse.length : 0,
              ),
            ),
    );
  }
}

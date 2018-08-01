import 'dart:async';
import 'dart:convert';
import 'package:erent/forms/viewproperties.dart';
import 'package:erent/viewhouse.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getlisthouses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ໂຄ​ສະ​ນາ​ເຮືອ​ນ'),
        actions: <Widget>[
          IconButton(
            color: Colors.white,
            onPressed: () {},
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
                          image: NetworkImage(
                            '${UrlApi().url}/images/'
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
                              Text('ລາ​ຄາ:${listhouse[index]['fee']}/$per')
                            ]),
                        trailing: Icon(Icons.keyboard_arrow_right),
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

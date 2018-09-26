import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:erent/comment.dart';
import 'package:erent/forms/properties_form.dart';
import 'package:erent/forms/properties_formedit.dart';
import 'package:erent/forms/viewproperties.dart';
import 'package:erent/translations.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:erent/url_api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money/money.dart';

class ListhouseUser extends StatefulWidget {
  ListhouseUserState createState() => ListhouseUserState();
}

class ListhouseUserState extends State<ListhouseUser> {
  bool isLoading = true;
  var listhouse;
  var userID;
  
  /*============= translate function ====================*/
  Translations localized = Translations();
  Future loadlang() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    localized.getlang = await prefs.get('lang');
    if (localized.lang != null && localized.getlang != localized.lang) {
      prefs.setString('lang', localized.lang);
      setState(() {
        localized.getlang = localized.lang;
      });
    } else {
      if (localized.getlang == null) {
        prefs.setString('lang', localized.lanngdefault);
        setState(() {
          localized.getlang = localized.lanngdefault;
        });
      }
    }
    String jsonContent =
        await rootBundle.loadString("locale/${localized.getlang}.json");
    setState(() {
      localized.translate = json.decode(jsonContent);
    });
  }


  final GlobalKey<ScaffoldState> _scoffoldKey = new GlobalKey<ScaffoldState>();
  Future<Null> getlisthouses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = await prefs.get('token');
    final response = await http
        .get('${UrlApi().url}/index.php/api/listhouseuser?id=${userid}');

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      setState(() {
        isLoading = false;
        listhouse = jsonResponse['rows'];
        userID = userid;
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
                  localized.list(localized.translate, 'Error connection'),
            )),
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  Center(
                      child:
                          new Text(localized.list(localized.translate, 'Please check your connection'))),
                  FlatButton(
                    child: Center(
                      child: new Text(
                        localized.list(localized.translate, 'Close>>'),
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
        children: <Widget>[
          Text(localized.list(localized.translate, 'Item have been deleted'))
          ],
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
    loadlang();
    getlisthouses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scoffoldKey,
      appBar: AppBar(
        title: Text(localized.list(localized.translate, 'Advertise house')),
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
                  var per = (listhouse[index]['per'] == "m") ? localized.list(localized.translate, 'Month') :localized.list(localized.translate, 'Year');
                 // int a=listhouse[index]['fee'];
                  //final money = Money(a, Currency('USD'));
                  return Column(
                    children: <Widget>[
                      ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  fullscreenDialog: true,
                                  builder: (context) => ViewProperties(
                                      int.parse(listhouse[index]['id']),
                                          int.parse(listhouse[index]['did']))));
                        },
                        leading: CachedNetworkImage(
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                          imageUrl: '${UrlApi().url}/images/small/'
                              '${listhouse[index]['photo_name']}',
                          placeholder: new CircularProgressIndicator(),
                          errorWidget: new Icon(Icons.error),
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
                                      localized.list(localized.translate, 'Invariable'),
                                      style: TextStyle(color: Colors.green),
                                    )
                                  : Text(
                                      localized.list(localized.translate, 'Not invariable'),
                                      style: TextStyle(color: Colors.red),
                                    ),
                              Text(localized.list(localized.translate, 'Price')+':${listhouse[index]['fee']} ${listhouse[index]['currency_name']}/$per'),
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
                                          int.parse(listhouse[index]['id']),
                                          int.parse(listhouse[index]['did']))));
                            },
                          ),
                        ]),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                  // label: Text('Like(${nbcount})'),
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.thumb_up,
                                    color: (listhouse[index]['likeProperties']
                                                .length !=
                                            0)
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                ),
                                Text(
                                    localized.list(localized.translate, 'Like')+'(${listhouse[index]['likeProperties'].length})',
                                    style: TextStyle(fontSize: 10.0))
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            fullscreenDialog: true,
                                            builder: (context) => Comment(
                                                listhouse[index]['id']
                                                )));
                                  },
                                  icon: Icon(
                                    Icons.comment,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  localized.list(localized.translate, 'Comment')+'(${listhouse[index]['comments'].length})',
                                  style: TextStyle(fontSize: 10.0),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.calendar_today,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                 localized.list(localized.translate, 'Time table'),
                                  style: TextStyle(fontSize: 10.0),
                                )
                              ],
                            ),
                          ),
                        ],
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

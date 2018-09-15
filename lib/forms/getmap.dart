import 'dart:async';

import 'package:dio/dio.dart';
import 'package:erent/url_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plugin_webview/webview_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetMap extends StatefulWidget {
  @override
  _GetMapState createState() => _GetMapState();
}

class _GetMapState extends State<GetMap> {
  var userID;
  getuserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await prefs.get('token');
    setState(() {
      userID = token;
    });
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    getuserID();
  }

  @override
  Future getlatlong() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Dio dio = Dio();
    final response = await dio
        .get('${UrlApi().url}/index.php/api/getlatlong?user_id=${userID}');
    if (response.statusCode == 200) {
      print(response.data);
      prefs.setString('lat', response.data['lat']);
      prefs.setString('long', response.data['long']);
    }
  }

  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.red, 
        ),
        home: (userID == null)
            ? Center(child: CircularProgressIndicator())
            : WebViewScaffold(
                url: "${UrlApi().url}/index.php/api/getmap?user_id=${userID}",
                appBar: AppBar(
                  title: Text('ແຜ່ນ​ທີ່'),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        getlatlong();
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ),
      );
}

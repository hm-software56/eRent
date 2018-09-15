import 'package:erent/url_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_plugin_webview/webview_scaffold.dart';

class ViewMap extends StatefulWidget{
  var houseID;
  ViewMapState createState()=>  ViewMapState(houseID);
  ViewMap(this.houseID);
}


class ViewMapState extends State<ViewMap> {
  var houseID;
  ViewMapState(this.houseID);
  
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: new ThemeData(
          primarySwatch: Colors.red,
        ),
        home: (houseID == null)
            ? Center(child: CircularProgressIndicator())
            : WebViewScaffold(
                url: "${UrlApi().url}/index.php/api/viewmap?id=${houseID}",
                appBar: AppBar(
                  title: Text('ແຜ່ນ​ທີ່'),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ),
      );
}
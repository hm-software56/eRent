import 'dart:async';
import 'dart:convert';

import 'package:erent/url_api.dart';
import 'package:flutter/material.dart';
import 'package:parallax_image/parallax_image.dart';
import 'package:http/http.dart' as http;

class ViewPhoto extends StatefulWidget {
  var did;
  ViewPhoto(this.did);
  ViewPhotoState createState() => ViewPhotoState(this.did);
}

class ViewPhotoState extends State<ViewPhoto> {
  var did;
  ViewPhotoState(this.did);

  var photos;
  bool isLoading = true;
  Future<Null> getPhoto() async {
    final response =
        await http.get('${UrlApi().url}/index.php/api/photos?did=${did}');
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print(jsonResponse);

      setState(() {
        isLoading = false;
        photos = jsonResponse['photos'];
      });
    } else {
      print('Error cooneted.....');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPhoto();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return new Scaffold(
      appBar: new AppBar(title: new Text('llll')),
      body: new Column(
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.all(20.0),
            child: new Text(
              'ssssss',
              style: theme.textTheme.title,
            ),
          ),
          new Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              constraints: const BoxConstraints(maxHeight: 400.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: new ParallaxImage(
                      extent: 300.0,
                      image:NetworkImage(
                            '${UrlApi().url}/images/'
                                '${photos[index]['name']}',
                          ),
                    ),
                  );
                },
                itemCount: photos != null ? photos.length : 0,
              )),
        ],
      ),
    );
  }
}

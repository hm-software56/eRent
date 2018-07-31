import 'dart:async';
import 'dart:convert';

import 'package:erent/url_api.dart';
import 'package:erent/viewphoto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ViewHouse extends StatefulWidget {
  var houseID;
  ViewHouse(this.houseID);

  ViewHouseState createState() => ViewHouseState(this.houseID);
}

class ViewHouseState extends State<ViewHouse> {
  var houseID;
  ViewHouseState(this.houseID);

  /// get List house
  var detailhouse;
  var photos;
  bool isLoading = true;

  Future<Null> getDetailhouse() async {
    final response = await http
        .get('${UrlApi().url}/index.php/api/detailhouse?id=${houseID}');

    /*final responsephoto =
        await http.get('${UrlApi().url}/index.php/api/photos?did=${detailID}');*/
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      // var jsonResponsephoto = json.decode(responsephoto.body);
      print(jsonResponse);
      //  print(jsonResponsephoto);

      setState(() {
        isLoading = false;
        detailhouse = jsonResponse['rows'];
        //  photos = jsonResponsephoto['photos'];
      });
    } else {
      print('Error cooneted.....');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDetailhouse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("​ລາຍ​ລະ​ອຽດ​ເຮືອນ")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: <Widget>[
                  Text(
                    '${detailhouse[0]['type_name']}',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (context) =>
                                  ViewPhoto(detailhouse[0]['did'])));
                    },
                    child: Image(
                      fit: BoxFit.cover,
                      height: 250.0,
                      image: NetworkImage(
                        '${UrlApi().url}/images/'
                            '${detailhouse[0]['photo_name']}',
                      ),
                    ),
                  ),
                  Text('${detailhouse[0]['details']}${detailhouse[0]['id']}')
                ],
              ),
            ),
    );
  }
}

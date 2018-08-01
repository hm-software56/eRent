import 'dart:async';
import 'dart:convert';

import 'package:erent/url_api.dart';
import 'package:erent/viewphoto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel/carousel.dart';

class ViewHouse extends StatefulWidget {
  var houseID;
  var detailID;
  ViewHouse(this.houseID, this.detailID);

  ViewHouseState createState() => ViewHouseState(this.houseID, this.detailID);
}

class ViewHouseState extends State<ViewHouse> {
  var houseID;
  var detailID;

  ViewHouseState(this.houseID, this.detailID);

  /// get List house
  var detailhouse;
  var listphotos;
  bool isLoading = true;
  List ListPhoroCarousel = List();

  Future<Null> getDetailhouse() async {
    final response = await http
        .get('${UrlApi().url}/index.php/api/detailhouse?id=${houseID}');

    final responsephoto =
        await http.get('${UrlApi().url}/index.php/api/photos?did=${detailID}');
    if (response.statusCode == 200  && responsephoto.statusCode == 200 ) {
      var jsonResponse = json.decode(response.body);
      var jsonResponsephoto = json.decode(responsephoto.body);

      // print(jsonResponse);
      // print(jsonResponsephoto);

      setState(() {
        isLoading = false;
        detailhouse = jsonResponse['rows'];
        listphotos = jsonResponsephoto['photos'];
        // List ListPhoroCarousel = List();
        for (var item in listphotos) {
          ListPhoroCarousel
              .add(NetworkImage('${UrlApi().url}/images/${item['name']}'));
        }
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
                  (ListPhoroCarousel.length > 1)
                      ? SizedBox(
                          height: 240.0,
                          child: Container(
                            child: Carousel(
                              displayDuration: Duration(seconds: 10),
                              children: ListPhoroCarousel
                                  .map((netImage) => GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                fullscreenDialog: true,
                                                builder: (context) =>
                                                    ViewPhoto(netImage)));
                                      },
                                      child: Image(
                                          image: netImage, fit: BoxFit.fill)))
                                  .toList(),
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    fullscreenDialog: true,
                                    builder: (context) => ViewPhoto(NetworkImage(
                                        '${UrlApi().url}/images/${detailhouse[0]['photo_name']}'))));
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
                  Divider(),
                  Text('${detailhouse[0]['details']}'),
                  (detailhouse[0]['dstatus'] == '1')
                      ? Text(
                          'ຫວ່າງ',
                          style: TextStyle(color: Colors.green),
                        )
                      : Text(
                          '​ບໍ່ຫວ່າງ',
                          style: TextStyle(color: Colors.red),
                        ),
                  Text('ລາ​ຄາ:${detailhouse[0]['fee']}/${(detailhouse[0]['per'] == "m") ? "ເດືອນ" : "ປີ"}')
                ],
              ),
            ),
    );
  }
}

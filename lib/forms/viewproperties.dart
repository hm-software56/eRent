import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:erent/forms/package.dart';
import 'package:erent/forms/properties_formedit.dart';
import 'package:erent/translations.dart';
import 'package:erent/url_api.dart';
import 'package:erent/view_map.dart';
import 'package:erent/viewphoto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewProperties extends StatefulWidget {
  int houseID;
  int detailID;
  ViewProperties(this.houseID, this.detailID);

  ViewPropertiesState createState() =>
      ViewPropertiesState(this.houseID, this.detailID);
}

class ViewPropertiesState extends State<ViewProperties> {
  int houseID;
  int detailID;

  ViewPropertiesState(this.houseID, this.detailID);

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
    if (response.statusCode == 200 && responsephoto.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var jsonResponsephoto = json.decode(responsephoto.body);

      //print(jsonResponse);
       //print(jsonResponsephoto);

      setState(() {
        isLoading = false;
        detailhouse = jsonResponse['rows'];
        listphotos = jsonResponsephoto['photos'];
        // List ListPhoroCarousel = List();
        for (var item in listphotos) {
          ListPhoroCarousel.add('${UrlApi().url}/images/small/${item['name']}');
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadlang();
    getDetailhouse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(localized.list(localized.translate, 'House details')),
          actions: <Widget>[
            IconButton(
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) =>
                            PropertiesFormedit('${houseID}', '${detailID}')));
              },
              icon: Icon(Icons.border_color),
            )
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : (detailhouse != null)
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: <Widget>[
                        Text(
                          '${detailhouse[0]['type_name']}',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        (ListPhoroCarousel.length > 1)
                            ? SizedBox(
                                height: 240.0,
                                child: Container(
                                  child: CarouselSlider(
                                    // displayDuration: Duration(seconds: 10),
                                    items: ListPhoroCarousel.map((netImage) =>
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    fullscreenDialog: true,
                                                    builder: (context) =>
                                                        ViewPhoto(netImage)));
                                          },
                                          child: CachedNetworkImage(
                                            fit: BoxFit.contain,
                                            imageUrl: netImage,
                                            placeholder:
                                                new CircularProgressIndicator(),
                                            errorWidget:
                                                new Icon(Icons.error),
                                          ),
                                        )).toList(),
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          fullscreenDialog: true,
                                          builder: (context) => ViewPhoto(
                                              NetworkImage(
                                                  '${UrlApi().url}/images/${detailhouse[0]['photo_name']}'))));
                                },
                                child: CachedNetworkImage(
                                  imageUrl:
                                      '${UrlApi().url}/images/${detailhouse[0]['photo_name']}',
                                  placeholder: new CircularProgressIndicator(),
                                  errorWidget: new Icon(Icons.error),
                                ),
                              ),
                        FlatButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewMap(houseID)));
                    },
                    label: Text(
                      localized.list(localized.translate, 'View Map'),
                      style: TextStyle(color: Colors.white),
                    ),
                    icon: Icon(
                      Icons.location_on,
                      color: Colors.white,
                    ),
                    color: Colors.red,
                  ),
                        Divider(),
                        Text('${detailhouse[0]['details']}'),
                        (detailhouse[0]['dstatus'] == '1')
                            ? Text(
                                localized.list(localized.translate, 'Invariable'),
                                style: TextStyle(color: Colors.green),
                              )
                            : Text(
                                localized.list(localized.translate, 'Not invariable'),
                                style: TextStyle(color: Colors.red),
                              ),
                        Text(
                            localized.list(localized.translate, 'Price')+':${detailhouse[0]['fee']} ${detailhouse[0]['currency_name']}/${(detailhouse[0]['per'] == "m") ? localized.list(localized.translate, 'Month') : localized.list(localized.translate, 'Year')}'),
                        Divider(),
                        (detailhouse[0]['status'] == '0')
                            ? Text(
                                localized.list(localized.translate, 'Status')+":"+localized.list(localized.translate, 'Pedding'),
                                style: TextStyle(color: Colors.red),
                              )
                            : (detailhouse[0]['status'] == '1')
                                ? Text(
                                    localized.list(localized.translate, 'Status')+":"+localized.list(localized.translate, 'Publish'),
                                    style: TextStyle(color: Colors.green),
                                  )
                                : Text(
                                    localized.list(localized.translate, 'Status')+":"+localized.list(localized.translate, 'Expired'),
                                    style: TextStyle(color: Colors.red),
                                  ),
                        Text(localized.list(localized.translate, 'Start date')+': ${detailhouse[0]['date_start']}'),
                        Text(
                            localized.list(localized.translate, 'End date')+': ${detailhouse[0]['date_end']}'),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: getDetailhouse,
                    child: ListView(children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 250.0),
                        child:
                            Center(child: Text(localized.list(localized.translate, 'Scroll up refresh'))),
                      )
                    ]),
                  ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => Package(houseID)));
            },
            tooltip: 'Toggle',
            child: Icon(Icons.attach_money)));
  }
}

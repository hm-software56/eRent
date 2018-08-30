import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:erent/comment.dart';
import 'package:erent/url_api.dart';
import 'package:erent/view_map.dart';
import 'package:erent/viewphoto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:carousel/carousel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  var UserID;
  var getFirstname;
  List ListPhoroCarousel = List();
  double long;
  double lat;
  int Countcomment;
  Future<Null> getDetailhouse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = await prefs.get('token');
    var firstname = await prefs.get('first_name');
    setState(() {
      UserID = userid;
      getFirstname = firstname;
    });

    final response = await http
        .get('${UrlApi().url}/index.php/api/detailhouse?id=${houseID}');

    final responsephoto =
        await http.get('${UrlApi().url}/index.php/api/photos?did=${detailID}');
    if (response.statusCode == 200 && responsephoto.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var jsonResponsephoto = json.decode(responsephoto.body);

      Dio dio = new Dio();
      final responseliked = await dio.get(
          "${UrlApi().url}/index.php/api/likecount?id=${houseID}&userid=${UserID}");
      final responseCountcomment = await dio.get(
          "${UrlApi().url}/index.php/api/countcomments?houseID=${houseID}");

      if (responseliked.statusCode == 200) {
        var nb = responseliked.data['nbcount'];
        setState(() {
          likeunlike = responseliked.data['like'];
          nbcount = nb;
          Countcomment=int.parse(responseCountcomment.data);
        });
      }

      setState(() {
        isLoading = false;
        detailhouse = jsonResponse['rows'];
        if (detailhouse[0]['longtitude'] == null ||
            detailhouse[0]['lattitude'] == null) {
          long = 18.625546;
          lat = 102.960681;
        } else {
          long = double.parse(detailhouse[0]['longtitude']);
          lat = double.parse(detailhouse[0]['lattitude']);
        }
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

  /* ================= favorite ======================*/
  int likeunlike = 1;
  var nbcount;
  Future Favorite(var houseID, var UserID) async {
    Dio dio = new Dio();
    Response response = await dio.get(
        "${UrlApi().url}/index.php/api/favorite?id=${houseID}&userid=${UserID}&like=${likeunlike}");
    if (response.statusCode == 200) {
      var nb = response.data['nbcount'];
      print(response.data['nbcount']);
      setState(() {
        likeunlike = response.data['like'];
        nbcount = nb;
      });
    }
  }

/*================ Add Comment ===========*/
  var commentInput;
  bool isComment = false;
  List listComment = List();
  addComment(var comment) async {
    //print(comment);
    Navigator.of(context).pop();

    Dio dio = new Dio();
    FormData formData = new FormData.from({
      'smg': comment,
      'userID': UserID,
      'houseID': houseID,
    });
    var response = await dio.post("${UrlApi().url}/index.php/api/addcomments",
        data: formData);
    if (response.statusCode == 200) {
      final responseList = await dio
          .get('${UrlApi().url}/index.php/api/listcomments?houseID=${houseID}');
      setState(() {
        listComment = responseList.data;
        Countcomment=1+Countcomment;
      });
      // print(response);
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
                                        child: CachedNetworkImage(
                                          imageUrl: netImage,
                                          placeholder:
                                              new CircularProgressIndicator(),
                                          errorWidget: new Icon(Icons.error),
                                        ),
                                      ))
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
                                    builder: (context) => ViewPhoto(
                                        '${UrlApi().url}/images/${detailhouse[0]['photo_name']}')));
                          },
                          child: Image(
                            fit: BoxFit.cover,
                            height: 250.0,
                            image: NetworkImage(
                              '${UrlApi().url}/images/small/'
                                  '${detailhouse[0]['photo_name']}',
                            ),
                          ),
                        ),
                  FlatButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewMap(long, lat)));
                    },
                    label: Text(
                      'view Map',
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
                          'ຫວ່າງ',
                          style: TextStyle(color: Colors.green),
                        )
                      : Text(
                          '​ບໍ່ຫວ່າງ',
                          style: TextStyle(color: Colors.red),
                        ),
                  Text(
                      'ລາ​ຄາ:${detailhouse[0]['fee']}/${(detailhouse[0]['per'] == "m") ? "ເດືອນ" : "ປີ"}'),
                  Divider(),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            IconButton(
                              // label: Text('Like(${nbcount})'),
                              onPressed: () {
                                Favorite(houseID, UserID);
                              },
                              icon: Icon(
                                Icons.thumb_up,
                                color: (likeunlike == 1)
                                    ? Colors.grey
                                    : Colors.red,
                              ),
                            ),
                            Text(
                              'Like(${nbcount})',
                              style: TextStyle(fontSize: 10.0),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    child: new AlertDialog(
                                      content: new TextField(
                                        maxLines: 2,
                                        keyboardType: TextInputType.multiline,
                                        decoration: new InputDecoration(
                                            labelText: "ປ້ອນ​ຄຳ​ເຫັນ"),
                                        onChanged: (String text) {
                                          commentInput = text;
                                          setState(() {
                                            isComment = true;
                                          });
                                        },
                                      ),
                                      actions: <Widget>[
                                        new FlatButton(
                                            child: (isComment)
                                                ? Icon(Icons.send,
                                                    color: Colors.blue)
                                                : Icon(Icons.send,
                                                    color: Colors.grey),
                                            onPressed: () {
                                              (isComment)
                                                  ? addComment(commentInput)
                                                  : '';
                                            })
                                      ],
                                    ));
                              },
                              icon: Icon(
                                Icons.comment,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Comment(${Countcomment})',
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
                              'ນັດເບີ່ງ​ເຮືອນ',
                              style: TextStyle(fontSize: 10.0),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  (listComment.length != 0)
                      ? Container(
                          width: 290.0,
                          height: 320.0,
                          child: ListView.builder(
                            itemCount: listComment.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: CircleAvatar(
                                    backgroundImage:
                                        AssetImage('assets/img/user.jpg')),
                                title: Text('${listComment[index]['user']['register']['first_name']}'),
                                subtitle: Text('${listComment[index]['smg']}'),
                              );
                            },
                          ),
                        )
                      : Text('')
                ],
              ),
            ),
    );
  }
}

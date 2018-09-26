import 'dart:async';
import 'dart:convert';
import 'package:erent/login.dart';
import 'package:erent/translations.dart';
import 'package:erent/url_api.dart';
import 'package:erent/viewhouse.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_one_signal/flutter_one_signal.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Home extends StatefulWidget {
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  var gettoken;
  var getusername;
  var getfirstname;
  var photo_profile;
  var photo_bg;

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

/* ====================== Onsigal Push notifycation ============================= */
  _initOneSignal() async {
    var notificationsPermissionGranted = await FlutterOneSignal.startInit(
        appId: '321b77aa-e8ff-4922-a91f-c6a9ed89bffe',
        // todo Replace with your own, this won't work for you
        notificationOpenedHandler: (notification) {
          print('opened notification: $notification');
          Navigator.of(context).pushNamed('/home');
        },
        notificationReceivedHandler: (notification) {
          print('received notification: $notification');
        });
    FlutterOneSignal.sendTag('userId', 'demoUserId');
    var payerID = await FlutterOneSignal.getUserId();

    Dio dio = new Dio();
    dio.options.connectTimeout = 5000; //5s
    dio.options.receiveTimeout = 3000;

    FormData formData = new FormData.from({
      'payerID': payerID,
    });
    var response = await dio.post(
        "${UrlApi().url}/index.php/api/userpayer?id=${gettoken}",
        data: formData);
    //print(response);
  }

  /*======================Get User Login ========================*/

  Future<Null> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await prefs.get('token');
    var datauser = await prefs.get('username');
    var firstname = await prefs.get('first_name');
    var photoProfile = await prefs.get('photo_profile');
    var photoBg = await prefs.get('photo_bg');
    setState(() {
      photo_profile = photoProfile;
      photo_bg = photoBg;
      gettoken = token;
      getusername = datauser;
      getfirstname = firstname;
     // _initOneSignal();
    });
  }

  @override
  void initState() {
    super.initState();
    loadlang();
    getToken();
    getlisthouses();

  }

  Future<Null> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    // Navigator.of(context).pushNamed('/login');
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Login()));
  }

  /*======================= get List house =========================*/
  var listhouses;
  bool isLoading = true;
  var listhousesApi;
  int alertcount = 0;
  Future<Null> getlisthouses() async {
    final response = await http.get('${UrlApi().url}/index.php/api/listhouse');

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      Dio dio = new Dio();
      dio.options.connectTimeout = 5000; //5s
      dio.options.receiveTimeout = 3000;
      var responsecountalert = await dio
          .post("${UrlApi().url}/index.php/api/countalert?userid=${gettoken}");
      //print(responsecountalert.data);
      setState(() {
        isLoading = false;
        listhouses = jsonResponse['rows'];
        listhousesApi = jsonResponse['rows'];
        alertcount = int.parse(responsecountalert.data);
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

//============== Search Appbar ================
  Widget appBarTitle;
  Icon actionIcon = new Icon(Icons.search);
  final TextEditingController _searchQuery = new TextEditingController();
  var listsearchhouse;
  bool ischeaching = false;
  _SearchListState() {
    if (_searchQuery.text.isEmpty) {
      setState(() {
        print('Search text empyt');
        if (ischeaching == true) {
          listhouses = listhousesApi;
        }
      });
    } else {
      setState(() {
        List _listsearch = new List();
        for (var item in listhousesApi) {
          if (item['details']
                  .toLowerCase()
                  .contains(_searchQuery.text.toLowerCase()) ||
              item['fee']
                  .toLowerCase()
                  .contains(_searchQuery.text.toLowerCase()) ||
              item['type_name']
                  .toLowerCase()
                  .contains(_searchQuery.text.toLowerCase())) {
            _listsearch.add(item);
          }
        }
        listhouses = _listsearch.toSet().toList();
        //print(listsearchhouse);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget appBar = AppBar(
      title: appBarTitle!=null?appBarTitle:Text(localized.list(localized.translate, 'Home')),
      actions: <Widget>[
        /*  ===============  Search ===============*/
        IconButton(
          icon: actionIcon,
          onPressed: () {
            setState(() {
              if (this.actionIcon.icon == Icons.search) {
                this.actionIcon = new Icon(Icons.close);
                this.appBarTitle = new TextField(
                  onChanged: (text) {
                    _SearchListState();
                  },
                  controller: _searchQuery,
                  style: new TextStyle(
                    color: Colors.white,
                  ),
                  decoration: new InputDecoration(
                      fillColor: Colors.greenAccent,
                      prefixIcon: new Icon(Icons.search, color: Colors.white),
                      hintText: localized.list(localized.translate, 'Search'),
                      hintStyle: new TextStyle(color: Colors.white)),
                );
                _SearchListState();
                ischeaching = true;
              } else {
                ischeaching = false;
                _searchQuery.clear();
                this.actionIcon = new Icon(Icons.search);
                this.appBarTitle = Text(localized.list(localized.translate, 'Home'));
              }
            });
          },
        ),
        /*==================Alert Push ===============*/
        (alertcount != 0)
            ? IconButton(
                icon: new Stack(
                  children: <Widget>[
                    new Icon(
                      Icons.add_alert,
                      size: 30.0,
                    ),
                    new Positioned(
                      height: 20.0,
                      width: 20.0,
                      top: 1.0,
                      right: 0.0,
                      child: new Stack(
                        children: <Widget>[
                          new Icon(Icons.brightness_1,
                              // size: 15.0,
                              color: Colors.green[800]),
                          new Positioned(
                            top: 5.0,
                            right: 2.0,
                            child: new Text('${alertcount}',
                                style: new TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w500)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/listhouseuser');
                },
              )
            : Text(''),
      ],
    );

    /* ------------------------ Upload Ingage profile -------------------------*/
  File _image;
  bool isloadimg = false;
  Future getImageProfile(var type) async {
    var imageFile = (type == 'camera')
        ? await ImagePicker.pickImage(source: ImageSource.camera)
        : await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        _image = imageFile;
        isloadimg = true;
      });
      /*============ Drop Images =================*/
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: imageFile.path,
          ratioX: 1.0,
          ratioY: 1.0,
          toolbarTitle:localized.list(localized.translate, 'Crop photo'),
          toolbarColor: Colors.red);
      if (croppedFile != null) {
        imageFile = croppedFile;
        /*============ Send Images to API Save =================*/
        Dio dio = new Dio();
        FormData formData = new FormData.from({
          "name": "profile_img",
          'edit':true,
          'userid':gettoken,
          "upfile": new UploadFileInfo(imageFile, "upload1.jpg")
        });
        var response = await dio
            .post("${UrlApi().url}/index.php/api/uplaodfile", data: formData);
        if (response.statusCode == 200) {
          setState(() {
            isloadimg = false;
            photo_profile = response.data;
          });
        } else {
          print('Error upload image');
        }
      } else {
        setState(() {
          if (photo_profile.photo == null) {
            _image = null;
          }
          isloadimg = false;
        });
      }
    }
  }

/*====================== Uplaod image profile Bg ========================*/
  File _imageBg;
  bool isloadimgBg = false;
  Future getImageBgProfile(var type) async {
    var imageBgFile = (type == 'camera')
        ? await ImagePicker.pickImage(source: ImageSource.camera)
        : await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageBgFile != null) {
      setState(() {
        _imageBg = imageBgFile;
        isloadimgBg = true;
      });
      /*============ Drop Images =================*/
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: imageBgFile.path,
          ratioX: 1.8,
          ratioY: 1.0,
          toolbarTitle:localized.list(localized.translate, 'Crop photo'),
          toolbarColor: Colors.red);
      if (croppedFile != null) {
        imageBgFile = croppedFile; 
        /*============ Send Images to API Save =================*/
        Dio dio = new Dio();
        FormData formData = new FormData.from({
          "name": "profileBg_img",
          'edit':true,
          'userid':gettoken,
          "upfile": new UploadFileInfo(imageBgFile, "upload1.jpg")
        });
        var response = await dio
            .post("${UrlApi().url}/index.php/api/uplaodfile", data: formData);
        if (response.statusCode == 200) {
          setState(() {
            isloadimgBg = false;
            photo_bg= response.data;
          });
        } else {
          print('Error upload image');
        }
      } else {
        setState(() {
          if (photo_bg == null) {
            _imageBg = null;
          }
          isloadimgBg = false;
        });
      }
    }
  }

//================== menu left ========================
    Widget drawer = Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            onDetailsPressed: (){
                  showDialog(
                      context: context,
                      child: AlertDialog( 
                          content: Container(
                        height: 80.0,
                        child: Column(
                          children: <Widget>[
                            Text(
                              localized.list(localized.translate, 'Change photo profile backgroud'),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: <Widget>[
                                OutlineButton.icon(
                                  label: Text(localized.list(localized.translate, 'GALLERY'),
                                      style: TextStyle(
                                          fontSize: 10.0, color: Colors.black)),
                                  icon: Icon(
                                    Icons.image,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    getImageBgProfile('gallery');

                                    Navigator.of(context).pop();
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: OutlineButton.icon(
                                    label: Text(localized.list(localized.translate, 'CAMERA'),
                                        style: TextStyle(fontSize: 10.0)),
                                    icon: Icon(
                                      Icons.camera,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      getImageBgProfile('camera');

                                      Navigator.of(context).pop();
                                    },
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )));
                },
            decoration: BoxDecoration(
              image: DecorationImage(
                
                  image: photo_bg == null
                      ? AssetImage('assets/img/bg.jpg')
                      : NetworkImage('${UrlApi().url}/images/small/'
                          '${photo_bg}'),
                  fit: BoxFit.fill),
            ),
            
            currentAccountPicture: GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      child: AlertDialog( 
                          content: Container(
                        height: 80.0,
                        child: Column(
                          children: <Widget>[
                            Text(
                              localized.list(localized.translate, 'Change photo profile'),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: <Widget>[
                                OutlineButton.icon(
                                  label: Text(localized.list(localized.translate, 'GALLERY'),
                                      style: TextStyle(
                                          fontSize: 10.0, color: Colors.black)),
                                  icon: Icon(
                                    Icons.image,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    getImageProfile('gallery');

                                    Navigator.of(context).pop();
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: OutlineButton.icon(
                                    label: Text(localized.list(localized.translate, 'CAMERA'),
                                        style: TextStyle(fontSize: 10.0)),
                                    icon: Icon(
                                      Icons.camera,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      getImageProfile('camera');

                                      Navigator.of(context).pop();
                                    },
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )));
                },
                child: CircleAvatar(
                  backgroundImage: photo_profile == null
                      ? AssetImage('assets/img/user.jpg')
                      : NetworkImage('${UrlApi().url}/images/small/'
                          '${photo_profile}'),
                )),
            accountName: Text(
              '$getfirstname',
              style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            accountEmail: Text(
              '$getusername',
              style: TextStyle(color: Colors.white),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.store,
              color: Colors.blue,
            ),
            title: Text(
              localized.list(localized.translate, 'Advertise house'),
              style: TextStyle(fontSize: 20.0),
            ),
            subtitle: Text(
              localized.list(localized.translate, 'Manage Advertise house your owner'),
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.of(context).pushNamed('/listhouseuser');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.account_circle,
              color: Colors.blue,
            ),
            title: Text(
              localized.list(localized.translate, 'Profile'),
              style: TextStyle(fontSize: 20.0),
            ),
            subtitle: Text(
              localized.list(localized.translate, 'Mange your profile'),
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.assessment,
              color: Colors.blue,
            ),
            title: Text(
              localized.list(localized.translate, 'The result received'),
              style: TextStyle(fontSize: 20.0),
            ),
            subtitle: Text(
              localized.list(localized.translate, 'How to get results'),
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.settings_applications,
              color: Colors.blue,
            ),
            title: Text(
              localized.list(localized.translate, 'Setting'),
              style: TextStyle(fontSize: 20.0),
            ),
            subtitle: Text(
              localized.list(localized.translate, 'Manage setting'),
              style: TextStyle(fontSize: 12.0),
            ),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {},
          ),
          Divider(),
          ListTile(
            trailing: Icon(
              Icons.settings_power,
              color: Colors.red,
            ),
            title: Text(
              localized.list(localized.translate, 'Logout'),
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            onTap: () {
              logOut();
            },
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: appBar,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: getlisthouses,
              child: ListView.builder(
                itemBuilder: (context, int index) {
                  var per = (listhouses[index]['per'] == "m") ? localized.list(localized.translate, 'Month') : localized.list(localized.translate, 'Year');
                  return Column(
                    children: <Widget>[
                      ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ViewHouse(
                                      listhouses[index]['id'],
                                      listhouses[index]['did'])));
                        },
                        leading: CachedNetworkImage(
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                          imageUrl: '${UrlApi().url}/images/small/'
                              '${listhouses[index]['photo_name']}',
                          placeholder: new CircularProgressIndicator(),
                          errorWidget: new Icon(Icons.error),
                        ),
                        
                        title: Text('${listhouses[index]['type_name']}'),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${listhouses[index]['details']}',
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                maxLines: 2, 
                              ),
                              (listhouses[index]['dstatus'] == '1')
                                  ? Text(
                                    localized.list(localized.translate, 'Invariable'),
                                      style: TextStyle(color: Colors.green),
                                    )
                                  : Text(
                                      localized.list(localized.translate, 'Not invariable'),
                                      style: TextStyle(color: Colors.red),
                                    ),
                              Text(localized.list(localized.translate, 'Price')+':${listhouses[index]['fee']} ${listhouses[index]['currency_name']}/$per')
                            ]),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      ),
                      Divider() 
                    ],
                  );
                },
                itemCount: listhouses != null ? listhouses.length : 0,
              ),
            ),
      drawer: drawer,
    );
  }
}

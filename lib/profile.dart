import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:erent/url_api.dart';
import 'package:flutter/material.dart';
import 'package:erent/models/model_register.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validate/validate.dart';

class Profile extends StatefulWidget {
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  ModelRegister _data = ModelRegister();
  bool isloading = false;
/*================= Get Data Profile  ===========================*/
  var listprofie;
  var userID;
  Future GetDataProfile() async {
    setState(() {
      isloading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = await prefs.get('token');
    setState(() {
      userID = userid;
    });
    Dio dio = new Dio();
    Response response = await dio
        .get("${UrlApi().url}/index.php/api/showprofile", data: {"id": userid});
    //print(response.data);
    if (response.statusCode == 200) {
      setState(() {
        _data.first_name = response.data['register']['first_name'];
        _data.last_name = response.data['register']['last_name'];
        _data.email = response.data['register']['email'];
        _data.phone = response.data['register']['phone'];
        _data.address = response.data['register']['address'];
        _data.photo = response.data['register']['photo'];
        _data.photo_bg = response.data['register']['photo_bg'];
        isloading = false;
      });
    } else {
      setState(() {
        isloading = false;
      });
      /*========== Alert Dialog Error get data=========*/
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
          toolbarTitle: 'ຕັດ​ຮູບ​ພາບ',
          toolbarColor: Colors.red);
      if (croppedFile != null) {
        imageFile = croppedFile;
        /*============ Send Images to API Save =================*/
        Dio dio = new Dio();
        FormData formData = new FormData.from({
          "name": "profile_img",
          "upfile": new UploadFileInfo(imageFile, "upload1.jpg")
        });
        var response = await dio
            .post("${UrlApi().url}/index.php/api/uplaodfile", data: formData);
        if (response.statusCode == 200) {
          setState(() {
            isloadimg = false;
            _data.photo = response.data;
          });
        } else {
          print('Error upload image');
        }
      } else {
        setState(() {
          if (_data.photo == null) {
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
          toolbarTitle: 'ຕັດ​ຮູບ​ພາບ',
          toolbarColor: Colors.red);
      if (croppedFile != null) {
        imageBgFile = croppedFile;
        /*============ Send Images to API Save =================*/
        Dio dio = new Dio();
        FormData formData = new FormData.from({
          "name": "profileBg_img",
          "upfile": new UploadFileInfo(imageBgFile, "upload1.jpg")
        });
        var response = await dio
            .post("${UrlApi().url}/index.php/api/uplaodfile", data: formData);
        if (response.statusCode == 200) {
          setState(() {
            isloadimgBg = false;
            _data.photo_bg = response.data;
          });
        } else {
          print('Error upload image');
        }
      } else {
        setState(() {
          if (_data.photo_bg == null) {
            _imageBg = null;
          }
          isloadimgBg = false;
        });
      }
    }
  }

/*================== Update data profile ====================*/
  bool isloadingsave = false;
  Future submit() async {
    setState(() {
      isloadingsave = true;
    });
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.
      Dio dio = new Dio();
      FormData formData = new FormData.from({
        'id': userID,
        "first_name": _data.first_name,
        'last_name': _data.last_name,
        'email': _data.email,
        'phone': _data.phone,
        'address': _data.address,
        'photo': _data.photo,
        'photo_bg': _data.photo_bg
      });
      Response response = await dio
          .post("${UrlApi().url}/index.php/api/editprofile", data: formData);
      if (response.statusCode == 200) {
        setState(() {
          isloadingsave = false;
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('photo_profile', _data.photo);
        prefs.setString('photo_bg', _data.photo_bg);
        Navigator.pushNamed(context, '/home');
      } else {
        print('Errors Edit profile');
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GetDataProfile();
  }

  /*================ Validate Data ========================*/
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String _validateFirstname(String value) {
    try {
      Validate.notEmpty(value);
    } catch (e) {
      return '​ຕ້ອງປ້ອນ​ຊື່​ຂອງ​ທ່ານ';
    }
    return null;
  }

  String _validateLastname(String value) {
    try {
      Validate.notEmpty(value);
    } catch (e) {
      return 'ຕ້ອງ​ປ້ອນ​ນາມ​ສະ​ກູນ​ຂອງ​ທ່ານ';
    }
    return null;
  }

  String _validatePhone(String value) {
    if (value.length != 13) {
      return 'ຕ້ອງ​ປ້ອນ​​ເບີ​ໂທຂອງ​ທ່ານ 13 ໂຕ​ເລກ.';
    }
    return null;
  }

  String _validateEmail(String value) {
    try {
      Validate.isEmail(value);
    } catch (e) {
      return '​ຕ້ອງ​ປ້ອນ​ເປັ​ນ​ອີ​ເມວ​.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ແກ້​ໄຂ​ໂປ​ຣ​ໄຟ'),
      ),
      body: isloading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: 'ຊື່​ຂອງ​ທ່ານ'),
                      initialValue: _data.first_name,
                      validator: _validateFirstname,
                      onSaved: (var value) {
                        this._data.first_name = value;
                      },
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: 'ນາມ​ສະ​ກຸນ​ທ່ານ'),
                      initialValue: _data.last_name,
                      validator: _validateLastname,
                      onSaved: (var value) {
                        this._data.last_name = value;
                      },
                    ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: _validateEmail,
                      initialValue: _data.email,
                      onSaved: (var value) {
                        this._data.email = value;
                      },
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'phone'),
                      initialValue: _data.phone,
                      validator: _validatePhone,
                      onSaved: (var value) {
                        this._data.phone = value;
                      },
                    ),
                    TextFormField(
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(labelText: 'Address'),
                      initialValue: _data.address,
                      onSaved: (var value) {
                        this._data.address = value;
                      },
                    ),
                    _image == null
                        ? (_data.photo == null)
                            ? Text('')
                            : Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: CachedNetworkImage(
                                  width: 100.0,
                                  height: 100.0,
                                  fit: BoxFit.contain,
                                  imageUrl: '${UrlApi().url}/images/small/'
                                      '${_data.photo}',
                                  placeholder: Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: new Icon(Icons.error),
                                ),
                              )
                        : isloadimg
                            ? Padding(
                                padding: const EdgeInsets.all(10.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: CachedNetworkImage(
                                  width: 100.0,
                                  height: 100.0,
                                  fit: BoxFit.contain,
                                  imageUrl: '${UrlApi().url}/images/small/'
                                      '${_data.photo}',
                                  placeholder: Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: new Icon(Icons.error),
                                ),
                              ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: OutlineButton.icon(
                        label: Text('ເລືອ​ກຮ​ູບ​ພາບໂປ​ຣ​ໄຟ'),
                        icon: Icon(
                          Icons.add_a_photo,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              child: AlertDialog(
                                  content: Row(
                                children: <Widget>[
                                  OutlineButton.icon(
                                    label: Text('GALLERY',
                                        style: TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.black)),
                                    icon: Icon(
                                      Icons.image,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      getImageProfile('gallery');
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: OutlineButton.icon(
                                      label: Text('CAMERA',
                                          style: TextStyle(fontSize: 10.0)),
                                      icon: Icon(
                                        Icons.camera,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        getImageProfile('camera');
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  )
                                ],
                              )));
                        },
                      ),
                    ),
                    _imageBg == null
                        ? (_data.photo_bg == null)
                            ? Text('')
                            : Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: CachedNetworkImage(
                                  height: 130.0,
                                  fit: BoxFit.cover,
                                  imageUrl: '${UrlApi().url}/images/small/'
                                      '${_data.photo_bg}',
                                  placeholder: Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: new Icon(Icons.error),
                                ),
                              )
                        : isloadimgBg
                            ? Padding(
                                padding: const EdgeInsets.all(10.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: CachedNetworkImage(
                                  // width: 100.0,
                                  height: 130.0,
                                  fit: BoxFit.cover,
                                  imageUrl: '${UrlApi().url}/images/small/'
                                      '${_data.photo_bg}',
                                  placeholder: Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: new Icon(Icons.error),
                                ),
                              ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: OutlineButton.icon(
                        label: Text('ເລືອ​ກຮ​ູບ​ພາບພື້ນຫຼັງໂປ​ຣ​ໄຟ'),
                        icon: Icon(
                          Icons.add_a_photo,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              child: new AlertDialog(
                                  content: Row(
                                children: <Widget>[
                                  OutlineButton.icon(
                                    label: Text('GALLERY',
                                        style: TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.black)),
                                    icon: Icon(
                                      Icons.image,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      getImageBgProfile('gallery');
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: OutlineButton.icon(
                                      label: Text('CAMERA',
                                          style: TextStyle(fontSize: 10.0)),
                                      icon: Icon(
                                        Icons.camera,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        getImageBgProfile('camera');
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  )
                                ],
                              )));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: isloadingsave
                          ? Center(child: CircularProgressIndicator())
                          : RaisedButton(
                              child: Text(
                                'ບັນ​ທືກ',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20.0),
                              ),
                              onPressed: () {
                                submit();
                              },
                              color: Colors.red,
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

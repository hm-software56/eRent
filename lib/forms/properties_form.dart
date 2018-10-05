import 'dart:async';
//import 'dart:convert';
import 'dart:io';

//import 'package:async/async.dart';
import 'package:erent/forms/getmap.dart';
import 'package:erent/forms/viewproperties.dart';
import 'package:erent/models/model_properties.dart';
import 'package:erent/translations.dart';
import 'package:erent/url_api.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
//import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validate/validate.dart';

class PropertiesForm extends StatefulWidget {
  PropertiesFormState createState() => PropertiesFormState();
}

class PropertiesFormState extends State<PropertiesForm> {
  Translations localized = Translations();
  bool isLoading = true;
  bool isloadimg = false;
  bool isloadsave = false;
  List listpropertytype = List();
  List listcurrency = List();
  Map mapprovice = Map();
  List listprovice = List();
  Map mapdistrict = Map();
  List listdistrict = [''];
  String validatetype = '';
  String validateper = '';
  String validateimg = '';
  String validatecurrency = '';
  String validateprovince = '';

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  ModelProperties _data = ModelProperties();

  /*================== get list property type and currency ===============*/
  Future<Null> getListType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var langcode = await prefs.get('langcode');
    Dio dio = Dio();
    final response = await dio.get(
        '${UrlApi().url}/index.php/api/listpropertiestype',
        data: {'lang': langcode});

    final responseCurrency = await dio.get(
        '${UrlApi().url}/index.php/api/listcurrency',
        data: {'lang': langcode});

    final responseProvince = await dio.get(
        '${UrlApi().url}/index.php/api/listprovince',
        data: {'lang': langcode});

    if (response.statusCode == 200 &&
        responseCurrency.statusCode == 200 &&
        responseProvince.statusCode == 200) {
      var jsonResponse = response.data;
      var jsoncurrency = responseCurrency.data;

      List listtype = List();
      for (var item in jsonResponse['rows']) {
        listtype.add('${item['name']}');
      }

      List currency = List();
      for (var item in jsoncurrency['rows']) {
        currency.add('${item['name']}');
      }

      List province = List();
      for (var item in responseProvince.data['rows']) {
        province.add('${item['name']}');
      }

      isLoading = false;
      setState(() {
        listpropertytype = listtype;
        listcurrency = currency;
        listprovice = province;
        mapprovice = responseProvince.data;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Error cooneted.');
      showDialog<Null>(
        // context: context,
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
                      child: new Text(localized.list(localized.translate,
                          'Please check your connection'))),
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

/*================= list district by province id  ===========================*/
  Future selectdistrictbyprovice(var province) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var langcode = await prefs.get('langcode');
    Dio dio = Dio();
    for (var item in mapprovice['rows']) {
      if (item['name'] == '${province}') {
        setState(() {
          _data.province_id = item['id'];
        });
      }
    }

    final response = await dio.get(
        '${UrlApi().url}/index.php/api/listdistrictbyprovince',
        data: {'lang': langcode, 'province_id': _data.province_id});
    if (response.statusCode == 200) {
      List district = List();
      if (response.data['rows'].length > 0) {
        for (var item in response.data['rows']) {
          district.add('${item['name']}');
        }
        setState(() {
          listdistrict = district;
          mapdistrict = response.data['rows'];
        });
      } else {
        setState(() {
          listdistrict = [''];
          mapdistrict = Map();
        });
      }
    }
  }

/* ------------------------ Upload Ingage -------------------------*/
  File _image;
  Future getImage(var type) async {
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
          ratioX: 1.5,
          ratioY: 1.0,
          toolbarTitle: localized.list(localized.translate, 'Crop photo'),
          toolbarColor: Colors.red);
      if (croppedFile != null) {
        imageFile = croppedFile;
        /*============ Send Images to API Save =================*/
        Dio dio = new Dio();
        FormData formData = new FormData.from(
            {"upfile": new UploadFileInfo(imageFile, "upload1.jpg")});
        var response = await dio
            .post("${UrlApi().url}/index.php/api/uplaodfile", data: formData);
        if (response.statusCode == 200) {
          setState(() {
            isloadimg = false;
            _data.imgname.add(response.data);
          });
        } else {
          print('Error upload image');
        }
      } else {
        setState(() {
          if (_data.imgname.length == 0) {
            _image = null;
          }
          isloadimg = false;
        });
      }
    }
  }

  /* -----------------------------------Remove image -----------------*/
  Future Removephoto(var imgdel) {
    for (var item in _data.imgname) {
      if (imgdel == item) {
        _data.imgname.remove(item);
      }
      setState(() {
        _data.imgname = _data.imgname;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    localized.loadlang();
    getListType();
  }

  /* ======================validate data ============================= */
  String _validatDetails(String value) {
    try {
      Validate.notEmpty(value);
    } catch (e) {
      return localized.list(localized.translate, 'Must be enter details house');
    }
    return null;
  }

  String _validatBed(String value) {
    try {
      Validate.notEmpty(value);
    } catch (e) {
      return localized.list(
          localized.translate, 'Must be enter number of bedroom');
    }
    return null;
  }

  String _validatBath(String value) {
    try {
      Validate.notEmpty(value);
    } catch (e) {
      return localized.list(
          localized.translate, 'Must be enter number of bathroom');
    }
    return null;
  }

  String _validatFee(String value) {
    try {
      Validate.notEmpty(value);
    } catch (e) {
      return localized.list(localized.translate, 'Must be enter price');
    }
    return null;
  }

  String _validatedropdown() {
    if (_data.propertye == null) {
      setState(() {
        validatetype =
            localized.list(localized.translate, 'Must be choose type house');
      });
    } else {
      setState(() {
        validatetype = '';
      });
    }

    if (_data.province == null) {
      setState(() {
        validateprovince =
            localized.list(localized.translate, 'Must be choose province');
      });
    } else {
      setState(() {
        validateprovince = '';
      });
    }

    if (_data.currency == null) {
      setState(() {
        validatecurrency =
            localized.list(localized.translate, 'Must be choose currency');
      });
    } else {
      setState(() {
        validatecurrency = '';
      });
    }

    if (_data.per == null) {
      setState(() {
        validateper = localized.list(
            localized.translate, 'Must be choose a month or year per price');
      });
    } else {
      setState(() {
        validateper = '';
      });
    }

    if (_image == null) {
      setState(() {
        validateimg =
            localized.list(localized.translate, 'Must be choose photo');
      });
    } else {
      setState(() {
        validateimg = '';
      });
    }
  }

  /* =================== Save Data to server ==========================*/
  Future<Null> submit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _data.userID = await prefs.get('token');
    _data.lat = await prefs.get('lat');
    _data.long = await prefs.get('long');

    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.

    }
    if (_data.propertye == null || _data.per == null || _image == null) {
      _validatedropdown();
    } else if (_data.detailes != null && _data.fee != null) {
      //print(imgList);
      setState(() {
        isloadsave = true;
      });
      Dio dio = new Dio();
      dio.options.connectTimeout = 5000; //5s
      dio.options.receiveTimeout = 3000;

      FormData formData = new FormData.from({
        'propertye': _data.propertye,
        'details': _data.detailes,
        'fee': _data.fee,
        'per': _data.per,
        'photos': [_data.imgname],
        'long': _data.long,
        'lat': _data.lat,
        'userID': _data.userID,
        'currency': _data.currency,
      });
      var response = await dio.post(
          "${UrlApi().url}/index.php/api/createproperties",
          data: formData);
      if (response.statusCode == 200 && response.data['id'] != null) {
        prefs.remove('lat');
        prefs.remove('long');
        setState(() {
          isloadsave = false;
        });
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ViewProperties(
                    int.parse(response.data['id']),
                    int.parse(response.data['did']))));
      } else {
        print('Error Post Data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // print('${sampleData}');

    return Scaffold(
      appBar: AppBar(
        title: Text(localized.list(localized.translate, 'Enter new house')),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: this._formKey,
                // autovalidate: true,
                child: ListView(
                  children: <Widget>[
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: localized.list(
                            localized.translate, 'Choose province'),
                      ),
                      isEmpty: _data.propertye == null,
                      child: new DropdownButtonHideUnderline(
                        child: new DropdownButton<String>(
                          value: _data.province,
                          isDense: true,
                          onChanged: (String newValue) {
                            setState(() {
                              _data.province = newValue;
                            });
                            selectdistrictbyprovice(_data.province);
                          },
                          items: listprovice.map((value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Text(
                      '${validateprovince}',
                      style: TextStyle(color: Colors.red, fontSize: 12.0),
                    ),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: localized.list(
                            localized.translate, 'Choose district'),
                      ),
                      isEmpty: _data.district == null,
                      child: new DropdownButtonHideUnderline(
                        child: new DropdownButton<String>(
                          value: _data.district,
                          isDense: true,
                          onChanged: (String newValue) {
                            setState(() {
                              _data.district = newValue;
                            });
                          },
                          items: listdistrict.map((value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Text(
                      '${validateprovince}',
                      style: TextStyle(color: Colors.red, fontSize: 12.0),
                    ),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: localized.list(
                            localized.translate, 'Choose type house'),
                      ),
                      isEmpty: _data.propertye == null,
                      child: new DropdownButtonHideUnderline(
                        child: new DropdownButton<String>(
                          value: _data.propertye,
                          isDense: true,
                          onChanged: (String newValue) {
                            setState(() {
                              _data.propertye = newValue;
                            });
                          },
                          items: listpropertytype.map((value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Text(
                      '${validatetype}',
                      style: TextStyle(color: Colors.red, fontSize: 12.0),
                    ),
                    TextFormField(
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          //hintText: '​ລາຍ​ລະ​ອຽດ',
                          labelText: localized.list(
                              localized.translate, 'Enter details for lao')),
                      validator: this._validatDetails,
                      onSaved: (var value) {
                        this._data.detailes = value;
                      },
                    ),
                    TextFormField(
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          labelText: localized.list(localized.translate,
                              'Enter details for english')),
                      onSaved: (var value) {
                        this._data.detailes_en = value;
                      },
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: localized.list(
                              localized.translate, 'Enter bedroom')),
                      validator: this._validatBed,
                      onSaved: (var value) {
                        this._data.number_bed = int.parse(value);
                      },
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: localized.list(
                              localized.translate, 'Enter bathroom')),
                      validator: this._validatBath,
                      onSaved: (var value) {
                        this._data.number_bath = int.parse(value);
                      },
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText:
                              localized.list(localized.translate, 'Price'),
                          labelText: localized.list(
                              localized.translate, 'Enter price')),
                      onSaved: (var value) {
                        this._data.fee = value;
                      },
                      validator: this._validatFee,
                    ),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: localized.list(
                            localized.translate, 'Choose currency'),
                      ),
                      isEmpty: _data.currency == null,
                      child: new DropdownButtonHideUnderline(
                        child: new DropdownButton<String>(
                          value: _data.currency,
                          isDense: true,
                          onChanged: (String newValue) {
                            setState(() {
                              _data.currency = newValue;
                            });
                          },
                          items: listcurrency.map((value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Text(
                      '${validatecurrency}',
                      style: TextStyle(color: Colors.red, fontSize: 12.0),
                    ),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: localized.list(localized.translate,
                            'Choose a month or year per price'),
                      ),
                      isEmpty: _data.per == null,
                      child: new DropdownButtonHideUnderline(
                        child: new DropdownButton<String>(
                          value: _data.per,
                          isDense: true,
                          onChanged: (String newValue) {
                            setState(() {
                              _data.per = newValue;
                            });
                          },
                          items: [
                            localized.list(localized.translate, 'Month'),
                            localized.list(localized.translate, 'Year')
                          ].map((value) {
                            return new DropdownMenuItem<String>(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    Text(
                      '${validateper}',
                      style: TextStyle(color: Colors.red, fontSize: 12.0),
                    ),
                    OutlineButton.icon(
                      label: Text(localized.list(localized.translate, 'Map')),
                      icon: Icon(
                        Icons.map,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                fullscreenDialog: true,
                                builder: (context) => GetMap()));
                      },
                    ),
                    (isloadimg)
                        ? Center(child: CircularProgressIndicator())
                        : Text(''),
                    _image == null
                        ? Text('')
                        : SizedBox(
                            height: 100.0,
                            //width: 200.0,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) =>
                                  GestureDetector(
                                    onDoubleTap: () {
                                      Removephoto(_data.imgname[index]);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Image(
                                        image: NetworkImage(
                                          '${UrlApi().url}/images/small/'
                                              '${_data.imgname[index]}',
                                        ),
                                      ),
                                    ),
                                  ),
                              itemCount: _data.imgname.length,
                            ),
                          ),
                    OutlineButton.icon(
                      label: Text(
                          localized.list(localized.translate, 'Choose photo')),
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
                                  label: Text(
                                      localized.list(
                                          localized.translate, 'GALLERY'),
                                      style: TextStyle(
                                          fontSize: 10.0, color: Colors.black)),
                                  icon: Icon(
                                    Icons.image,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    getImage('gallery');
                                    Navigator.of(context).pop();
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: OutlineButton.icon(
                                    label: Text(
                                        localized.list(
                                            localized.translate, 'CAMERA'),
                                        style: TextStyle(fontSize: 10.0)),
                                    icon: Icon(
                                      Icons.camera,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      getImage('camera');
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                )
                              ],
                            )));
                        //getImage();
                      },
                    ),
                    Text(
                      '${validateimg}',
                      style: TextStyle(color: Colors.red, fontSize: 12.0),
                    ),
                    Divider(),
                    (isloadsave)
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Text(''),
                    RaisedButton(
                      child: Text(
                        localized.list(localized.translate, 'Save'),
                        style: TextStyle(color: Colors.white, fontSize: 20.0),
                      ),
                      onPressed: () {
                        submit();
                      },
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

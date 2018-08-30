import 'dart:async';
import 'dart:io';

import 'package:erent/forms/viewproperties.dart';
import 'package:erent/url_api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validate/validate.dart';

class PropertiesFormedit extends StatefulWidget {
  var proID;
  var detailID;
  PropertiesFormeditState createState() =>
      PropertiesFormeditState(this.proID, this.detailID);
  PropertiesFormedit(this.proID, this.detailID);
}

class PropertiesFormeditState extends State<PropertiesFormedit> {
  var proID;
  var detailID;
  PropertiesFormeditState(this.proID, this.detailID);

  bool isLoading = true;
  bool isloadimg = false;
  bool isloadsave = false;
  List listpropertytype = List();
  String validatetype = '';
  String validateper = '';
  String validateimg = '';
  File _image;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  _PropertiesForm _data = _PropertiesForm();

  Future<Null> getData() async {
    Dio dio = Dio();
    final responsepro =
        await dio.get('${UrlApi().url}/index.php/api/detailhouse?id=${proID}');
    final responsephoto =
        await dio.get('${UrlApi().url}/index.php/api/photos?did=${detailID}');
    if (responsepro.statusCode == 200 && responsephoto.statusCode == 200) {
      //print(responsephoto.data);
      // responsephoto.data;
      setState(() {
        _data.detailes = responsepro.data['rows'][0]['details'];
        _data.propertye = responsepro.data['rows'][0]['type_name'];
        _data.fee = responsepro.data['rows'][0]['fee'];
        _data.long = responsepro.data['rows'][0]['longtitude'];
        _data.lat = responsepro.data['rows'][0]['lattitude'];

        if (responsepro.data['rows'][0]['fee'] == 'm') {
          _data.per = '​ເດືອນ';
        } else {
          _data.per = 'ປີ';
        }
        for (var item in responsephoto.data['photos']) {
          _data.imgname.add(item['name']);
          _image=new File('assets/img/logo.jpg');
        }
      });
    }
    ;

    final response =
        await dio.get('${UrlApi().url}/index.php/api/listpropertiestype');

    if (response.statusCode == 200) {
      var jsonResponse = response.data;
      // print(jsonResponse);
      //print(jsonResponsepackage);
      isLoading = false;
      setState(() {
        for (var item in jsonResponse['rows']) {
          listpropertytype.add('${item['name']}');
        }
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

/* ------------------------ Upload Ingage -------------------------*/
  //List imgList = List();
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        isloadimg = true;
      });
      Dio dio = new Dio();
      FormData formData = new FormData.from(
          {"upfile": new UploadFileInfo(image, "upload1.jpg")});
      var response = await dio.post("${UrlApi().url}/index.php/api/uplaodfile",
          data: formData);
      if (response.statusCode == 200) {
        setState(() {
          isloadimg = false;
          _data.imgname.add(response.data);
        });
      } else {
        print('Error upload image');
      }
    }
    setState(() {
      _image = image;
      // imgList.add(image);
    });
  }

  /* -----------------------------------Remove image -----------------*/
  Future Removephoto(var imgdel) {
    for (var item in _data.imgname) {
      if (imgdel == item) {
        _data.imgname.remove(item);
      }
      setState(() {
        _data.imgname = _data.imgname;
        if(_data.imgname.length==0)
        {
          _image=null;
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  /* ======================validate data ============================= */
  String _validatDetails(String value) {
    try {
      Validate.notEmpty(value);
    } catch (e) {
      return 'ປ້ອນ​ລາຍ​ລະ​ອຽດ​ເຮືອນ';
    }
    return null;
  }

  String _validatFee(String value) {
    try {
      Validate.notEmpty(value);
    } catch (e) {
      return '​ປ້ອນລາ​ຄາ';
    }
    return null;
  }

  String _validatedropdown() {
    if (_data.propertye == null) {
      setState(() {
        validatetype = "ຕ້ອງເລືອກ​ປະ​ເພ​ດ​ເຮືອນ";
      });
    } else {
      setState(() {
        validatetype = '';
      });
    }

    if (_data.per == null) {
      setState(() {
        validateper = "ຕ້ອງເລືອກ​ເດືອນ​ຫຼື​ປີ​ຕໍ່​ລາ​ຄາ​";
      });
    } else {
      setState(() {
        validateper = '';
      });
    }

    if (_image == null) {
      setState(() {
        validateimg = "ຕ້ອງເລືອກຮູບ​ພາບ​​";
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
      });
      var response = await dio.post(
          "${UrlApi().url}/index.php/api/editproperties?id=${proID}",
          data: formData);
      if (response.statusCode == 200 && response.data['id'] != null) {
        print(response);
        setState(() {
          isloadsave = false;
        });
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
               fullscreenDialog: true,
                builder: (context) =>
                    ViewProperties(response.data['id'], response.data['did'])));
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
        title: Text('​ແກ້​ໄຂ​ຂໍ້​ມ​ູນ​ເຮືອນ'),
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
                      decoration: const InputDecoration(
                        labelText: 'ເລືອກ​ປະ​ເພດ​ເຮືອນ',
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
                      maxLines: 8,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          //hintText: '​ລາຍ​ລະ​ອຽດ',
                          labelText: '​ປ້ອນລາຍ​ລະ​ອຽດ​ເຮືອນ'),
                      initialValue: _data.detailes,
                      validator: this._validatDetails,
                      onSaved: (var value) {
                        this._data.detailes = value;
                      },
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: 'ລາ​ຄາ', labelText: '​ປ້ອນລາ​ຄາ/ກີບ'),
                      initialValue: _data.fee,
                      onSaved: (var value) {
                        this._data.fee = value;
                      },
                      validator: this._validatFee,
                    ),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: '​ເລືອກ ​ເດືອນ/ປີ ຕໍ່​ລາ​ຄາ​',
                      ),
                      isEmpty: _data.per == '',
                      child: new DropdownButtonHideUnderline(
                        child: new DropdownButton<String>(
                          value: _data.per,
                          isDense: true,
                          onChanged: (String newValue) {
                            setState(() {
                              _data.per = newValue;
                            });
                          },
                          items: ['ເດືອນ', 'ປີ'].map((value) {
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
                    Divider(),
                    Text('ປ້ອນແຜ່ນ​ທີ'),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: 'ປ້ອນ longitude'),
                      initialValue: _data.long,
                      onSaved: (var value) {
                        this._data.long = value;
                      },
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(labelText: 'ປ້ອນ latitude'),
                      initialValue: _data.lat,
                      onSaved: (var value) {
                        this._data.lat = value;
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
                      label: Text('ເລືອ​ກຮ​ູບ​ພາບ'),
                      icon: Icon(
                        Icons.add_a_photo,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        getImage();
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
                        'ບັນ​ທືກ',
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

class _PropertiesForm {
  var propertye;
  var detailes;
  String fee;
  String per;
  String long;
  String lat;
  String datestart;
  var package;
  List imgname = List();
  var userID;
}

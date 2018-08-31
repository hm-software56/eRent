import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:erent/url_api.dart';
import 'package:flutter/material.dart';
import 'package:erent/models/model_register.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  ModelRegister _data = ModelRegister();

/* ------------------------ Upload Ingage -------------------------*/
  File _image;
  bool isloadimg = false;
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
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
          _data.photo = response.data;
        });
      } else {
        print('Error upload image');
      }
    }
    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ແກ້​ໄຂ​ໂປ​ຣ​ໄຟ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: <Widget>[
            TextFormField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: 'ຊື່​ຂອງ​ທ່ານ'),
              onSaved: (var value) {
                this._data.first_name = value;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: 'ນາມ​ສະ​ກຸນ​ທ່ານ'),
              onSaved: (var value) {
                this._data.last_name = value;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email'),
              onSaved: (var value) {
                this._data.email = value;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'phone'),
              onSaved: (var value) {
                this._data.phone = value;
              },
            ),
            TextFormField(
              maxLines: 4,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(labelText: 'Address'),
              onSaved: (var value) {
                this._data.address = value;
              },
            ),
            _image == null
                ? Text('')
                : Image(
                    image: NetworkImage(
                      '${UrlApi().url}/images/small/'
                          '${_data.photo}',
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
                                    fontSize: 10.0, color: Colors.black)),
                            icon: Icon(
                              Icons.image,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              getImage();
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
                              onPressed: () {},
                            ),
                          )
                        ],
                      )));
                },
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
                                    fontSize: 10.0, color: Colors.black)),
                            icon: Icon(
                              Icons.image,
                              color: Colors.blue,
                            ),
                            onPressed: () {},
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
                              onPressed: () {},
                            ),
                          )
                        ],
                      )));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: RaisedButton(
                child: Text(
                  'ບັນ​ທືກ',
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
                onPressed: () {
                  // submit();
                },
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

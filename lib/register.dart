import 'dart:io';

import 'package:erent/url_api.dart';
import 'package:flutter/material.dart';
import 'package:validate/validate.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erent/verifycode.dart';

class _RegisterData {
  String firstname = '';
  String lastname = '';
  String email = '';
  String phone = '';
  String address = '';
}

class Register extends StatefulWidget {
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  var isLoading = false;
  String checkemailunique = '';
  String checkphoneunique = '';

  final GlobalKey<ScaffoldState> _scoffoldKey = new GlobalKey<ScaffoldState>();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  _RegisterData _data = new _RegisterData();

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

  Future<Null> submit() async {
    // First validate form.
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.

      setState(() {
        isLoading = true;
      });
      final response =
          await http.post('${UrlApi().url}/index.php/api/register', body: {
        'first_name': _data.firstname,
        'last_name': _data.lastname,
        'email': _data.email,
        'phone': _data.phone,
        'address': _data.address
      });
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        // print(jsonResponse);
        setState(() {
          isLoading = false;
        });
        if (jsonResponse['id'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt('register_id', jsonResponse['id']);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Verifycode()));
        } else {
          setState(() {
            if (jsonResponse['phone'] != null) {
              checkphoneunique = "ເບີ​ໂທ​ລະ​ສັບ​ຂ​ອງ​ທ່ານ​ຖືກ​ນຳ​ໃຊ້​ກ່ອນ​ແລ້ວ";
            } else {
              checkphoneunique = "";
            }
            if (jsonResponse['email'] != null) {
              checkemailunique = "ອີ​ເມວ​ຂອງ​ທ່າ​ນ​ຖືກ​ນຳ​ໃຊ້​ກ່ອນ​ແລ້ວ​";
            } else {
              checkemailunique = "";
            }
          });

          _scoffoldKey.currentState.showSnackBar(new SnackBar(
            backgroundColor: Colors.red,
            content: new Row(
              children: <Widget>[Text('ລົງ​ທະ​ບ​ຽນ​ມີ​ຂໍ້​ຜິດ​ພາດ.!')],
            ),
          ));
        }
      } else {
        setState(() {
          isLoading = false;
        });

        _scoffoldKey.currentState.showSnackBar(new SnackBar(
          backgroundColor: Colors.red,
          content: new Row(
            children: <Widget>[Text('​ມີຂໍ້​ຜິດ​ພາດ​ທາງເຊີ​ເວີ.!')],
          ),
        ));
        print("Not connection data");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      key: _scoffoldKey,
      appBar: AppBar(
        title: Text('ລົງ​ທະ​ບ​ຽນ​ເຂົ້າ​ລະ​ບົບ'),
      ),
      body: Container(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: this._formKey,
            child: ListView(
              children: <Widget>[
                Text(
                  '$checkemailunique',
                  style: TextStyle(color: Colors.red),
                ),
                Text('$checkphoneunique', style: TextStyle(color: Colors.red)),
                Divider(),
                TextFormField(
                    decoration: InputDecoration(
                        hintText: '​ຊື່​', labelText: '​ປ້ອນ​ຊື່ຂອງ​ທ່ານ'),
                    validator: this._validateFirstname,
                    onSaved: (String value) {
                      this._data.firstname = value;
                    }),
                TextFormField(
                    decoration: InputDecoration(
                        hintText: '​ນາມ​ສະ​ກູນ',
                        labelText: '​ປ້ອນນາມ​ສະ​ກູນຂອງ​ທ່ານ'),
                    validator: this._validateLastname,
                    onSaved: (String value) {
                      this._data.lastname = value;
                    }),
                TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: '85620 XXXXXXXX',
                        labelText: '​ປ້ອນ​ເບີ​ໂທ​ຂອງ​ທ່ານ'),
                    validator: this._validatePhone,
                    onSaved: (String value) {
                      this._data.phone = value;
                    }),
                TextFormField(
                    keyboardType: TextInputType
                        .emailAddress, // Use email input type for emails.
                    decoration: InputDecoration(
                        hintText: 'you@example.com',
                        labelText: '​ປ້ອນ​ອີ​ເມວ​ຂອງ​ທ່ານ'),
                    validator: this._validateEmail,
                    onSaved: (String value) {
                      this._data.email = value;
                    }),
                TextFormField(
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        hintText: 'ທີ​ຢູ່', labelText: '​ປ້ອນທີ​ຢູ່​ທ່ານ'),
                    onSaved: (var value) {
                      this._data.address = value;
                    }),
                Padding(
                  padding: isLoading
                      ? EdgeInsets.only(top: 20.0, bottom: 5.0)
                      : EdgeInsets.all(1.0),
                  child: Center(
                      child: isLoading ? CircularProgressIndicator() : null),
                ),
                Container(
                  width: screenSize.width,
                  child: RaisedButton(
                    child: Text(
                      '​ລົງ​ທະ​ບຽນ',
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                    onPressed: this.submit,
                    color: Colors.red,
                  ),
                  margin: EdgeInsets.only(top: 20.0),
                ),
              ],
            ),
          )),
    );
  }
}

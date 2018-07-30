import 'dart:async';
import 'dart:convert';

import 'package:erent/url_api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validate/validate.dart';
import 'package:erent/newpassword.dart';
class _VerifyData {
var codeverify = '';
}

class Verifycode extends StatefulWidget {
  VerifycodeState createState() => VerifycodeState();
}

class VerifycodeState extends State<Verifycode> {
  
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scoffoldKey = new GlobalKey<ScaffoldState>();
  _VerifyData _data = _VerifyData();

  String _validateCodeverify(String value) {
    try {
      Validate.notEmpty(value);
    } catch (e) {
      return '​ທ່ານລະ​ຫັດ​ຢັ້ງ​ຢີນ';
    }
    return null;
  }

  Future<Null> submit() async {
    // First validate form.
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.

      SharedPreferences prefs = await SharedPreferences.getInstance();
      int registerID = await prefs.get('register_id');
      final response =
          await http.post('${UrlApi().url}/index.php/api/verifycode', body: {
        'codeverify': _data.codeverify,
        'registerid':'$registerID',
      });

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print(jsonResponse);
        if (jsonResponse['id'] != null) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => NewPassword()));
        }else{
          _scoffoldKey.currentState.showSnackBar(new SnackBar(
            backgroundColor: Colors.red,
            content: new Row(
              children: <Widget>[Text('​ລະ​ຫັດ​ບໍ່​ຖືກ​ລົງ​ໃໝ່.!')],
            ),
          ));
        }
      } else {
        _scoffoldKey.currentState.showSnackBar(new SnackBar(
            backgroundColor: Colors.red,
            content: new Row(
              children: <Widget>[Text('​ມີຂໍ້​ຜິດ​ພາດ​ທາງເຊີ​ເວີ.!')],
            ),
          ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scoffoldKey,
      appBar: AppBar(
        title: Text('ຢັ້ງຢືນລະ​ຫັດ​'),
      ),
      body: Container(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: this._formKey,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
                  child: Text('ກວດ​ເບີ່ງ​ຂໍ້​ຄວາມ​ເບີ​ໂທຂອງ​ທ່ານແລ​້ວ​ປ້ອນ​ລະ​ຫັດ​ເຂົ້າ',style: TextStyle(fontSize: 16.0,)),
                ),
                Divider(),
                TextFormField(
                  keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: '​ລະ​ຫັດ', labelText: '​ປ້ອນ​​ລະ​ຫັດ​ຢັ້ງ​ຢີນ'),
                    validator: this._validateCodeverify,
                    onSaved: (String value) {
                      this._data.codeverify = value;
                    }),

                Container(
                  width: screenSize.width,
                  child: RaisedButton(
                    child: Text(
                      '​ຢັ້ງ​ຢືນ',
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                    onPressed: this.submit,
                    color: Colors.red,
                  ),
                  margin: EdgeInsets.only(top: 20.0),
                ),
                // Center(child: isLoading ? CircularProgressIndicator() : null),
              ],
            ),
          )),
    );
  }
}

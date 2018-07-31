import 'dart:async';
import 'dart:convert';

import 'package:erent/login.dart';
import 'package:erent/url_api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class _NewpasswordData {
  var password = '';
  var comfirmpassword = '';
}

class NewPassword extends StatefulWidget {
  NewPasswordState createState() => NewPasswordState();
}

class NewPasswordState extends State<NewPassword> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scoffoldKey = new GlobalKey<ScaffoldState>();
  var pw;
  var isLoading = false;
  _NewpasswordData _data = _NewpasswordData();

  String _validatePassword(String value) {
    if(value.length<3)
    {
       return '​​ຕ້ອງ​ປ້ອນລະ​ຫັດ​ລອກ​ອີນຢ່າງ​ນ້ອຍ 4 ໂຕ.!';
    }
    setState(() {
        pw = value;
      });
    return null;
    /*try {
      Validate.notEmpty(value);
      setState(() {
        pw = value;
      });
    } catch (e) {
      return '​​ຕ້ອງ​ປ້ອນລະ​ຫັດ​ລອກ​ອີນ.!';
    }
    return null;*/
  }

  String _validateComfirmpassword(String value) {
    if (value != pw) {
      return 'ລະ​ຫັດ​ຢັ້ງ​ຢືນ​ບໍ່​ຖືກ​ຕ້ອງ.!​';
    }
    return null;
  }

  Future<Null> submit() async {
    // First validate form.
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.

      //print( _data.password);
      setState(() {
        isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      int registerID = await prefs.get('register_id');
      final response =
          await http.post('${UrlApi().url}/index.php/api/newpassword', body: {
        'password': _data.password,
        'registerid': '$registerID',
      });

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print(jsonResponse);

        setState(() {
          isLoading = false;
        });

        if (jsonResponse['id'] != null) {
          await prefs.remove('register_id');
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Login()));
          print("OK");
        } else {
          _scoffoldKey.currentState.showSnackBar(new SnackBar(
            backgroundColor: Colors.red,
            content: new Row(
              children: <Widget>[Text('​​ມີຂໍ້​ຜິດ​ພາດ​.!')],
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scoffoldKey,
      appBar: AppBar(
        title: Text('ຕັ້ງ​ລະ​ຫັດ​ເຂົ້​າ​ລະ​ບົບ'),
      ),
      body: Container(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: this._formKey,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
                  child: Text('ຕັ້ງ​ລະ​ຫັດ​ໃໝ່​ເພຶ່ອ​ໃຊ້​ລອກ​ອີນເຂົ້​າ​ລະ​ບົບ',
                      style: TextStyle(
                        fontSize: 16.0,
                      )),
                ),
                Divider(),
                TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      // hintText: '​ຕັ້ງ​ລະ​ຫັດ​​ລອກ​ອີນໃໝ່',

                      labelText: '​ຕັ້ງ​ລະ​ຫັດ​​ລອກ​ອີນໃໝ່',
                    ),
                    validator: this._validatePassword,
                    onSaved: (String value) {
                      this._data.password = value;
                    }),
                TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                        //hintText: '​ຢັ້ງ​ຢືນລະ​ຫັດ​​ລອກ​ອີນໃໝ່​ອີກ​ຄັ້ງ',
                        labelText: '​ຢັ້ງ​ຢືນລະ​ຫັດ​​ລອກ​ອີນໃໝ່​ອີກ​ຄັ້ງ'),
                    validator: this._validateComfirmpassword,
                    onSaved: (String value) {
                      this._data.comfirmpassword = value;
                    }),
                Padding(
                  padding: isLoading
                      ? EdgeInsets.only(top: 20.0, bottom: 5.0)
                      : EdgeInsets.all(1.0),
                  child: Center(
                      child: isLoading ? CircularProgressIndicator() : null),
                ),
                Container(
                  //  width: screenSize.width,
                  child: RaisedButton(
                    child: Text(
                      'ບັນ​ທືກ',
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

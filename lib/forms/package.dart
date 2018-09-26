import 'dart:async';
import 'dart:convert';
import 'package:erent/forms/viewproperties.dart';
import 'package:erent/translations.dart';
import 'package:erent/url_api.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Package extends StatefulWidget {
  var houseID;
  PackageState createState() => PackageState(this.houseID);
  Package(this.houseID);
}

class PackageState extends State<Package> {
  var houseID;
  PackageState(this.houseID);

  bool isLoading = true;
  bool isloadsave = false;
  var packageID;
  var datestart;
  var validatepackage = '';
  var validateDate = '';

  final dateFormat = DateFormat("EEEE, MMMM d, yyyy 'at' h:mma");
  List<RadioModel> sampleData = new List<RadioModel>();

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

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  Future<Null> getListPackages() async {
    Dio dio = Dio();
    final responsepackge =
        await dio.get('${UrlApi().url}/index.php/api/listpackage');

    if (responsepackge.statusCode == 200) {
      var jsonResponsepackage = responsepackge.data;

      // print(jsonResponse);
      //print(jsonResponsepackage);
      isLoading = false;
      setState(() {
        for (var itempackage in jsonResponsepackage['rows']) {
          sampleData.add(new RadioModel(
              false, '${itempackage['id']}', '${itempackage['name']}'));
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

  final TextEditingController _controller = new TextEditingController();
  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = new DateTime.now();
    var initialDate = convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now)
        ? initialDate
        : now);

    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: new DateTime(2018),
        lastDate: new DateTime(9999));

    if (result == null) return;

    setState(() {
      _controller.text = new DateFormat.yMd().format(result);
      datestart = _controller.text;
    });
  }

  DateTime convertToDate(String input) {
    try {
      var d = new DateFormat.yMd().parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }

  String _validated() {
    if (packageID == null) {
      setState(() {
        validatepackage = localized.list(localized.translate, 'Must be choose package');
      });
    } else {
      setState(() {
        validatepackage = '';
      });
    }
    if (datestart == null) {
      setState(() {
        validateDate = localized.list(localized.translate, 'Must be choose date publish');
      });
    } else {
      setState(() {
        validateDate = '';
      });
    }
  }

/* =================== Save Data to server ==========================*/
  Future<Null> submit() async {
   // print(datestart);
    //print(packageID);
    if (packageID == null || datestart == null) {
      _validated();
    } else {
      //print(imgList);
      setState(() {
        isloadsave = true;
      });
      Dio dio = new Dio();
      dio.options.connectTimeout = 5000; //5s
      dio.options.receiveTimeout = 3000;

      FormData formData = new FormData.from({
        'packageID​': packageID,
        'datestart': datestart,
      });
      var response = await dio.post(
          "${UrlApi().url}/index.php/api/renewpackage?id=${houseID}",
          data: formData);
      if (response.statusCode == 200) {
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
  void initState() {
    // TODO: implement initState
    super.initState();
    loadlang();
    getListPackages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localized.list(localized.translate, 'Buy package')),
      ),
      body: Form(
        key: this._formKey,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () => _chooseDate(context, _controller.text),
                child: IgnorePointer(
                  child: TextFormField(
                    // validator: widget.validator,
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: localized.list(localized.translate, 'Choose date publish'),
                      suffixIcon: Icon(Icons.date_range),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${validateDate}',
                        style: TextStyle(color: Colors.red, fontSize: 12.0))
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[Text(localized.list(localized.translate, 'Choose package you want to buy'))],
              ),
            ),
            (isLoading)
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: sampleData.length,
                      itemBuilder: (BuildContext context, index) {
                        return InkWell(
                          //highlightColor: Colors.red,

                          splashColor: Colors.blueAccent,

                          onTap: () {
                            setState(() {
                              sampleData.forEach(
                                  (element) => element.isSelected = false);

                              sampleData[index].isSelected = true;

                              var package_id =
                                  RadioItem(sampleData[index])._item.buttonText;

                              packageID = package_id;
                            });
                          },

                          child: new RadioItem(sampleData[index]),
                        );
                      },
                    ),
                  ),
            (isloadsave)
                ? CircularProgressIndicator()
                : ListBody(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(
                          onPressed: () {
                            submit();
                          },
                          color: Colors.red,
                          child: Text(
                            localized.list(localized.translate, 'Buy'),
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class RadioItem extends StatelessWidget {
  final RadioModel _item;
  RadioItem(this._item);
  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.all(15.0),
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new Container(
            height: 25.0,
            width: 25.0,
            child: new Center(
              child: _item.isSelected ? Icon(Icons.done) : Text(''),
            ),
            decoration: new BoxDecoration(
              color: _item.isSelected ? Colors.red : Colors.transparent,
              border: new Border.all(
                  width: 1.0,
                  color: _item.isSelected ? Colors.red : Colors.grey),
              borderRadius: const BorderRadius.all(const Radius.circular(2.0)),
            ),
          ),
          new Container(
            margin: new EdgeInsets.only(left: 10.0),
            child: new Text(_item.text),
          )
        ],
      ),
    );
  }
}

class RadioModel {
  bool isSelected;
  final String buttonText;
  final String text;

  RadioModel(this.isSelected, this.buttonText, this.text);
}

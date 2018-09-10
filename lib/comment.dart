import 'dart:async';

import 'package:dio/dio.dart';
import 'package:erent/url_api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Comment extends StatefulWidget {
  var houseID;
  CommentState createState() => CommentState(this.houseID);
  Comment(this.houseID);
}

class CommentState extends State<Comment> {
  var houseID;
  CommentState(this.houseID);

/* ============== Get list comment ============= */
  List listComment = List();
  var photo_profile;
  var userID;
  _Getlistcomment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var photoProfile = await prefs.get('photo_profile');
    var token = await prefs.get('token');
    Dio dio = new Dio();
    final responseList = await dio
        .get('${UrlApi().url}/index.php/api/listcomments?houseID=${houseID}');
    if (responseList.statusCode == 200) {
      print(responseList.data); 
      setState(() { 
        listComment = responseList.data;
        photo_profile = photoProfile;
        userID=token;
      });
    }
  }

  /*========= answer comment =======*/
  var answerInput;
  int idcomment = 0;
  answerComment(var answer, int idcommentinput) async {
    Dio dio = new Dio();
    FormData formData = new FormData.from({
      'smg': answer,
      'userID': userID,
      'houseID': houseID,
      'idq':idcommentinput
    });
    var response = await dio.post("${UrlApi().url}/index.php/api/addcomments",
        data: formData);
    if (response.statusCode == 200) {
    }
    //print(answer);
    setState(() {
      idcomment = idcommentinput;
      answerInput = answer;
    });
    //print(idcomment);
  }

  Future<Null> getanswer(int idq) async {
    Dio dio = new Dio();
    final responseList = await dio
        .get('${UrlApi().url}/index.php/api/listanswers?idq=${idq}');
    if (responseList.statusCode == 200) {
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _Getlistcomment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comment'), 
      ),
      body: ListView.builder(
        itemCount: listComment.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  listComment[index]['user']['register']['photo'] == null
                      ? AssetImage('assets/img/user.jpg')
                      : NetworkImage('${UrlApi().url}/images/small/'
                          '${listComment[index]['user']['register']['photo']}'),
            ),
            title:
                Text('${listComment[index]['user']['register']['first_name']}'),
            subtitle:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              Text('${listComment[index]['smg']}'),
              idcomment != int.parse(listComment[index]['id'])
                  ? IconButton(
                      icon: Icon(
                        Icons.question_answer,
                        color: Colors.red,
                      ),
                      iconSize: 20.0,
                      onPressed: () {
                        showDialog(
                            context: context,
                            child: AlertDialog(
                              content: TextField(
                                maxLines: 2,
                                keyboardType: TextInputType.multiline,
                                decoration:
                                    InputDecoration(labelText: "ປ້ອນ​ຄຳ​ເຫັນ"),
                                onChanged: (String text) {
                                  answerInput = text;
                                },
                              ),
                              actions: <Widget>[
                                FlatButton(
                                    child: Icon(Icons.send, color: Colors.red),
                                    onPressed: () {
                                      answerComment(answerInput,
                                          int.parse(listComment[index]['id']));
                                      Navigator.of(context).pop();
                                    })
                              ],
                            ));
                      },
                    )
                  : Text(''), 
              (idcomment == int.parse(listComment[index]['id']))
                  ? Text('www', 
                      style: TextStyle(  
                        color: Colors.blue, 
                      ))
                  :Text('sssss')
            ]), 
          );
        },
      ),
    );
  }
}

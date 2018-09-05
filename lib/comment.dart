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
  _Getlistcomment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var photoProfile = await prefs.get('photo_profile');
    Dio dio = new Dio();
    final responseList = await dio
        .get('${UrlApi().url}/index.php/api/listcomments?houseID=${houseID}');
    if (responseList.statusCode == 200) {
      setState(() {
        listComment = responseList.data;
        photo_profile = photoProfile;
      });
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
            subtitle: Text('${listComment[index]['smg']}'),
          );
        },
      ),
    );
  }
}

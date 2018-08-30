import 'package:dio/dio.dart';
import 'package:erent/url_api.dart';
import 'package:flutter/material.dart';

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
  _Getlistcomment() async {
    Dio dio = new Dio();
    final responseList = await dio
        .get('${UrlApi().url}/index.php/api/listcomments?houseID=${houseID}');
    if (responseList.statusCode == 200) {
      setState(() {
        listComment = responseList.data;
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
                backgroundImage: AssetImage('assets/img/user.jpg')),
            title:
                Text('${listComment[index]['user']['register']['first_name']}'),
            subtitle: Text('${listComment[index]['smg']}'),
          );
        },
      ),
    );
  }
}

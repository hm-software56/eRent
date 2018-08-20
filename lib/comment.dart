import 'package:flutter/material.dart';

class Comment extends StatefulWidget {
  CommentState createState() => CommentState();
}

List listComment = List();

class CommentState extends State<Comment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comment'),
      ),
      body: ListView.builder(
        itemBuilder: (context, int index) {
          return Text('aaaaaa');
        },
        itemCount: listComment != null ? listComment.length : 0,
      ),
    );
  }
}

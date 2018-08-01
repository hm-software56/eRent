import 'dart:async';
import 'dart:convert';

import 'package:erent/url_api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:zoomable_image/zoomable_image.dart';

class ViewPhoto extends StatefulWidget {
  var did;
  ViewPhoto(this.did);
  ViewPhotoState createState() => ViewPhotoState(this.did);
}

class ViewPhotoState extends State<ViewPhoto> {
  var did;
  ViewPhotoState(this.did);

  var photos;
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return new Scaffold(
      appBar: AppBar(),
      body: ZoomableImage(
          did,
          backgroundColor: Colors.white),
    );
  }
}

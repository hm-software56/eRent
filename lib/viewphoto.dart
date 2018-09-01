import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

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
        body: PhotoView(
          imageProvider: NetworkImage(did),
          maxScale: 4.0,
        ));
  }
}

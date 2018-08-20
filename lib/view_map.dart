import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class ViewMap extends StatefulWidget{
  double long;
  double lat;
  ViewMapState createState()=>  ViewMapState(this.long,this.lat);
  ViewMap(this.long,this.lat);
}


class ViewMapState extends State<ViewMap> {
  double long;
  double lat;
  ViewMapState(this.long,this.lat);
  
  @override
  Widget build(BuildContext context){
    return new FlutterMap(
      options: new MapOptions(
        center: new LatLng(long, lat),
        zoom: 13.0,
      ),
      layers: [
        new TileLayerOptions(
          urlTemplate: "https://api.tiles.mapbox.com/v4/"
              "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
          additionalOptions: {
            'accessToken': 'pk.eyJ1IjoiZGF4aW9uZ2luZm8iLCJhIjoiY2prdXVvbzhiMGFqbTN3bXF0OXUyNDBieCJ9.XPJHscYSWGrXWBna8eRJfA',
            'id': 'mapbox.streets',
          },
        ),
        new MarkerLayerOptions(
          markers: [
            new Marker(
              width: 40.0,
              height: 40.0,
              point: new LatLng(long, lat),
              builder: (ctx) =>
              new Container(
                child:Icon(Icons.location_on,color:Colors.red,), 
                
              ),
            ),
          ],
        ),
      ],
    );
  }
}
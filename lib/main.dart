import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS and Time App',
      home: GpsTimeHomePage(),
    );
  }
}

class GpsTimeHomePage extends StatefulWidget {
  @override
  _GpsTimeHomePageState createState() => _GpsTimeHomePageState();
}

class _GpsTimeHomePageState extends State<GpsTimeHomePage> {
  String _timeString = "";
  String _locationString = "Getting location...";

  @override
  void initState() {
    super.initState();
    _getTime();
    _getLocation();
  }

  void _getTime() {
    final String formattedDateTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().toUtc());
    setState(() {
      _timeString = "GMT Time: $formattedDateTime";
    });
  }

  void _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    } 

    // When permissions are granted
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _locationString = "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPS and Time App'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(_timeString, style: TextStyle(fontSize: 20)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(_locationString, style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}

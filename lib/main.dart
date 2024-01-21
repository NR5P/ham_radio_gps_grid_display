import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ham Radio Grid Square App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Ham Radio Grid Square Finder'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String gridSquare = "";
  String currentTime = "";
  String dayOfWeek = "";
  String date = "";

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    getCurrentTime();
  }

  void getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
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

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      gridSquare = calculateGridSquare(position.latitude, position.longitude);
    });
  }

  void getCurrentTime() {
    Timer.periodic(Duration(seconds: 1), (Timer t) => updateTime());
  }

  void updateTime() {
    setState(() {
      currentTime = DateFormat('HH:mm:ss').format(DateTime.now().toUtc()) + " z";
      dayOfWeek = DateFormat('EEEE').format(DateTime.now());
      date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    });
  }

  String calculateGridSquare(double latitude, double longitude) {
    // Longitude calculations
    int longIndex = ((longitude + 180) / 20).floor();
    String longLetter = String.fromCharCode('A'.codeUnitAt(0) + longIndex);
    int longNumber = (((longitude + 180) % 20) / 2).floor();
    int longSubLetterIndex = ((((longitude + 180) % 20) % 2) * 12).floor();
    String longSubLetter = String.fromCharCode('a'.codeUnitAt(0) + longSubLetterIndex);

    // Latitude calculations
    int latIndex = ((latitude + 90) / 10).floor();
    String latLetter = String.fromCharCode('A'.codeUnitAt(0) + latIndex);
    int latNumber = ((latitude + 90) % 10).floor();
    int latSubLetterIndex = ((((latitude + 90) % 10) % 1) * 24).floor();
    String latSubLetter = String.fromCharCode('a'.codeUnitAt(0) + latSubLetterIndex);

    // Combining the results
    return longLetter + latLetter + longNumber.toString() + latNumber.toString() + longSubLetter + latSubLetter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns children with space in between
      children: <Widget>[
        // Top part for day, date, and time
        Column(
          children: <Widget>[
            SizedBox(height: 20), // Adds some space at the top
            Text(
              dayOfWeek,
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              date,
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              currentTime,
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
        // Bottom part for grid square
        Padding(
          padding: EdgeInsets.only(bottom: 20), // Adds some space at the bottom
          child: Text(
            gridSquare,
            style: Theme.of(context).textTheme.headline4,
          ),
        ),
      ],
    )),
    );
  }
}

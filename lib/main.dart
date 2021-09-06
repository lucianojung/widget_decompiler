import 'package:flutter/material.dart';
import 'package:widget_decompiler/widget_decompiler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title of the app
      title: 'Widget Decompiler Demo',
      // home page of the app
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // constructor
  MyHomePage();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: WidgetDecompiler(),
      ),
    );
  }
}

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
  bool show = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            show = !show;
          });
        },
      ),
      body: WidgetDecompiler(
        width: 1000,
        child: testWidget(),
        show: show,
      ),
    );
  }
}

Widget testWidget() {
  return Container(
    child: Row(
      children: [
        Container(),
        Container()
      ],
    ),
     width: 1000,
     height: 100,
    color: MaterialColor(0xfff44336, Map()),
  );
}
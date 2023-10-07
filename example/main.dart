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
      // theme of the app
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF67BCB3)),
        useMaterial3: true,
      ),
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
        child: Icon(!show ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            show = !show;
          });
        },
      backgroundColor: Color(0xFF67BCB3),
      ),
      body: WidgetDecompiler(
        width: 1000,
        child: testWidget(),
        showWidget: show,
        backgroundColor: Color(0xFF67BCB3),
      ),
    );
  }
}

Widget testWidget() {
  return Center(
    child: Container(
      child: Image.asset('assets/flutter_packages_logo_512.png',),
    )
  );
}

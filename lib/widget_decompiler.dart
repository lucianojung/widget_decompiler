import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'GlobalList.dart';

class WidgetDecompiler extends StatefulWidget {
  final Widget child;
  final String widgetName;
  final Color? backgroundColor;

  const WidgetDecompiler(
      {Key? key, required this.child, this.widgetName = 'MyWidget', this.backgroundColor})
      : super(key: key);

  @override
  _WidgetDecompilerState createState() => _WidgetDecompilerState();
}

class _WidgetDecompilerState extends State<WidgetDecompiler>{
  bool _unfolded = false;
  String _childWidgetTree = '';
  BuildContext? _context;

  String _widgetName = '';

  @override
  void initState() {
    _widgetName = widget.widgetName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Builder(builder: (context) {
              _context = context;
              return widget.child;
            }),
            Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                            icon: Icon(Icons.copy),
                            tooltip: 'copy widget Codeblock',
                            onPressed: () {
                              // getSourceTree(_context!.widget.toStringShort(), _context);
                              getWidgetTree('RedBoxWidget', _context);
                              Clipboard.setData(
                                ClipboardData(text: _childWidgetTree),
                              );
                              final snackBar = SnackBar(
                                  content: Text('Copied widget code to clipboard'),
                                  backgroundColor: Theme.of(context).primaryColor);
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            }),
                        Spacer(),
                        IconButton(
                          icon: Icon(_unfolded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down),
                          onPressed: () {
                            getWidgetTree(_widgetName, _context);
                            setState(() {
                              _unfolded = !_unfolded;
                            });
                          },
                        ),
                      ],
                    ),
                    if (_unfolded)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SelectableText(
                          _childWidgetTree,
                          style: TextStyle(
                            fontFamily: 'AzeretMono-Medium',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getWidgetTree(String widgetName, BuildContext? context) {
    _childWidgetTree = 'Widget $widgetName() {\n';
    _childWidgetTree += '  return Container(\n';
    _getWidgetElementAndChildren(context, 2, context!.widget);
    _childWidgetTree += '  );\n';
    _childWidgetTree += '}';
  }

  _getWidgetElementAndChildren(BuildContext? context, int tabs, Widget parent) {
    context!.visitChildElements((element) {
      String s = '';
      for (int i = 0; i < tabs; i++) {
        s += '  ';
      }
      List<String> tempKnownChildren =
          GlobalLists.knownChildren[parent.toStringShort()] ?? [];
      if (tempKnownChildren
          .contains(element.toStringShort().split('-').first)) {
        _getWidgetElementAndChildren(element, tabs, parent);
      } else {
        String widgetName = element.widget.toStringShort().split('-').first;
        if (GlobalLists.multipleChildrenWidgets.keys.contains(widgetName)) {
          _childWidgetTree += '$s child: $widgetName( ${GlobalLists.multipleChildrenWidgets[widgetName]}: [\n';
        } else {
          _childWidgetTree += '$s child: $widgetName(\n';
        }
        // print(context.runtimeType);
        _getWidgetElementAndChildren(
            element,
            tabs + 1,
            GlobalLists.knownChildren
                    .containsKey(element.widget.toStringShort())
                ? element.widget
                : parent);

        if (GlobalLists.multipleChildrenWidgets.keys.contains(widgetName)) {
          _childWidgetTree += s + ']),\n';
        } else {
          _childWidgetTree += s + '),\n';
        }
      }
    });
  }

}

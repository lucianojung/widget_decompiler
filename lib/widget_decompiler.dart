import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'GlobalList.dart';

class WidgetDecompiler extends StatefulWidget {
  @override
  _WidgetDecompilerState createState() => _WidgetDecompilerState();
}

class _WidgetDecompilerState extends State<WidgetDecompiler> {
  final Widget _child = SizedBox(
    child: Container(),
    height: 100,
    width: 400,
  );

  bool _unfolded = false;
  String _childWidgetTree = '';
  BuildContext? _context;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Builder(
                builder: (context) {
                  _context = context;
                  return _child;
                }
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(16.0),
                    bottomLeft: Radius.circular(16.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                              icon: Icon(Icons.copy),
                              tooltip: 'copy widget Codeblock',
                              onPressed: () {
                                getWidgetTree('RedBoxWidget', _context);
                                Clipboard.setData(
                                  ClipboardData(text: _childWidgetTree),
                                );
                              }),
                          Spacer(),
                          IconButton(
                            icon: Icon(_unfolded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down),
                            onPressed: () {
                              getWidgetTree('RedBoxWidget', _context);
                              setState(() {
                                _unfolded = !_unfolded;
                              });
                            },
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: SelectableText(
                          _unfolded ? _childWidgetTree : '',
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
      if (tempKnownChildren.contains(element.toStringShort().split('-').first)) {
        _getWidgetElementAndChildren(element, tabs, parent);
      } else {
        String widgetName = element.widget.toStringShort().split('-').first;
        if(GlobalLists.multipleChildrenWidgets.contains(widgetName)) {
          _childWidgetTree += '$s child: $widgetName( children: [\n';
        } else {
          _childWidgetTree += '$s child: $widgetName(\n';
        }
        // print(context.runtimeType);
        _getWidgetElementAndChildren(
            element,
            tabs + 1,
            GlobalLists.knownChildren.containsKey(element.widget.toStringShort())
                ? element.widget
                : parent);

        if(GlobalLists.multipleChildrenWidgets.contains(widgetName)) {
          _childWidgetTree += s + ']),\n';
        } else {
          _childWidgetTree += s + '),\n';
        }
      }
    });
  }

}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WidgetDecompiler extends StatefulWidget {
  final Widget child;
  final String widgetName;
  final Color? backgroundColor;
  final bool show;
  final double? width;

  const WidgetDecompiler(
      {Key? key,
      required this.child,
      this.widgetName = 'MyWidget',
      this.backgroundColor,
      this.show = true,
      this.width});

  @override
  _WidgetDecompilerState createState() => _WidgetDecompilerState();
}

class _WidgetDecompilerState extends State<WidgetDecompiler> {
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
    return SingleChildScrollView(
      child: SizedBox(
        width: widget.width,
        child: Align(
          alignment: Alignment.topCenter,
          child: widget.show
              ? Column(
                  children: [
                    Builder(builder: (context) {
                      _context = context;
                      return widget.child;
                    }),
                    Container(
                      decoration: BoxDecoration(
                        color: widget.backgroundColor ??
                            Theme.of(context).primaryColor,
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
                                    icon:
                                        Icon(Icons.copy, color: Colors.black87),
                                    tooltip: 'copy widget Codeblock',
                                    onPressed: () {
                                      // getSourceTree(_context!.widget.toStringShort(), _context);
                                      getWidgetTree(widget.child,
                                          widget.widgetName, _context);
                                      Clipboard.setData(
                                        ClipboardData(text: _childWidgetTree),
                                      );
                                      final snackBar = SnackBar(
                                          content: Text(
                                              'Copied widget code to clipboard',
                                              style: TextStyle(
                                                  color: Colors.black)),
                                          backgroundColor: widget
                                                  .backgroundColor ??
                                              Theme.of(context).primaryColor);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    }),
                                Spacer(),
                                IconButton(
                                  icon: Icon(
                                      _unfolded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.black87),
                                  onPressed: () {
                                    getWidgetTree(
                                        widget.child, _widgetName, _context);
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
                                  // style: TextStyle(
                                  //   fontFamily: 'AzeretMono-Medium',
                                  // ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : widget.child,
        ),
      ),
    );
  }

  getWidgetTree(Widget child, String widgetName, BuildContext? context) {
    _childWidgetTree = 'Widget $widgetName() {\n';
    _childWidgetTree += '  return Container(\n';
    //print(_diagnosticNode.getProperties()); //-> gives attribute information
    _getChildElement(context, 2, 1);
    //_getWidgetElementAndChildren(context, 2, context!.widget);
    _childWidgetTree += '  );\n';
    _childWidgetTree += '}';
  }

  _getChildElement(BuildContext? context, int depth, childrenCount) {
    var childIndex = 1;
    context!.visitChildElements((Element element) {
      String widgetName = element.toDiagnosticsNode().getProperties()[1].value.toString().split('(')[0];

      if (widgetName.startsWith('_')) {
        //skip this widget
        _getChildElement(
            element, depth, element.toDiagnosticsNode().getChildren().length);
      }

      // print('*widget: ${element.toDiagnosticsNode().getProperties()[1]} -- depth $depth');
      // print('--properties: ${element.toDiagnosticsNode().getProperties()}');
      // print('--children: ${element.toDiagnosticsNode().getChildren()}');
      _addDepthTabs(depth);
/*      element
          .toDiagnosticsNode()
          .getProperties()
          .where((element) => element.toString().contains('BoxConstraints'))
          .forEach((element2) {
        print(element2.value);
        print(element2.name);
        print(element2.level);
        print(element2.emptyBodyDescription);
        print(element2.linePrefix);
        print(element2.runtimeType);
        print(element2.toString());
        print(element2.getProperties());
        print(element2.getChildren());
        print(element2.toTimelineArguments());
        print(element2.toDescription());
        print(element2.toStringDeep());
      });*/

      if (childrenCount == 1) {
        _childWidgetTree +=
            'child: $widgetName (\n';
      } else {
        depth += 1;
        if (childIndex == 1) {
          _childWidgetTree += 'children: [\n';
          _addDepthTabs(depth);
        }
        _childWidgetTree +=
            '$widgetName (\n';
      }
      _getChildElement(
          element, depth + 1, element.toDiagnosticsNode().getChildren().length);

      element
          .toDiagnosticsNode()
          .getProperties()
          .where((element) =>
              !element.toString().contains('null') &&
              !element.toString().contains('widget'))
          .forEach((element) {
        //print(element.value.toString());

        //is color
        var regexHexColor = RegExp('0xff(?:[0-9a-fA-F]{6})');
        if (element.toString().contains(regexHexColor)) {
          var name = element.name.toString().length > 2
              ? element.name.toString()
              : 'color';
          print(regexHexColor.allMatches(element.value.toString()));
          var value =
              'MaterialColor(${regexHexColor.firstMatch(element.value.toString())?.group(0)}, Map())';

          _addDepthTabs(depth);
          _childWidgetTree += '$name: $value,\n';
        }

        //is object (default)
        else if (element.toString().contains('(')) {
          var name = element.name.toString();
          var value = element.value.toString();
          value = value.replaceAll('w=', 'minWidth: ');
          value = value.replaceAll('h=', 'minHeight: ');
          value = value.replaceAll('biggest', '');

          _addDepthTabs(depth);
          _childWidgetTree += '$name: $value,\n';
        }
      });

      _addDepthTabs(depth);
      _childWidgetTree += '),\n';

      if (childIndex == childrenCount && childrenCount > 1) {
        _addDepthTabs(depth);
        _childWidgetTree += '],\n';
      }

      depth -= 1;
      childIndex++;
    });
  }

  _addDepthTabs(int depth) {
    for (int i = 0; i < depth; i++) {
      _childWidgetTree += '   ';
    }
  }
}

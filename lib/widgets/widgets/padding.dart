import 'package:flutter/cupertino.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/utils/style_parse.dart';
import '../widget.dart';

class TWidgetPadding extends TWidget{
  
  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}){
    
    var attrs = getAttributes(node);
    dynamic child;
    
    if (node.children.isNotEmpty) {
      child = Tuna3.parseWidget(node.children[0], jsRuntime,styleSheet: styleSheet);
    }
    return  Padding(
      padding: StyleParse.edgeInsetsGeometry( attrs['padding']),
      child: child,
    );
  }
}
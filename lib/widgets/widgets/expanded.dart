import 'package:flutter/material.dart';
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:html/dom.dart' as dom;
import '../../tuna3.dart';
import '../constants.dart';
import '../widget.dart';

class TWidgetExpanded extends TWidget{
  
  TWidgetExpanded():super(tagName:'expanded');

  @override
  parse(dom.Element node,JsRuntime jsRuntime, {TStyleSheet? styleSheet}){
    Map<String,dynamic>? attrs = getAttributes(node);
    dynamic child;
    if(node.children.isNotEmpty){
      child = Tuna3.parseWidget(node.children[0],jsRuntime,styleSheet:styleSheet);
    }else{
      child = Container();
    }

    // print(child);
  
    var _ret =  Expanded(
      child: child,
      flex: attrs.containsKey(AttrNames.flex) ? int.parse(attrs[AttrNames.flex]) : 1,
    );
    // print(_ret);
    return _ret;
  }
}

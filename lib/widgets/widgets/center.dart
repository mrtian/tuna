import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/tuna3.dart';
import '../../style_sheet.dart';
import '../constants.dart';
import '../widget.dart';


class TWidgetCenter  extends TWidget{
  TWidgetCenter():super(tagName: 'center');
  
  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}) {
    var attrs  = getAttributes(node);
    return Center(
      widthFactor: attrs.containsKey(AttrNames.widthFactor) ?  double.parse(attrs[AttrNames.widthFactor]) : null,
      heightFactor:
          attrs.containsKey(AttrNames.heightFactor) ? double.parse(attrs[AttrNames.heightFactor]) : null,
      child:  Tuna3.parseWidget( node.children[0],jsRuntime,styleSheet: styleSheet),
    );
  }
}

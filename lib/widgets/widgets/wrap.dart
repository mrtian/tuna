import 'package:flutter/material.dart';
import 'package:tuna3/tuna3.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/utils/style_parse.dart';

import '../../js_runtime.dart';
import '../../style_sheet.dart';
import '../constants.dart';
import '../widget.dart';

class TWidgetWrap extends TWidget{
  
  TWidgetWrap():super(tagName: 'wrap');

  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}) {
    print(node);
    Map<String,dynamic> attrs = getAttributes(node);
    List children = node.children;
    List<Widget> _children = [];

    if(children.isNotEmpty && children.isNotEmpty){
      children.forEach((item){
        var ret = Tuna3.parseWidget(node, jsRuntime,styleSheet: styleSheet);
        if(ret is List){
          ret.forEach((item){
            _children.add(item);
          });
        }else{
          _children.add(ret);
        }
      });
    }

    return Wrap(
      direction: attrs.containsKey(AttrNames.direction)
          ? StyleParse.axis(attrs[AttrNames.direction])
          : Axis.horizontal,
      alignment: attrs.containsKey(AttrNames.alignment)
          ? StyleParse.wrapAlignment(attrs[AttrNames.alignment])
          : WrapAlignment.start,
      spacing: attrs.containsKey(AttrNames.spacing) ? double.parse(attrs[AttrNames.spacing]) : 0.0,
      runAlignment: attrs.containsKey(AttrNames.runAlignment)
          ? StyleParse.wrapAlignment(attrs[AttrNames.runAlignment])
          : WrapAlignment.start,
      runSpacing: attrs.containsKey(AttrNames.runSpacing) ? double.parse(attrs[AttrNames.runSpacing]) : 0.0,
      crossAxisAlignment: attrs.containsKey(AttrNames.crossAxisAlignment)
          ? StyleParse.wrapCrossAlignment(attrs[AttrNames.crossAxisAlignment])
          : WrapCrossAlignment.start,
      textDirection: attrs.containsKey(AttrNames.textDirection)
          ? StyleParse.textDirection(attrs[AttrNames.textDirection])
          : null,
      verticalDirection: attrs.containsKey(AttrNames.verticalDirection)
          ? StyleParse.verticalDirection(attrs[AttrNames.verticalDirection])
          : VerticalDirection.down,
      children: _children,
    );
    
  }
}
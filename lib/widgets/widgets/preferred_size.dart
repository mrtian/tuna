import 'dart:ui';
import 'package:html/dom.dart' as dom;
import 'package:flutter/material.dart';
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/tuna3.dart';

import '../../style_sheet.dart';
import '../constants.dart';
import '../widget.dart';

class TWidgetPreferredSize  extends TWidget{
  
  TWidgetPreferredSize():super(tagName: ['psize','preferredSize']);

  @override
  parse(dom.Element node, JsRuntime jsRuntime, {TStyleSheet? styleSheet}) {
    var attrs = getAttributes(node);
    double? width = attrs.containsKey(AttrNames.width)?double.parse(attrs[AttrNames.width]):null;
    double? height = attrs.containsKey(AttrNames.height)?double.parse(attrs[AttrNames.height]):null;
    var size;
    if(width==null && height!=null){
      size = Size.fromHeight(height);
    }else if(height==null && width!=null){
      size = Size.fromWidth(width);
    }else{
      size = Size(width!,height!);
    }
    return PreferredSize(
      preferredSize:size,
      child: Tuna3.parseWidget(node.children[0], jsRuntime,styleSheet: styleSheet)
    );
  }
}
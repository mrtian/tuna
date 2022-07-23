import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/tuna3.dart';
import '../constants.dart';
import '../widget.dart';

class TWidgetSize extends TStyleWidget{
  TWidgetSize():super(tagName: ['size','sizedBox']);

  @override
  build(dom.Element node, JsRuntime jsRuntime, {TStyleSheet? styleSheet}) {
    Map<String,dynamic> attrs = getAttributes(node);
    bool expand = attrs['expand']=="true"?true:false;

    dynamic child;
    if(node.children.isNotEmpty){
      child = Tuna3.parseWidget(node.children[0],jsRuntime,styleSheet: styleSheet);
    }
    if(expand==true){
      return SizedBox.expand(
        child:child,
      );
    }else{
      var width = attrs.containsKey(AttrNames.width) ? double.parse(attrs["width"]) : null;
      var height = attrs.containsKey(AttrNames.height) ? double.parse(attrs["height"]) : null;
      var ret =  SizedBox(
        width: width,
        height: height,
        child: child,
      );
      // print(ret);
      return ret;
    }
  }
}

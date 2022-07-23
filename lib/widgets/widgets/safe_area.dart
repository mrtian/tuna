import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/utils/style_parse.dart';
import '../constants.dart';
import '../widget.dart';

class TWidgetSafeArea  extends TWidget{
  
  TWidgetSafeArea():super(tagName: ['safeArea','safearea']);

  @override
  parse( dom.Element node, JsRuntime jsRuntime, {TStyleSheet? styleSheet}) {
    var attrs = getAttributes(node);
    return SafeArea(
      left: attrs.containsKey(AttrNames.left)?StyleParse.bool(attrs[AttrNames.left]):true, 
      top: attrs.containsKey(AttrNames.top)?StyleParse.bool(attrs[AttrNames.top]):true, 
      right: attrs.containsKey(AttrNames.right)?StyleParse.bool(attrs[AttrNames.right]):true, 
      bottom: attrs.containsKey(AttrNames.bottom)?StyleParse.bool(attrs[AttrNames.bottom]):true,
      minimum:attrs.containsKey(AttrNames.minimum)?StyleParse.edgeInsetsGeometry(attrs[AttrNames.minimum]):EdgeInsets.zero,
      child: node.children.isNotEmpty? Tuna3.parseWidget(node.children[0], jsRuntime,styleSheet: styleSheet):null,
    );
  }
}

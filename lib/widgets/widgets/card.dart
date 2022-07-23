import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/utils/style_parse.dart';
import '../../tuna3.dart';
import '../widget.dart';
import './icon.dart';


class TWidgetCard  extends TWidget{

  TWidgetCard():super(tagName: 'card');

  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}) {
    var attrs  = getAttributes(node);
    var color = attrs['color']==null?null:StyleParse.hexColor(attrs['color']);
    var shadowColor = attrs['shadowColor']==null?null:StyleParse.hexColor(attrs['shadowColor']);
    double? elevation = attrs['elevation'] == null?null:double.parse(attrs['elevation']);
    var margin = attrs['margin']==null?null:StyleParse.edgeInsetsGeometry(attrs['margin']); 
    
    return Card(
      color:color,
      shadowColor:shadowColor,
      elevation:elevation,
      margin:margin,
      child:Tuna3.parseWidget(node.children[0],jsRuntime,styleSheet:styleSheet),
    );
  }
}

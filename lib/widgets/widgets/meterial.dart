import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/utils/style_parse.dart';

import '../constants.dart';
import '../widget.dart';

class TWidgetMeterial  extends TWidget{
  
  TWidgetMeterial():super(tagName: 'meterial');
  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}){
    
    var attrs = getAttributes(node);
    var child = Tuna3.parseWidget(node.children[0],jsRuntime,styleSheet: styleSheet);
    var color = attrs.containsKey(AttrNames.color)
				? StyleParse.hexColor(attrs[AttrNames.color])
				: null;
    
    var shadowColor = attrs.containsKey("shadowColor")
				? StyleParse.hexColor(attrs["shadowColor"])
				: null;
    double elevation = attrs['elevation']!=null?double.parse(attrs['elevation']):0.0;
    TextStyle textStyle = attrs['textStyle']!=null?StyleParse.textStyle( StyleParse.convertAttr(attrs['textStyle'])):null;
    var borderRadius =  attrs['radius'] !=null ? StyleParse.borderRadius(attrs['radius']):null;

    return  Material(
      color: color,
      shadowColor: shadowColor,
      elevation:elevation,
      child: child,
      textStyle:textStyle,
      borderRadius:borderRadius
    );
  }
}
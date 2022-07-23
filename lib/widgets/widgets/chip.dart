import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/utils/style_parse.dart';
import '../../tuna3.dart';
import '../widget.dart';
import './icon.dart';


class TWidgetChip  extends TWidget{

  TWidgetChip():super(tagName: 'chip');

  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}) {
    var attrs  = getAttributes(node);
    var bgColor = attrs['backgroundColor']==null?null:StyleParse.hexColor(attrs['backgroundColor']);
    var deleteIcon = attrs['deleteIcon'] == null?null:TWidgetIcon.parseIconName(attrs['deleteIcon']);
    var deleteIconColor = attrs['deleteIconColor']==null?null:StyleParse.hexColor(attrs['deleteIconColor']); 
    var shadowColor = attrs['shadowColor']==null?null:StyleParse.hexColor(attrs['shadowColor']);
    var radius = attrs['radius']!=null?double.parse(attrs['radius']):5.0;
    var avatar;
    var label;
    var density = attrs['density']!=null?attrs['density'].split(","):[0.0,0.0];

    node.children.forEach((dom.Element element) {
      if(element.localName=="avatar"){
        avatar = Tuna3.parseWidget( node.children[0],jsRuntime,styleSheet:styleSheet);
      }
      
      if(element.localName=="label"){
        label = Tuna3.parseWidget(node.children[0],jsRuntime,styleSheet:styleSheet);
      }

    });
    return Chip(
      backgroundColor:bgColor,
      deleteIcon:deleteIcon,
      deleteIconColor: deleteIconColor,
      padding: attrs['padding']!=null?StyleParse.edgeInsetsGeometry(attrs['padding']):null,
      // visualDensity:,
      elevation:attrs['elevation']!=null?double.parse(attrs['elevation']):0.0,
      shadowColor: shadowColor,
      materialTapTargetSize:MaterialTapTargetSize.padded,
      onDeleted:attrs['onDeleted']!=null?(){
        jsRuntime.evaluate(attrs['onDeleted']);
      } :null,
      deleteButtonTooltipMessage:attrs['delTooltip'],
      avatar: avatar,
      visualDensity:VisualDensity(horizontal: double.parse(density[0].toString()),vertical: double.parse(density[1].toString())),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      label: label,
      labelPadding: attrs['labelPadding']!=null?StyleParse.edgeInsetsGeometry(attrs['labelPadding']):null,
      labelStyle: attrs['labelStyle']!=null?StyleParse.textStyle(attrs['labelStyle']):null,
      autofocus: attrs['autofocus']=="true"?true:false,
    );
  }
}

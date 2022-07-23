import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/utils/style_parse.dart';

import '../../tuna3.dart';
import '../constants.dart';
import '../widget.dart';


class TWidgetButton extends TWidget {

  TWidgetButton():super(tagName: 'button');

  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}) {
    
    Map<String, dynamic> attrs = getAttributes(node);

    String btnType = attrs['type'] ?? 'raised';

    double radius = attrs.containsKey(AttrNames.radius)
      ? double.parse(attrs[AttrNames.radius]) : btnType=="flat"?0.0:5.0;
    Color? color = attrs.containsKey(AttrNames.color) ? StyleParse.hexColor(attrs[AttrNames.color]) : null;
    Color? disabledColor = attrs.containsKey(AttrNames.disabledColor)
            ? StyleParse.hexColor(attrs[AttrNames.disabledColor])
            : null;
    var disabledElevation = attrs.containsKey(AttrNames.disabledElevation) ? double.parse(attrs[AttrNames.disabledElevation]) : 0.0;
    var disabledTextColor = attrs.containsKey(AttrNames.disabledTextColor) ? StyleParse.hexColor(attrs[AttrNames.disabledTextColor]) : null;
    var elevation = attrs.containsKey(AttrNames.elevation) ? double.parse(attrs[AttrNames.elevation]) : 2.0;
    var padding = attrs.containsKey(AttrNames.padding)
            ? StyleParse.edgeInsetsGeometry(attrs[AttrNames.padding])
            : const EdgeInsets.all(0.0);
    var splashColor = attrs.containsKey(AttrNames.splashColor)
            ? StyleParse.hexColor(attrs[AttrNames.splashColor])
            : null;
    Color? textColor = attrs.containsKey(AttrNames.textColor) ? StyleParse.hexColor(attrs[AttrNames.textColor]) : null;
    var child = node.children.isNotEmpty ? Tuna3.parseWidget(node.children[0],jsRuntime,styleSheet: styleSheet):attrs.containsKey('value')?Text(attrs['value']):null;

    var onPressed;
    if(attrs.containsKey("onPressed")){
      onPressed = StyleParse.convertAttr(attrs["onPressed"].trim());
    }
    
    var pressedCall = onPressed!=null ? (){
        var viewInsets = Get.context!.mediaQueryViewInsets;
        if(viewInsets.bottom > 0){
          FocusScope.of(Get.context!).requestFocus(FocusNode());
        }
        
        if(onPressed.isNotEmpty){
          var code;
          if(onPressed is String){
            code = onPressed+'()';
          }else if(onPressed is Map && onPressed.containsKey("handle")){
            var params = Map.from(onPressed);
            if(attrs.containsKey("hideKeyboard") && attrs["hideKeyboard"]=="true"){
              if(viewInsets.bottom> 0){
                FocusScope.of(Get.context!).requestFocus(FocusNode());
              }
            }
            params.remove("handle");
            code  = onPressed['handle']+'('+json.encode(params)+')';
          }
          if(code.isNotEmpty){
            try{
              jsRuntime.evaluate(code);
            }on PlatformException catch(e){
              print(e);
            }
          }
        }
      }:null;
    
    builderButton(context){
      switch(btnType){
        case 'flat':
          return FlatButton(
            color: color,
            // enabled:attrs.containsKey("enabled")?parseBool(attrs['enabled']):true,
            disabledColor: disabledColor,
            disabledTextColor: disabledTextColor,
            padding: padding,
            splashColor: splashColor,
            textColor:textColor,
            child: child,
            shape : RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
            onPressed: attrs.containsKey("disable") &&StyleParse.bool(attrs['disable']) ? null: pressedCall,
          );
        case 'icon':
          return IconButton(
            iconSize: attrs.containsKey("size")?double.parse(attrs['size']):24.0,
            icon: child, 
            color: color,
            disabledColor: disabledColor,
            alignment: attrs['align']==null?Alignment.center:StyleParse.alignment(attrs['align']),
            padding: padding,
            splashColor: splashColor,
            onPressed:attrs.containsKey("disable") &&StyleParse.bool(attrs['disable']) ? null: pressedCall,
          );
        case 'raised':
        default:
          return RaisedButton(
            color: color,
            disabledColor: disabledColor,
            disabledElevation: disabledElevation,
            disabledTextColor: disabledTextColor,
            elevation: elevation,
            padding: padding,
            splashColor: splashColor,
            textColor:textColor,
            child: child,
            shape : RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
            onPressed:attrs.containsKey("disable") &&StyleParse.bool(attrs['disable']) ? null: pressedCall,
          );
      }
    } 

    if(Get.context!=null){
      return builderButton(Get.context);
    }else{
      return  Builder(
        builder:builderButton
      );
    }
  }
}

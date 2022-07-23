
import 'package:flutter/material.dart';
import 'package:tuna3/utils/style_parse.dart';
import 'package:tuna3/widgets/constants.dart';

class InputParse{
  InputDecoration decoration(Map<String, dynamic> map,placeholder){

  var hintStyle = map.containsKey(AttrNames.hintStyle)
      ? StyleParse.textStyle(map[AttrNames.hintStyle]) : null;

  var hintMaxLines = map.containsKey(AttrNames.hintMaxLines)
      ? int.parse(map[AttrNames.hintMaxLines]) : null;

  var filled = map.containsKey(AttrNames.filled)
      ? StyleParse.bool(map[AttrNames.filled]):false;

  var enabled = map.containsKey(AttrNames.enabled)
      ? map[AttrNames.enabled]:true;

  var alignLabelWithHint = map.containsKey(AttrNames.alignLabelWithHint)
      ? StyleParse.bool(map[AttrNames.alignLabelWithHint]):true;

  var contentPadding = map.containsKey(AttrNames.contentPadding)
      ? StyleParse.edgeInsetsGeometry(map[AttrNames.contentPadding]) : const EdgeInsets.all(3.0);


  return InputDecoration(
    hintText:placeholder,
    hintStyle:hintStyle,
    hintMaxLines:hintMaxLines,
    contentPadding:contentPadding,
    filled:filled,
    fillColor:StyleParse.hexColor(map[AttrNames.fillColor]),
    focusColor:StyleParse.hexColor(map[AttrNames.focusColor]),
    hoverColor:StyleParse.hexColor(map[AttrNames.hoverColor]),
    errorBorder:border(map[AttrNames.errorBorder]),
    focusedBorder:border(map[AttrNames.focusedBorder]),
    disabledBorder:border(map[AttrNames.disabledBorder]),
    enabledBorder:border(map[AttrNames.border]),
    border:border(map[AttrNames.border]),
    enabled:enabled,
    alignLabelWithHint:alignLabelWithHint
  );
}

static border(String border,{radius=0.0}){

  if(border.trim()=="none"){
    return const OutlineInputBorder(
        borderSide:BorderSide.none,
        gapPadding: 0.0
    );
  }
  
  if(border is String){
    List style = border.split(RegExp(r"[\s\t,]+"));
    Color? color;
    double? width;
    dynamic type;

    if(style.length==3){
      width = double.parse(style[0]);
      color = StyleParse.hexColor(style[2].trim().replaceAll(RegExp(r";$"),""));
      type = style[1];
    }else if(style.length==2){
      width = double.parse(style[0]);
      color = StyleParse.hexColor(style[1]);
    }
    
    if(type=="all"){
      return OutlineInputBorder(
          borderSide:BorderSide(
            color:color!,
            width:width!,
          ),
          borderRadius: BorderRadius.all( Radius.circular(double.parse(radius))),
          gapPadding:4.0
      );
    }else{
      return UnderlineInputBorder(
          borderSide:BorderSide(
            color:color!,
            width:width!,
          ),
          borderRadius: BorderRadius.all( Radius.circular(double.parse(radius)))
      );
    }
  }
}
}
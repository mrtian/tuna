import 'package:flutter/material.dart';
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/utils/animate_parse.dart';
import 'package:tuna3/utils/style_parse.dart';
import '../../compontents/animateSet/animation_set.dart';
import 'package:html/dom.dart' as dom;
import '../widget.dart';

class TWidgetAnimator extends TWidget{

  TWidgetAnimator():super(tagName: 'animator');

  parse(dom.Element node,JsRuntime jsRuntime ,{TStyleSheet? styleSheet}) {

    Map<String,dynamic> attrs = getAttributes(node);
    
    dynamic children = node.children;
    dynamic  _children = [];
    dynamic  _sets = [];
    int duration = attrs['duration']!=null?int.parse(attrs['duration']!):450;

    if(children.length>0){
      children.forEach((item){
        if(item.localName=="set" || item.localName=="serial"){
          _sets.add(item);
        }else{
          _children.add(item);
        }
      });
    }

    if(_children.length==0){
      return Container();
    }
   
    return AnimatorSet(
      animatorSet: AnimateParse.amimationSet(_sets,duration:duration),
      animationType: AnimateParse.animationType(attrs["repeat"]),
      child: Tuna3.parseWidget( _children[0],jsRuntime,styleSheet: styleSheet),
      debug: attrs.containsKey("debug") ? StyleParse.bool(attrs["debug"]):false
    );
  }


}
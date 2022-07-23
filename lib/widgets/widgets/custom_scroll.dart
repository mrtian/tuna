import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/utils/animate_parse.dart';
import 'package:tuna3/utils/style_parse.dart';
import '../../tuna3.dart';
import '../widget.dart';

class TWidgetCustomScroll extends TWidget{

  static final Map<String,ScrollController> _scrollerControllers = {};
  
  TWidgetCustomScroll():super(tagName: ['customScroll','cscroll']);

  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}){
    Map<String,dynamic> attrs = getAttributes(node);
    bool reverse = attrs.containsKey("reverse")?StyleParse.bool(attrs['reverse']):false;
    double start = attrs.containsKey("offset")? double.parse(attrs['offset']):0.0;
    double anchor = attrs.containsKey("anchor")? double.parse(attrs['anchor']):0.0;
    String? name = attrs['name'];
    bool shrinkWrap = attrs.containsKey("reverse")?StyleParse.bool(attrs['reverse']):false;
    double? cacheExtent = attrs.containsKey("cacheExtent")? double.parse(attrs['cacheExtent']):null;
    int? semanticChildCount = attrs.containsKey("semanticChildCount")? int.parse(attrs['semanticChildCount']):null;
    bool? primary = attrs.containsKey("primary")?StyleParse.bool(attrs['primary']):null;

    ScrollController? controller;
    if(name!=null){
      if(!TWidgetCustomScroll._scrollerControllers.containsKey(name)){
        controller = ScrollController(initialScrollOffset: start);
      }else{
        controller = TWidgetCustomScroll._scrollerControllers[name];
      }
      if(controller!=null ){
        jsRuntime.addJavascriptMessageHandle("TunaScrollViewEvent."+name, (params){
          if(params is Map && 
            params["method"] != null
          ){
            var method = params["method"];
            var data = params["data"];
            switch(method){
              case "jumpTo":
                if(controller!=null && data!=null){
                  controller.jumpTo(double.parse(data.toString()));
                }
                return true;
              case "animateTo":
                if(controller!=null && data!=null){
                  if(data is String || data is int || data is double){
                    controller.animateTo(double.parse(data.toString()), duration: const Duration(milliseconds: 250), curve: Curves.linear);
                  }else if(data is Map && data.containsKey("offset")){
                    var offset = double.parse(data["offset"].toString());
                    var duration = data.containsKey("duration")?Duration(milliseconds: data['duration']):const Duration(milliseconds: 250);
                    var curve = data.containsKey("curve")?AnimateParse.curve(data["curve"]):Curves.linear;
                    controller.animateTo(offset, duration: duration, curve: curve);
                  }
                  return true;
                }
                return false;
              case "position":
                if(controller!=null){
                  ScrollPosition pos =  controller.position;
                  return {
                    "pixes":pos.pixels,
                    "max":pos.maxScrollExtent,
                    "min":pos.minScrollExtent
                  };
                }
                return null;
              case "listen":
                if(controller!=null){
                  controller.addListener(() { 
                    var code = 'T.getScrollView("'+name+'").resolveScrollListen();';
                    jsRuntime.evaluate(code);
                  });
                }
                return true;
              case "offset":
                if(controller!=null){
                  return controller.offset;
                }
                return null;
            }
          }
        });
      }
    }

    return CustomScrollView(
      key: attrs.containsKey("key") ? Key(attrs['key']) : null,
      scrollDirection:attrs['direction']!=null?StyleParse.axis(attrs['direction']):Axis.vertical,
      reverse:reverse,
      controller:controller,
      shrinkWrap:shrinkWrap,
      anchor:anchor,
      cacheExtent:cacheExtent,
      slivers:Tuna3.parseWidgets(node.children, jsRuntime,styleSheet: styleSheet),
      semanticChildCount:semanticChildCount,
      primary:primary,
      center:attrs.containsKey("center")?attrs['center']:null
    );
  }
}
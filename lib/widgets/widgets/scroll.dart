import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/utils/animate_parse.dart';
import 'package:tuna3/utils/style_parse.dart';
import '../../tuna3.dart';
import '../constants.dart';
import '../widget.dart';

class TWidgetScrollView extends TStyleWidget{

  TWidgetScrollView():super(tagName: ['scroller','scrollView']);

  @override
  build(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}){
    
    ScrollController? scrollController;
    Map<String,dynamic> attrs = getAttributes(node);
    String? widgetName = attrs['name'];

    dynamic child;

    SingleChildScrollView scrollView;
    var primary = attrs.containsKey(AttrNames.primary)?StyleParse.bool(attrs[AttrNames.primary]):widgetName!=null?false:true;

    if(widgetName!=null){
      scrollController = ScrollController(
        initialScrollOffset: attrs.containsKey("offset")?double.parse(attrs["offset"]):0.0,
        keepScrollOffset:attrs.containsKey("keepScrollOffset")?StyleParse.bool(attrs['keepScrollOffset']):true
      );
      jsRuntime.addJavascriptMessageHandle("TunaScrollViewEvent."+widgetName,(params){
        if(params is Map && 
          params["method"] != null
        ){
          var method = params["method"];
          var data = params["data"];
          switch(method){
            case "jumpTo":
              if(scrollController!=null && data!=null){
                scrollController.jumpTo(double.parse(data.toString()));
              }
              return true;
            case "animateTo":
              if(scrollController!=null && data!=null){
                if(data is String || data is int || data is double){
                  scrollController.animateTo(double.parse(data.toString()), duration: const Duration(milliseconds: 250), curve: Curves.linear);
                }else if(data is Map && data.containsKey("offset")){
                  var offset = double.parse(data["offset"].toString());
                  var duration = data.containsKey("duration")?Duration(milliseconds: data['duration']):const Duration(milliseconds: 250);
                  var curve = data.containsKey("curve")?AnimateParse.curve(data["curve"]):Curves.linear;
                  scrollController.animateTo(offset, duration: duration, curve: curve);
                }
                return true;
              }
              return false;
            case "position":
              if(scrollController!=null){
                ScrollPosition pos =  scrollController.position;
                return {
                  "pixes":pos.pixels,
                  "max":pos.maxScrollExtent,
                  "min":pos.minScrollExtent
                };
              }
              return null;
            case "listen":
              if(scrollController!=null){
                scrollController.addListener(() { 
                  var code = 'T.getScrollView("'+widgetName+'").resolveScrollListen();';
                  jsRuntime.evaluate(code);
                });
              }
              return true;
            case "offset":
              if(scrollController!=null){
                return scrollController.offset;
              }
              return null;
          }
        }
      });
    }
    
    if(node.children.isNotEmpty){
      child  = Tuna3.parseWidget(node.children[0],jsRuntime,styleSheet:styleSheet);
    }
    
    if(widgetName!=null && !primary){
      scrollView =  SingleChildScrollView(
        padding: StyleParse.edgeInsetsGeometry(attrs[AttrNames.padding]),
        controller: scrollController,
        scrollDirection: attrs.containsKey(AttrNames.direction) ? StyleParse.axis(attrs[AttrNames.direction]) : Axis.vertical,
        reverse: attrs.containsKey(AttrNames.reverse) ? StyleParse.bool(attrs[AttrNames.reverse]) : false,
        primary:primary,
        physics: attrs.containsKey(AttrNames.physics) && attrs[AttrNames.physics]=='true' ? null:new BouncingScrollPhysics(),
        child: child,
      );
    }else{
      scrollView = SingleChildScrollView(
        padding: StyleParse.edgeInsetsGeometry(attrs[AttrNames.padding]),
        scrollDirection: attrs.containsKey(AttrNames.direction) ? StyleParse.axis(attrs[AttrNames.direction]) : Axis.vertical,
        reverse: attrs.containsKey(AttrNames.reverse) ? StyleParse.bool(attrs[AttrNames.reverse]) : false,
        primary: primary,
        physics: attrs.containsKey(AttrNames.physics) && attrs[AttrNames.physics]=='true' ? null:new BouncingScrollPhysics(),
        child: child,
      );
    }
    return scrollView;
  }

}

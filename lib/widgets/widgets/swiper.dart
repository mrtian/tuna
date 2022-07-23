import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:tuna3/utils/style_parse.dart';

import '../../js_runtime.dart';
import '../../style_sheet.dart';
import '../../tuna3.dart';
import '../constants.dart';
import '../widget.dart';


class TWidgetSwiper extends TWidget{
  TWidgetSwiper():super(tagName: 'swiper');

  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}) {
    Map<String,dynamic> attrs  = getAttributes(node);
    String? onChanged = attrs['onChanged'];
    return  Swiper(
      scrollDirection: (attrs.containsKey("vertical") && (attrs["vertical"] == "true" || attrs["vertical"] == true)) ? Axis.vertical : Axis.horizontal,
      outer:false,
      itemBuilder: (context, index) {
        // ignore: unnecessary_null_comparison
        if(onChanged!=null){
          try{
            jsRuntime.evaluateFunc(onChanged, index);
          }catch(e){
            print(e);
          }
        }
        return Tuna3.parseWidget(node.children[index],jsRuntime,styleSheet: styleSheet);
      },
      itemCount:  node.children.length,
      pagination: attrs.containsKey(AttrNames.pagination)
        ? parsePagination( StyleParse.convertAttr(attrs[AttrNames.pagination]) )
        : null,
      loop:attrs.containsKey(AttrNames.loop)
        ? StyleParse.bool(attrs[AttrNames.loop])
        : false,
      index:attrs.containsKey(AttrNames.index)
        ? int.parse(attrs[AttrNames.index])
        : 0,
      autoplay: attrs.containsKey(AttrNames.autoplay)
        ? StyleParse.bool(attrs[AttrNames.autoplay])
        : false,
      duration: attrs.containsKey(AttrNames.duration)
        ? int.parse(attrs[AttrNames.duration])
        : 350,
      itemWidth: attrs.containsKey(AttrNames.width)
        ? double.parse(attrs[AttrNames.width])
        : 300.0,
      itemHeight: attrs.containsKey(AttrNames.height)
        ? double.parse(attrs[AttrNames.height])
        : 200.0
    );

  }

  parsePagination(Map<String, dynamic> attrs) {

      dynamic _builder;
      if(attrs.containsKey(AttrNames.style)){
        if(attrs[AttrNames.style] == 'fraction'){
          _builder = SwiperPagination.fraction;
        }else if(attrs[AttrNames.style] == 'dots'){
          return  SwiperCustomPagination(
              builder:(BuildContext context, SwiperPluginConfig config){
                  return smallDots(attrs,context,config);
              }
          );
        }else if(attrs[AttrNames.style]=='num'){
          return SwiperCustomPagination(
            builder:(BuildContext context, SwiperPluginConfig config){
                return smallFraction(attrs,context,config);
            }
          );
        }
      }else{
        _builder = SwiperPagination.dots;
      }

      return SwiperPagination(
        alignment: attrs.containsKey(AttrNames.alignment)
          ? StyleParse.alignment(attrs[AttrNames.alignment])
          : Alignment.bottomCenter,
        // activeColor:Colors.grey[100],
        margin:  attrs.containsKey(AttrNames.margin)
          ? StyleParse.edgeInsetsGeometry(attrs[AttrNames.margin])
          : const EdgeInsets.all(5.0),

        builder: _builder,
      );
  }

  Widget smallFraction(attrs,context,config){
      ThemeData themeData = Theme.of(context);

      Color activeColor = attrs.containsKey(AttrNames.activeColor) 
          ? StyleParse.hexColor(attrs[AttrNames.activeColor]) : themeData.primaryColor;
      Color color = attrs.containsKey(AttrNames.color) 
          ? StyleParse.hexColor(attrs[AttrNames.color]) : themeData.scaffoldBackgroundColor;

      double activeFontSize = attrs.containsKey(AttrNames.activeFontSize)
          ? double.parse(attrs[AttrNames.activeFontSize]) : 14;
      double fontSize = attrs.containsKey(AttrNames.fontSize)
          ? double.parse(attrs[AttrNames.fontSize]) : 14;

      var radius = attrs.containsKey(AttrNames.radius) 
          ? double.parse(attrs[AttrNames.radius]) : 0.0;
      var backgroundColor = attrs.containsKey(AttrNames.backgroundColor)
          ? StyleParse.hexColor(attrs[AttrNames.backgroundColor])
          : null;

      var padding = attrs.containsKey(AttrNames.padding)
          ? StyleParse.edgeInsetsGeometry(attrs[AttrNames.padding])
          : const EdgeInsets.all(0.0);

      var margin = attrs.containsKey(AttrNames.margin)
        ? StyleParse.edgeInsetsGeometry(attrs[AttrNames.margin])
        : const EdgeInsets.all(0.0);

      var border = attrs.containsKey(AttrNames.border)
        ? StyleParse.border(attrs[AttrNames.border]) : null;

      
      var retWidget =  Container(
        padding:padding,
        margin:margin,
        decoration: BoxDecoration(
          color:backgroundColor,
          borderRadius:BorderRadius.all(Radius.circular(radius)),
          border:border
        ),
        child:Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              "${config.activeIndex + 1}",
              style: TextStyle(color: activeColor, fontSize: activeFontSize),
            ),
            Text(
              "/${config.itemCount}",
              style: TextStyle(color: color, fontSize: fontSize),
            )
          ],
        )
      );

      return Align(
        alignment: attrs.containsKey(AttrNames.alignment)
            ? StyleParse.alignment(attrs[AttrNames.alignment])
            : Alignment.bottomRight,
        child: retWidget,
      );
  }

  Widget smallDots(attrs,context,config){

      ThemeData themeData = Theme.of(context);

      Color activeColor = attrs.containsKey(AttrNames.activeColor) 
          ? StyleParse.hexColor(attrs[AttrNames.activeColor]) : themeData.primaryColor;
      Color color = attrs.containsKey(AttrNames.color) 
          ? StyleParse.hexColor(attrs[AttrNames.color]) : themeData.scaffoldBackgroundColor;

      var size = attrs.containsKey(AttrNames.size)
          ? double.parse(attrs[AttrNames.size])
          : 6.0;

      var margin = attrs.containsKey(AttrNames.margin)
        ? StyleParse.edgeInsetsGeometry(attrs[AttrNames.margin])
        : const EdgeInsets.all(10.0);

      var space = attrs.containsKey(AttrNames.space)
        ? StyleParse.edgeInsetsGeometry(attrs[AttrNames.space])
        : const EdgeInsets.all(2.0);

      var radius = attrs.containsKey(AttrNames.radius) 
          ? double.parse(attrs[AttrNames.radius]) : 0.0;
      var backgroundColor = attrs.containsKey(AttrNames.backgroundColor)
          ? StyleParse.hexColor(attrs[AttrNames.backgroundColor])
          : null;

      var padding = attrs.containsKey(AttrNames.padding)
          ? StyleParse.edgeInsetsGeometry(attrs[AttrNames.padding])
          : const EdgeInsets.all(0.0);

      var border = attrs.containsKey(AttrNames.border)
        ? StyleParse.border(attrs[AttrNames.border]) : null;

     
      List<Widget> dots = [];
      for(var i=0;i<config.itemCount;i++){
        if(config.activeIndex==i){
          dots.add(Container(
            width:size,
            height:size,
            margin:space,
            decoration:BoxDecoration(
              color:activeColor,
              borderRadius:BorderRadius.all(Radius.circular(size))
            )
          ));
        }else{
          dots.add(Container(
            width:size,
            height:size,
            margin:space,
            decoration:BoxDecoration(
              color:color,
              borderRadius:BorderRadius.all(Radius.circular(size))
            )
          ));
        }
      }
      
      return Align(
        alignment: attrs.containsKey(AttrNames.alignment)
            ? StyleParse.alignment(attrs[AttrNames.alignment])
            : Alignment.bottomRight,
        child: Container(
          padding:padding,
          margin:margin,
          decoration: BoxDecoration(
            color:backgroundColor,
            borderRadius:BorderRadius.all(Radius.circular(radius)),
            border:border
          ),
          child:Row(
            mainAxisSize: MainAxisSize.min,
            children: dots,
          )
        ),
      );
  }


}

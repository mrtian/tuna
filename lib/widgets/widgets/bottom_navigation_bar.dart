import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/utils/style_parse.dart';

import '../constants.dart';
import '../widget.dart';


class TWidgetBottomNavigationBar extends TWidget{
  
  TWidgetBottomNavigationBar():super(tagName: ['bottomNavigationBar','bottomNavBar']);

  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}){
    Map<String,dynamic> attrs = getAttributes(node);
    return TunaBottomNavigationBarWidget(node,attrs,jsRuntime,styleSheet:styleSheet);
  }

  static Map<String,dynamic> bottomNavBarContainer = {};

}


class TunaBottomNavigationBarWidget extends StatefulWidget{
  final dom.Element node;
  final JsRuntime jsRuntime;
  final TStyleSheet? styleSheet;
  final Map<String,dynamic> attrs;

  const TunaBottomNavigationBarWidget(this.node,this.attrs,this.jsRuntime,{
    Key? key,
    this.styleSheet,
  }):super(key:key);

  @override
  _TunaBottomBarWidgetState createState()=>_TunaBottomBarWidgetState();
}

class _TunaBottomBarWidgetState extends State<TunaBottomNavigationBarWidget> with AutomaticKeepAliveClientMixin{

  List <BottomNavigationBarItem> items = [];

  int? currentIndex;
  double? elevation ;
  var  barType;
  Color? fixedColor;
  Color? backgroundColor ;
  double? iconSize ;
  Color? selectedItemColor;
  Color? unselectedItemColor;
  double? selectedFontSize ;
  double? unselectedFontSize ;
  TextStyle? selectedLabelStyle;
  TextStyle? unselectedLabelStyle ;
  bool? showSelectedLabels;
  bool? showUnselectedLabels;

  late dom.Element node;
  late Map<String, dynamic> attrs;
  String? widgetName;
  String? eventName;
  int? lastIndex;

  bool hasBinding = false;

  @override
  bool get wantKeepAlive => true;

  @override
  initState(){
    
    node = widget.node;
    attrs = widget.attrs;
    widgetName = attrs[AttrNames.name];

    currentIndex = attrs.containsKey(AttrNames.index) && attrs[AttrNames.index]!=null && attrs[AttrNames.index]!="null" 
            ? int.parse(attrs[AttrNames.index]!) : 0;
    elevation = attrs.containsKey(AttrNames.elevation) ? double.parse(attrs[AttrNames.elevation]!): 2.0;
    barType = StyleParse.bottomNavigationBarType(attrs[AttrNames.barType]);
    fixedColor = StyleParse.hexColor(attrs[AttrNames.fixedColor]);
    backgroundColor = StyleParse.hexColor(attrs[AttrNames.backgroundColor]);
    iconSize = attrs.containsKey(AttrNames.iconSize) ? double.parse(attrs[AttrNames.iconSize]!) : 24.0;
    selectedItemColor = StyleParse.hexColor(attrs[AttrNames.selectedItemColor]);
    unselectedItemColor = StyleParse.hexColor(attrs[AttrNames.unselectedItemColor]);
    selectedFontSize = attrs.containsKey(AttrNames.selectedFontSize) ? double.parse(attrs[AttrNames.selectedFontSize]!) : 13.0;
    unselectedFontSize = attrs.containsKey(AttrNames.unselectedFontSize) ? double.parse(attrs[AttrNames.unselectedFontSize]!) : 13.0;
    selectedLabelStyle = attrs.containsKey(AttrNames.selectedLabelStyle) ?  StyleParse.textStyle(attrs[AttrNames.selectedLabelStyle]!):null;
    unselectedLabelStyle =  attrs.containsKey(AttrNames.unselectedLabelStyle) ? StyleParse.textStyle(attrs[AttrNames.unselectedLabelStyle]!):null;
    showSelectedLabels = attrs.containsKey(AttrNames.showSelectedLabels) ? StyleParse.bool(attrs[AttrNames.showSelectedLabels]):true;
    showUnselectedLabels = attrs.containsKey(AttrNames.showUnselectedLabels) ? StyleParse.bool(attrs[AttrNames.showUnselectedLabels]):true;
    

    List<dom.Element> children = node.children;
    if(children.isNotEmpty){
      children.forEach((dom.Element item){
        if(item.localName!.toLowerCase()=='baritem' && item.children is List && item.children.isNotEmpty){
          Widget? icon;
          dynamic text;
          Widget? activeIcon;
          Color? bgColor;
          String? tooltip;
          LinkedHashMap<dynamic, String> _barAttrs = item.attributes;

          if(_barAttrs.containsKey("bgColor")){
            bgColor = StyleParse.hexColor(_barAttrs['bgColor']);
          }else if(_barAttrs.containsKey("tooltip")){
            tooltip = _barAttrs['tooltip'];
          }

          item.children.forEach((dom.Element itm){
            LinkedHashMap<dynamic, String> _attrs = itm.attributes;
            if(itm.localName==AttrNames.icon){
              if(_attrs.containsKey("active")){
                if(itm.children.isNotEmpty){
                  activeIcon = Tuna3.parseWidget( itm.children[0],widget.jsRuntime,styleSheet: widget.styleSheet);
                }else{
                  activeIcon = Tuna3.parseWidget(itm,widget.jsRuntime,styleSheet: widget.styleSheet);
                }
              }else{
                if( itm.children.isNotEmpty){
                  icon = Tuna3.parseWidget(itm.children[0],widget.jsRuntime,styleSheet: widget.styleSheet);
                }else{
                  icon = Tuna3.parseWidget(itm,widget.jsRuntime,styleSheet: widget.styleSheet);
                }
              }
            }else{
              text = itm.text;
            }
          });
          icon ??= const Text("");
          if(activeIcon!=null){
            items.add(BottomNavigationBarItem(
              activeIcon:activeIcon,
              icon: icon!,
              label: text,
              backgroundColor:backgroundColor,
              tooltip:tooltip
            ));
            // print(activeIcon);
          }else{
            items.add(BottomNavigationBarItem(
              icon: icon!,
              label: text,
              backgroundColor:backgroundColor,
              tooltip:tooltip
            ));
            
          }
        }
      });
    }

    if(widgetName!=null){
      // 监听事件
      widget.jsRuntime.addWidgetMessageHandle('BottomNavBar',widgetName!, handleEvent);
      // 页面渲染完成后执行
      var widgetsBinding = WidgetsBinding.instance;
      widgetsBinding.addPostFrameCallback((callback)async{
          if(!hasBinding &&  !widget.jsRuntime.onDispose ){
            hasBinding =  true;
            widget.jsRuntime.resolveWidgetReady("BottomNavBar", widgetName!);
          }
      });
    }
    lastIndex = currentIndex;

    super.initState();
  }

  @override
  dispose(){
    super.dispose();
  }
  // 处理事件
  handleEvent(params){
    if(params is Map && 
      params["method"] != null
    ){
      var method = params["method"];
      var data = params["data"];
      switch(method){
        case "changeIndex":
          if(data!=null){
            handleBarItem(data);
          }
          return true; 
        case "init":
          return {"index":currentIndex,"prevIndex":lastIndex};   
      } 
    }
  }

  handleBarItem(index){
    lastIndex = currentIndex;
    currentIndex = index;
    setState((){});
    evaluateChange();
  }

  evaluateChange(){
    if(widgetName==null){
      return;
    }
    var obj = {
      "index":currentIndex,
      "prevIndex":lastIndex
    };
    var dispatchCode = 'try{T.getBottomNavBar("'+widgetName!+'").resolveOnChange('+json.encode(obj)+')}catch(e){console.log(e.toString());};';
    widget.jsRuntime.evaluate(dispatchCode);
  }

  @override
  Widget build(context){
    super.build(context);
    return BottomNavigationBar(
          currentIndex: currentIndex!, 
          elevation: elevation, 
          type: barType,
          fixedColor:fixedColor,
          backgroundColor:backgroundColor,
          iconSize: iconSize!,
          selectedItemColor:selectedItemColor,
          unselectedItemColor:unselectedItemColor, 
          selectedFontSize: selectedFontSize!, 
          unselectedFontSize: unselectedFontSize!,
          selectedLabelStyle: selectedLabelStyle,
          unselectedLabelStyle: unselectedLabelStyle,
          showSelectedLabels: showSelectedLabels, 
          showUnselectedLabels: showUnselectedLabels,
          items: items,
          onTap: (index){
            lastIndex = currentIndex;
            currentIndex = index;
            setState((){});
            if(widgetName!=null){
              evaluateChange();
            }
          },
        );
  }
}
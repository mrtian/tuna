import 'package:flutter/material.dart';
import 'package:tuna3/js_runtime.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/utils/style_parse.dart';
import '../../tuna3.dart';
import '../constants.dart';
import '../widget.dart';


class TWidgetOffstage  extends TWidget{

  TWidgetOffstage():super(tagName: 'offstage');

  static Map<String,JsRuntime> instances = {};

  @override
  parse(dom.Element node, JsRuntime jsRuntime, {TStyleSheet?styleSheet}) {
    var attrs = getAttributes(node);
    return _TunaWidgetOffstage(node,attrs:attrs,jsRuntime: jsRuntime,styleSheet:styleSheet);
    
  }
}
class _TunaWidgetOffstage extends StatefulWidget{
  final dom.Element node;
  final JsRuntime jsRuntime;
  final Map<String,dynamic> attrs;
  final TStyleSheet? styleSheet; 

  _TunaWidgetOffstage(this.node,{
    Key? key,
    required this.jsRuntime,
    required this.attrs,
    this.styleSheet
  }):super(key:key);

  _TunaWidgetOffstageState createState()=>_TunaWidgetOffstageState();
}

class _TunaWidgetOffstageState extends State<_TunaWidgetOffstage>{
  
  late dom.Element node;
  late Map<String,dynamic> attrs;
  String? widgetName;
  String? eventName;
  bool off = true;

  bool hasBinding = false;
  Widget? child;

  // bool get wantKeepAlive => true;

  @override
  void initState() {
    node = widget.node;
    attrs = widget.attrs;
    widgetName = attrs[AttrNames.name];
    off = attrs.containsKey("off")?StyleParse.bool(attrs['off']):off;

    if(node.children.isNotEmpty){
      child = Tuna3.parseWidget(node.children[0],widget.jsRuntime,styleSheet: widget.styleSheet);
    }

    if(widgetName!=null){
      // 监听事件
      widget.jsRuntime.addWidgetMessageHandle('Offstage',widgetName!, handleEvent);
      // 页面渲染完成后执行
      var widgetsBinding = WidgetsBinding.instance;
      widgetsBinding.addPostFrameCallback((callback)async{
          if(!hasBinding &&  !widget.jsRuntime.onDispose ){
            hasBinding =  true;
            widget.jsRuntime.resolveWidgetReady("Offstage", widgetName!);
          }
      });
    }
    super.initState();
  }

  handleEvent(params){
    if(params is Map && 
      params["method"] != null
    ){
      var method = params["method"];
      switch(method){
        case "off":
          off = true;
          setState(() {});
          return true; 
        case "on":
          off = false;
          setState(() {});
          return true;   
      } 
    }
  }
  @override
  Widget build(BuildContext context) {
    return Offstage(
    	offstage: off,
      child: child,
    );
  }
}
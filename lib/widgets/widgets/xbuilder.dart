import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/jscore/core/js_value.dart';
import 'package:tuna3/style_sheet.dart';
import '../../tuna3.dart';

class XBuilder extends StatefulWidget{
  final dom.Element node;
  final JsRuntime jsRuntime;
  final TStyleSheet? styleSheet;

  const XBuilder(this.node,this.jsRuntime,{Key? key,this.styleSheet}) : super(key: key);

  @override
  State<StatefulWidget> createState() => XBuilderState();
  
}

class XBuilderState extends State<XBuilder> with AutomaticKeepAliveClientMixin{
  late String template;
  late JsRuntime jsRuntime;

  bool hasBinding = false;
  late String widgetId;
  Map<String,dynamic> attrs = {};
  Map<String,dynamic> widgetData = {};

  @override
  void initState() {
    super.initState();
    jsRuntime = widget.jsRuntime;
    if(widget.node.attributes.isNotEmpty){
      widget.node.attributes.forEach((key, value) {
        attrs[key.toString()] = value;
      });
    }

    if(attrs.containsKey("template") && attrs['template'].isNotEmpty){
      template = jsRuntime.getTemplateById(attrs['template']);
    }else{
      template = widget.node.innerHtml.trim();
    }
    
    widgetId = attrs['id'] ?? Tuna3.toMd5(template);

    var widgetsBinding = WidgetsBinding.instance;
      widgetsBinding.addPostFrameCallback((callback)async{
          if(!hasBinding &&  !jsRuntime.onDispose ){
            hasBinding =  true;
            jsRuntime.resolveWidgetReady("XBuilder", widgetId);
          }
      });
      jsRuntime.addWidgetMessageHandle("XBuilder", widgetId, jsCallHandel);
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    JSValue tpl = Tuna3.parseTemplate(template,data: widgetData);
    if(tpl.string!=null && tpl.string!.trim().isNotEmpty){
      dom.DocumentFragment doc =  parseFragment(tpl.string);
      if(doc.children.isNotEmpty){
        var _widgets = Tuna3.parseWidgets(doc.children, jsRuntime,styleSheet: widget.styleSheet);
        if(_widgets.length>1){
          return _widgets;
        }else{
          return _widgets[0];
        }
      }
    }
    return const SizedBox(width: 0.0,height: 0.0,);
  }
  // 
  jsCallHandel(params){
    // print(params);
    String? method = params["method"];
    dynamic postData = params["data"];
    
    if(method!=null && method.isNotEmpty){
      switch(method){
        case "init":
          if(postData is Map){
            postData.forEach((key, value) {
              widgetData[key] = value;
            });
            if(mounted){
              setState(() {});
            }
          }
          break;
        case "update":
          setState(() {});
          break;
        case "set":
          if(postData is Map){
            postData.forEach((key, value) {
              widgetData[key] = value;
            });
          }
          setState(() {});
          break;
        case "justSet":
          if(postData is Map){
            postData.forEach((key, value) {
              widgetData[key] = value;
            });
          }
          break;
        case "clearData":
          widgetData = {};
          setState(() {});
          break;
        case "justClear":
          widgetData = {};
          break;
      }
    }
  }

  @override
  bool get wantKeepAlive => true;
  
}
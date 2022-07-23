import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/utils/template_modifies.dart';


class XWidgetController extends GetxController{
  RxMap<String,dynamic> data;
  String route;
  String id;
  
  static Map<String,List<XWidgetController>> instances = {};
  XWidgetController(this.route,this.id,this.data){
    if(XWidgetController.instances.containsKey(route)){
      XWidgetController.instances[route]!.add(this);
    }else{
      XWidgetController.instances[route] = [this];
    }
  }
  @override
  void onInit() {
    if(JsRuntime.instances.containsKey(route)){
      JsRuntime.instances[route]!.resolveWidgetCall("XWidget", id,callName:'resolveReadyStatus');
    }
    super.onInit();
  }
}

// ignore: must_be_immutable
class XWidget extends GetWidget<XWidgetController>{
  
  dom.Element element;
  Map<String,dynamic> data = {};
  JsRuntime jsRuntime;
  TStyleSheet? styleSheet;
  
  late String tpl;
  late List<dom.Element> children;
  late String? tagName; 
  late String id;
  XWidgetController? _controller;

  RegExp dataKeyReg = RegExp(r"\${([^\}]+)}");

  
  XWidget({Key? key, 
    required this.element,
    required this.jsRuntime,
    this.styleSheet,
  }) : super(key: key) {
    LinkedHashMap attr = element.attributes;
    tagName = element.localName;
    children = element.children;
    id = attr['id'];
    // controller.data = data!;
    dynamic widgetData = jsRuntime.widgetsData[id];
    
    if(widgetData!=null){
      data = widgetData;
    }
    tpl =  element.outerHtml.replaceAllMapped(dataKeyReg, (match){
      String? varibale = match.group(1);
      if(varibale!=null){
        var modifies = varibale.trim().split("|");
        if(modifies.length>1){
          String _var = modifies[0].trim();
          List<String> methodAndParams = modifies[1].trim().split(":");
          String method = methodAndParams[0].trim();
          List<dynamic> params = [];
          dynamic ret;
          if(methodAndParams.length>1){
            for(var i=1;i<methodAndParams.length;i++){
              params.add(methodAndParams[i]);
            }
            ret = parseModifies(method, _var,data[_var],params);
            return r"${"+_var+"}";
          }else{
            if(!data.containsKey(varibale)){
              data[varibale] = null;
            }
          }
          
        }
      }
      return r"${"+varibale!+"}";
    });

    // Get.put(XWidgetController(data.obs));
    // if(id!.isNotEmpty){
    jsRuntime.addWidgetMessageHandle("XWidget",id, (message){
      if(message is Map && message.containsKey("method")){
        var method = message['method'];
        var msgData = message['data'];
        if(method=='_setData' && _controller!=null){
         
          if(msgData!=null){
            if(msgData is Map){
              msgData.forEach((key, value) {
                _controller!.data[key.toString()] = value;
              });
            }else{
              _controller!.data = msgData.obs;
            }
            
            _controller!.update([jsRuntime.id+"-"+id]);
          }
          
        }
      }
    }); 

  }

  @override
  Widget build(BuildContext context) {
    
    // print(tpl);
    return GetBuilder(
      global: false,
      init: XWidgetController(jsRuntime.id,id,data.obs),
      id:jsRuntime.id+"-"+id,
      builder: (XWidgetController controller){
        _controller ??= controller;
        
        String _tpl =  tpl.replaceAllMapped(dataKeyReg, (match){
          String? varibale = match.group(1);
          if(varibale!=null){
            return "${controller.data['$varibale']}";
          }
          return "";
        });

        _tpl = _tpl.replaceAll("<x:", "<").replaceAll("</x:", "</");
        var newEl= parseFragment(_tpl);
        if(newEl.children.isNotEmpty){
          return Tuna3.parseWidget(newEl.children[0], jsRuntime,styleSheet: styleSheet);
        }else{
          return Text("Can't render xwidget with data[${controller.data}] ");
        }
    });
    
  }

  parseModifies(method,vari,_data,params){
    if(TemplateModify.methods.containsKey(method)){
      dynamic ret =  TemplateModify.methods[method](_data,params);
      if(method=='default' && _data==null){
        data[vari] = ret;
      }
      return ret;
    }
    return _data;
  }

}
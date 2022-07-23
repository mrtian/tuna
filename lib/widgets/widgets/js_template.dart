import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/jscore/core/js_value.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/utils/style_parse.dart';

import '../widget.dart';

class TWidgetJsTemplate extends TWidget{
  
  TWidgetJsTemplate():super(tagName:['jswidget',"jsTemplate",'jsTpl','tpl']);

  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}){
    
    Map<String,dynamic> attrs = getAttributes(node);
    Map<String,dynamic> data = {};
    String? name = attrs['dataId'];
    String htmlStr  = node.innerHtml.trim();

    if(name!=null){
      data = jsRuntime.widgetsData[name];
    }else{
      
      if(htmlStr.isNotEmpty){
        dynamic _initData;
        if(htmlStr.isNotEmpty){
          try{
            _initData = json.decode(htmlStr);
          }catch(e){
            // print(e);
          }
        }
        if(_initData!=null && (_initData is Map || _initData is List)){
          data = _initData;
        }
      }
    }
    
    dynamic child = const SizedBox(width:0.0,height:0.0);
    String? templateStr;
    
    if(attrs["include"]!=null && attrs["include"].isNotEmpty){
      templateStr = jsRuntime.getTemplateById(attrs["include"]);
    }else{
      templateStr = htmlStr;
    }

    Map<String,dynamic> options = {};
    if (attrs.containsKey("options")) {
      var optionsTmp = StyleParse.convertAttr(attrs["options"]);
      optionsTmp.forEach((key, value) {
        options[key] = value == "true" ? true : (value == "false" ? false : value);
      });
    }
    
    if(templateStr!=null){
      JSValue tpl = Tuna3.parseTemplate(templateStr,data:data,options:options);
      // print(templateStr);
      // print(data);
      // print(tpl.string);
      if(tpl.string!=null && tpl.string!.isNotEmpty  && tpl.string!="{Template Error}" && tpl.string!="null"){
        // print(tpl.string);
        var _body = parseFragment(tpl.string!.trim());
        
        if(_body.children.length>1){
          child =  Tuna3.parseWidgets(_body.children,jsRuntime,styleSheet: styleSheet);
        }else{
          child = Tuna3.parseWidget(_body.children[0],jsRuntime,styleSheet: styleSheet);
        }
      }
    }
    
    return child;
  }
}

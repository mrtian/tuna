import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/utils/style_parse.dart';
import 'package:tuna3/utils/styled_widget_parse.dart';
import 'package:tuna3/widgets.dart';
import 'package:html/dom.dart' as dom;

import '../style_sheet.dart';

abstract class TWidget{

  final dynamic tagName;
  Map<String,dynamic> attributes = {};

  bool inited = false;
  Map<String,dynamic> _jsCreateCallFnNames = {};

  TWidget({
    this.tagName
  }){
    // 添加组件
    if(tagName!=null){
      if(tagName is String){
        TWidgets.regWidget(tagName, this);
      }else if(tagName is List){
        tagName.forEach((tag){
          if(tag is String){
            TWidgets.regWidget(tag, this);
          }
        });
      }
    }
    
  }

  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet});
  methodCall(String id,String method,dynamic data,JsRuntime jsRuntime){
    return;
  }

  Map<String,dynamic> getAttributes(dom.Element node){
    // 解析attributes
    var attrs = node.attributes;
    Map<String,dynamic> attrsMap = {};

    if(attrs.isNotEmpty){
    // 解析属性
      attrs.forEach((akey,aval){
        var name = akey.toString();
        var val = aval.toString();

        // visitor属性
        if(name.startsWith("v-")){
          // 初始化visitor值
          if(!attrsMap.containsKey("VISITOR")){
            Map<String,dynamic> _m = {};
            attrsMap["VISITOR"] = _m;
          }
          name = name.replaceAll(RegExp(r"^v-"), "");
          if(name=="if"){
            attrsMap["VISITOR"]["IF"] = val;
          }else if(name.startsWith("on")){
            var names = name.split(":");
            var visitor = attrsMap["VISITOR"];
            if(!visitor.containsKey("ON")){
              Map<String,dynamic> _on = {};
              visitor["ON"] = _on;
            }
            if(names.length>1){
              visitor["ON"][names[1]] = val;
            }
          }else if(name=="launch"){
            attrsMap["VISITOR"]['LAUNCH'] = val;
          }

        }else{
          attrsMap[name] = val;
        }
      });

    }
    return attrsMap;
        
  }

  getSheetTree(dom.Element node){
    var attrs = node.attributes;
    List<String> _sheetTree = [];
    // class样式
    if(attrs.containsKey("class")){
      String? className = attrs["class"];
      List<String> classNames = className!.split(RegExp(r"[\s\t]+"));
      var _clns = [];
      classNames.forEach((cname){
        _clns.add(".CN:"+cname);
      });
      _sheetTree.add("TN:"+node.localName!+(_clns.join("")));
    }else{
      _sheetTree.add("TN:"+node.localName!);
    }
    if(_sheetTree.isNotEmpty){
      return _sheetTree;
    }
  }

  insertToJsEngine(JsRuntime jsRuntime){
    // 添加js处理逻辑
    jsRuntime.addJavascriptMessageHandle("TWidgetChannel."+tagName, (params)async{
      if(params.containsKey("method") && params['method'].isNotEmpty && params['id']!=null){
        var method = params['method'];
        var data = params['data'];
        var id = params['id'];
        if(method=="_onCreated"){
          // print(data);
          if(data is String){
            _jsCreateCallFnNames[id] = data;
          }else if(data is Map){
            _jsCreateCallFnNames[id] = data['id'];
            data = data['data'];
          }
        }
        return await methodCall(id,method, data,jsRuntime);
      }
    });
    inited = true;
  }

  // 回调js组件的方法
  resolveCall(String id,String method,JsRuntime jsRuntime,{dynamic data}){
    var ret;
    if(data!=null){
      try{
        ret = json.encode(data);
      }catch(e){
        print(e);
      }
    }
    var code;
    if(_jsCreateCallFnNames[id]!=null){
      if(ret!=null){
        code = '(function(){ if('+_jsCreateCallFnNames[id]+' && '+_jsCreateCallFnNames[id]+'.'+method+'){ '+_jsCreateCallFnNames[id]+'.'+method+'('+ret+');}  })();';
      }else{
        code = '(function(){ if('+_jsCreateCallFnNames[id]+' && '+_jsCreateCallFnNames[id]+'.'+method+'){ '+_jsCreateCallFnNames[id]+'.'+method+'();}  })();';
      }
      jsRuntime.evaluate(code);
    }
     
  }

  resolveReady(id,jsRuntime){
    resolveCall(id,"_resolveReady",jsRuntime);
  }

}

abstract class TStyleWidget extends TWidget{

  final dynamic tagName;

  TStyleWidget({
    this.tagName
  }):super(tagName: tagName);
  
  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}){

    Map<String,dynamic>? style;
    // 解析样式表
    if(node.attributes.isNotEmpty && node.attributes.containsKey("style")){
      style = StyleParse.convertAttr(node.attributes['style']);
    }

    // 获取当前元素的样式表中的样式
    var sheetStyle;
    var sheetTree = getSheetTree(node);
    if(styleSheet!=null && sheetTree!=null){
      sheetStyle = styleSheet.getStyle(sheetTree)!;
    }
    // 与内联样式进行合并更新样式
    if(sheetStyle!=null){
      if(style!=null && style.isNotEmpty){
        List<Map<String,dynamic>> list = [sheetStyle,style];
        style = TStyleSheet.mergeStyle(list);
      }else{
        style = sheetStyle;
      }
    }
    Widget widget = build(node,jsRuntime,styleSheet: styleSheet);
    if(style!=null && node.attributes.isNotEmpty){
      return  StyledWidgetParse.parse(widget,node.attributes,style);
    }
    return widget;
    
  }

  build(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet});

}
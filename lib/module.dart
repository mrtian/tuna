import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/widgets/widget.dart';
import './js_runtime.dart';

abstract class ScriptModule extends TWidget{

  final String jsAssets;
  final String moduleName;
  
  @override
  // ignore: overridden_fields
  final String tagName;

  final String onCreatedMethod = "_onCreated";

  // Map<String,JsRuntime> jsRuntimes;
  @override
  // ignore: overridden_fields
  bool inited = false;

  Map<String,String> windowCalls = {};

  // ignore: prefer_final_fields
  List<Function> __readyCalls = [];

  ScriptModule(this.moduleName,{this.jsAssets='',this.tagName=''});
  
  insertToJsRuntime(JsRuntime jsRuntime){
    // jsRuntimes[JsRuntime.id] = JsRuntime;
    // 添加js处理逻辑
    jsRuntime.addJavascriptMessageHandle("TunaJsWidget."+moduleName, (params)async{
     
      if(params.containsKey("method") && params['method'].isNotEmpty && params['id']!=null){
        var method = params['method'];
        var data = params['data'];
        var id = params['id'];
        if(method=="_onCreated"){
          // print(data);
          if(data is String){
            windowCalls[id] = data;
          }else if(data is Map){
            windowCalls[id] = data['id'];
            data = data['data'];
          }
        }
        return await methodCall(id,method, data,jsRuntime);
      }
    });
    
    if(__readyCalls.isNotEmpty){
      for (var fn in __readyCalls) {
        try{
          fn();
        }catch(e){
          // ignore: avoid_print
          print(e);
        }
      }
      __readyCalls.clear();
    }
    // debugPrint(this.moduleName+" is inited!");
    inited = true;
    
  }

  @override
  methodCall(String id,String method,dynamic data,JsRuntime jsRuntime);
  
  // 扩展组件
  @override
  Widget parse(dom.Element node,JsRuntime jsRuntime,{ TStyleSheet? styleSheet}){
    return const SizedBox();
  }

  // 回调js组件的方法
  @override
  resolveCall(id,method,JsRuntime jsRuntime,{data}){
    // print(method);
    ready((){
      // debugPrint(moduleName+"[$id] resolveCall method[$method] data[$data].");
      var ret;
      if(data!=null){
        
        try{
          ret = json.encode(data);
        }catch(e){
          print(e);
        }
      }else{
        ret=null;
      }
      var code;
      if(windowCalls[id]!=null){
        String? _id = windowCalls[id];
        if(ret!=null){
          code = '(function(){ if('+_id!+' && '+_id+'.'+method+'){ '+_id+'.'+method+'('+ret+');}  })();';
        }else{
          code = '(function(){ if('+_id!+' && '+_id+'.'+method+'){ '+_id+'.'+method+'();}  })();';
        }
        jsRuntime.evaluate(code);
      }
      // }
    });
    
  }

  @override
  resolveReady(id,jsRuntime){
    resolveCall(id,"_resolveReady",jsRuntime);
  }

  ready(Function fn){
    if(!inited){
      __readyCalls.add(fn);
    }else{
      fn();
    }
  }

}
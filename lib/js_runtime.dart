
// ignore_for_file: unused_field

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuna3/dialog.dart';
import 'package:tuna3/js_plugins/web_socket.dart';
import 'package:tuna3/tuna3.dart';
import 'js_plugins/http.dart';
import 'js_plugins/path.dart';
import 'js_plugins/permission.dart';

import 'js_plugins/picker.dart';
import 'jscore/engine.dart';

class JsRuntime{
  
  String id;
  String pageId;

  static String pageBaseCode = '';
  // ignore: prefer_final_fields
  static Map<String,JsRuntime> instances = {};

  late JsCoreEngine jsEngine;

  bool isDebug = (const bool.fromEnvironment('dart.vm.product') == false);
  // ignore: prefer_final_fields
  Map<String,List<Function>> _javascriptMessageHandles = {};
  
  // ignore: prefer_final_fields
  List<Function> _disposeCalls = [];
  Map<String,dynamic> cache = {};
  Map<String,dynamic> scriptsTemplates = {};
  Map<String,dynamic> widgetsData = {};
  Map<String,TabController> tabControllers = {};
  Map<String,dynamic> filePlugins = {};
  Map<String,dynamic> directoryPlugins = {};

  //页面数据
  Map<String,dynamic>? pageData;
  dynamic pageArguments;

  bool onDispose = false;

  // 初始化
  JsRuntime(this.id,this.pageId){
    jsEngine = JsCoreEngine(id);
    jsEngine.addMessagesHandle(_handleMessage);
    // inject Tuna3.scriptModules
    for(var i=0;i<Tuna3.scriptModuleInstances.length;i++){
      Tuna3.scriptModuleInstances[i].insertToJsRuntime(this);
    }
    JsRuntime.instances[id] = this;
    // 权限相关操作监听
    TPermission.inserToJsRuntime(this);
    // 弹窗类
    XDialog.inserToJsRuntime(this);
    // file plugin
    TunaPathPlugin.insertToJsRuntime(this);
    // 绑定模块
    Picker().insertToJsRuntime(this);
    HttpModule().insertToJsRuntime(this);
    TWebSocket().insertToJsRuntime(this);
    // base javascript 
    evaluate(JsRuntime.pageBaseCode);
  }

  getTemplateById(String id){
    return scriptsTemplates[id];
  }

  dispose(){
    if(_disposeCalls.isNotEmpty){
      for(var i=0;i<_disposeCalls.length;i++){
        var _call = _disposeCalls[i];
        if( _call is Function){
          try{
            _call(this);
          }catch(e){
            debugPrint(e.toString());
          }
        }
      }
    }

    JsRuntime.instances.remove(id);

    onDispose = true;
    _javascriptMessageHandles.clear();
    scriptsTemplates.clear();
    widgetsData.clear();
    cache.clear();

    jsEngine.release();
  }

  registDispose(fn){
    if(!onDispose){
      for(var i=0;i<_disposeCalls.length;i++){
        var fn = _disposeCalls[i];
        if(fn is Function){
          fn(this);
        }
      }
    }
  }

  // 添加js message 事件处理
  addJavascriptMessageHandle(String name,Function fn){
    if(_javascriptMessageHandles.containsKey(name) && _javascriptMessageHandles[name] is List){
      _javascriptMessageHandles[name]!.add(fn);
    }else{
      _javascriptMessageHandles[name] = [fn];
    }
  }

  // 处理消息
  _handleMessage(JsMessage message){
    if(message.name=='__ConsoleLog'){
      return;
    }

    Timer.run(() {
      try{
        _javascriptMessageHandle(message.id,message.name,message.data);
      }catch(e){
        debugPrint(e.toString());
      }
    });
  }
  

  // javascript消息处理
  _javascriptMessageHandle(msgId,name,data)async {
    
    if(_javascriptMessageHandles.containsKey(name) && 
      _javascriptMessageHandles[name] is List  &&
      _javascriptMessageHandles.isNotEmpty
    ){
      
      var message = {"id":msgId,"name":name,"data":data};
      
      _javascriptMessageHandles[name]!.forEach((Function fn)async{
        try{
          // print(data);
          dynamic backData  = fn(data);
          if(backData is Future){
            backData = await backData;
          }
          if(backData==null){
            evaluate('__ResolveTPostMessage('+json.encode(message)+');');
          }else{
            try{
              evaluate('__ResolveTPostMessage('+json.encode(message)+','+json.encode(backData)+');');
            }catch(e){
              print(e);
            }
          }
        }catch(e){
          print("resolve message error:$e\t[$msgId\t$name\t$data]");
          evaluate('__RejectTPostMessage("'+json.encode(message)+'",'+json.encode(e.toString())+');');
        }
      });
    }else{
      debugPrint("message handle not found[$msgId\t$name\t$data]");
      evaluate('__RejectTPostMessage("'+msgId+'",'+json.encode({"message":"handle not found."})+');');
    }
  }

  // 删除消息监听方法
  removeJavascriptMessageHandle(String name,fn){
    // ignore: unnecessary_null_comparison
    if(_javascriptMessageHandles!=null && _javascriptMessageHandles.containsKey(name)){
      _javascriptMessageHandles[name]!.remove(fn);
    }
  }

  // 执行javascript
  evaluate(String code){
    try{
      if(!onDispose){
        return jsEngine.evaluate(code);
      }
    }on PlatformException catch(e){
      debugPrint('[JsRuntime]$e');
    }
  }

  evaluateFunc(fnName,params){
    if(params==null){
      return evaluate('!(function(){ if('+fnName+'){ '+fnName+'(); }  })();');
    }
    return evaluate('!(function(){ if('+fnName+'){ '+fnName+'('+json.encode(params)+'); }  })();');
  }

  // 当组件渲染成功时触发ready事件
  resolveWidgetReady(String widgetType,String widgetName){
    evaluate('(function(){ var r=T.get'+widgetType+'('+json.encode(widgetName)+');if(r){ r.resolveReadyStatus();  }   })();');
  }
  // resolveWidgetCall
  resolveWidgetCall(String widgetType,String widgetName,{String? callName,dynamic data}){
    if(data!=null){
      evaluate('(function(data){ try{ T.get'+widgetType+'("'+widgetName+'").'+callName!+'(data)}catch(e){}   })('+json.encode(data)+')');
    }else{
      evaluate('(function(){ try{ T.get'+widgetType+'("'+widgetName+'").'+callName!+'()}catch(e){}   })()');
      // evaluate('(function(data){})()');
    }
    
  }

  // add widget Message handle
  addWidgetMessageHandle(String widgetType,String widgetName,handle){
    addJavascriptMessageHandle("Tuna"+widgetType+"Event."+widgetName,handle);
  }

  // widget method 的快捷操作
  addWidgetMethodHandle( Map<String,String> widgetMap,String method,handle){
    if(widgetMap.containsKey("type") && widgetMap.containsKey("name")){
      String? _type = widgetMap["type"];
      String? _name = widgetMap['name'];
      addJavascriptMessageHandle("Tuna"+_type!+"Event."+_name!,(params){
        if(params is Map && params['method']== method){
          var data = params['data'];
          handle(data);
        }
      });
    }
  }

 // add widget Message handle
  removeWidgetMessageHandle(String widgetType,String widgetName,handle){
    var name = "Tuna"+widgetType+"Event."+widgetName;
    removeJavascriptMessageHandle(name,handle);
  }
  
}
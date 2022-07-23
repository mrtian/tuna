import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import './core.dart';
import './binding/js_value_ref.dart' as JSValueRef;
import 'core/js_object.dart';
import 'core/js_value.dart';


class JsCoreEngine{
  
  final String id;
  JSContext? jsContext;

  Map<String,List<Function>> _messageHandles = {};
  List<Function> _globalMessageHandles = [];
  Map<String,Timer> _intervalTimers = {};
  Map<String,Timer> _timeroutTimers = {};

  static Map<String,JsCoreEngine> instances = {};

  JsCoreEngine(this.id){

    jsContext = JSContext.createInGroup();
    JsCoreEngine.instances[id] = this;

    var postNativeMessageFunc = JSObject.makeFunctionWithCallback(
        jsContext!, '__PostGlobalNativeMessage', Pointer.fromFunction(JsCoreEngine.postNativeMessage)
    );

    jsContext!.globalObject.setProperty(
      "__PostGlobalNativeMessage",
      postNativeMessageFunc.toValue(),
      JSPropertyAttributes.kJSPropertyAttributeNone
    );
    String initCode = '''
    var __NativeJsCoreEngineId="$id";
    function __PostNativeMessage(messageId,messageName,messageData){
      __PostGlobalNativeMessage(__NativeJsCoreEngineId,messageId,messageName,messageData);
    }
    var __NativeSetTimeOutCallBackFuncitons = {};
    function setTimeout(fn,timer){
      var id = new Date().getTime()+"."+Math.random();
      __NativeSetTimeOutCallBackFuncitons[id] = fn;
      __PostNativeMessage(id,'__SetTimeout',timer);
      return id;
    }
    function clearTimeout(id){
      if(__NativeSetTimeOutCallBackFuncitons[id]){
        delete __NativeSetTimeOutCallBackFuncitons[id];
      }
      __PostNativeMessage(id,'__ClearTimeout');
    }
    var __NativeSetIntvervalCallBackFuncitons = {};
    function setInterval(fn,timer){
      var id = new Date().getTime()+"."+Math.random();
      __NativeSetIntvervalCallBackFuncitons[id] = fn;
      __PostNativeMessage(id,'__SetInterval',timer);
      return id;
    }
    function clearInterval(id){
      if(__NativeSetIntvervalCallBackFuncitons[id]){
        delete __NativeSetIntvervalCallBackFuncitons[id];
      }
      __PostNativeMessage(id,'__ClearInterval');
    }
    var console = {
      log:(message)=>{
        var id = new Date().getTime()+'';
        __PostNativeMessage(id,'__ConsoleLog',{
          "type":"info",
          "msg":message
        });
      },
      warn:(message)=>{
        var id = new Date().getTime()+'';
        __PostNativeMessage(id,'__ConsoleLog',{
          "type":"warn",
          "msg":message
        });
      },
      error:(message)=>{
        var id = new Date().getTime()+'';
        __PostNativeMessage(id,'__ConsoleLog',{
          "type":"error",
          "msg":message
        });
      }
    };
    ''';
    jsContext!.evaluate(initCode);
    // setTimeout
    addMessageHandle("__SetTimeout", (JsMessage message){
      var tid = Timer(Duration(milliseconds: message.data),(){
        jsContext!.evaluate('if(__NativeSetTimeOutCallBackFuncitons && __NativeSetTimeOutCallBackFuncitons["'+message.id+'"]){ __NativeSetTimeOutCallBackFuncitons["'+message.id+'"](); }');
        _timeroutTimers.remove(message.id);
      });
      _timeroutTimers[message.id] = tid;
    });
    // clearTimeout
    addMessageHandle("__ClearTimeout", (JsMessage message){
      if(_timeroutTimers.containsKey(message.id)){
        _timeroutTimers[message.id]!.cancel();
      }
      _timeroutTimers.remove(message.id);
    });
    // setInterval
    addMessageHandle("__SetInterval", (JsMessage message){
      var tid = Timer.periodic(Duration(milliseconds: message.data),(timer){
        jsContext!.evaluate('if(__NativeSetIntvervalCallBackFuncitons && __NativeSetIntvervalCallBackFuncitons["'+message.id+'"]){ __NativeSetIntvervalCallBackFuncitons["'+message.id+'"](); }');
      });
      _intervalTimers[message.id] = tid;
    });
    // clearInterval
    addMessageHandle("__ClearInterval", (JsMessage message){
      if(_intervalTimers.containsKey(message.id)){
        _intervalTimers[message.id]!.cancel();
      }
      _intervalTimers.remove(message.id);
    });
    // console
    addMessageHandle("__ConsoleLog", (JsMessage message){
      var type = message.data['type'];
      var msg = message.data['msg'];
      // ignore: avoid_print
      print('[Log $type]$msg');
      // print('[Log '+message.data['type']+']'+message.data['msg'].toString());
    });

  }

  static Pointer postNativeMessage(
    Pointer ctx,
    Pointer function,
    Pointer thisObject,
    int argumentCount,
    Pointer<Pointer> arguments,
    Pointer<Pointer> exception
  ){
    if (argumentCount >2) {
      var jsEngineIdRef = arguments[0];
      JSString _jsEngineId = JSString(JSValueRef.jSValueToStringCopy(ctx,jsEngineIdRef,JSValuePointer(nullptr).pointer));
      String jsEngineId = _jsEngineId.string!;
      
      var engine = JsCoreEngine.instances[jsEngineId];
      
      // get messageId
      var msgIdRef =  arguments[1];
      String messageId = JSValue(engine!.jsContext!, msgIdRef).string!;
      var nameRef = arguments[2];
      String name  = JSValue(engine.jsContext!, nameRef).string!;
      var data;
      if(argumentCount>3){
        var dataRef = arguments[3];
        JSValue _data = JSValue(engine.jsContext!, dataRef);
        data = JsCoreEngine.convertJsValue(_data);
      }
      JsMessage message = JsMessage(messageId, name, data);
      if(message.name !="__ConsoleLog" && 
        message.name !="__SetTimeout" &&
        message.name !="__SetInterval" && 
        message.name !='__ClearInterval' &&  
        message.name !='__ClearTimeout'
      ){
        engine._globalMessageHandles.forEach((fn) {
          try{
            fn(message);
          }catch(e){}
        });
      }
      engine._handleMessageFromJs(message);
    }
    
    return nullptr;
  }

  // 处理Javascript传递的消息
  _handleMessageFromJs(JsMessage message){
     if(_messageHandles.containsKey(message.name) && 
      _messageHandles[message.name]!.isNotEmpty
     ){
       _messageHandles[message.name]!.forEach((msgCallFn) async{
         var backData = msgCallFn(message);
         if(message.name=="__ConsoleLog" || 
          message.name=="__SetTimeout" || 
          message.name=="__SetInterval" || 
          message.name=='__ClearInterval' ||  
          message.name=='__ClearTimeout'
         ){
           return;
         }
         if(backData is Future){
           backData = await backData;
         }
         resolveJavascriptMessage(message.id,backData);
       });
     }
  }

  // 转换变量
  converToDart(JSValue val){
    return JsCoreEngine.convertJsValue(val);
  }

  static convertJsValue(JSValue value){
    var data;
    // 仅支持这几种类型，其它设置为null
    if(value.isArray || value.isObject){
      JSObject obj = value.toObject();
      if(obj.isConstructor || obj.isFunction){
        data = null;
      }else{
        try{
          var str = value.createJSONString(null);
          data = json.decode(str.string!);
        }catch(e){
          // ignore: avoid_print
          print(e);
        }
      }
    }else if(value.isBoolean){
      data = value.toBoolean;
    }else if(value.isString){
      data = value.string;
    }else if(value.isNumber){
      var val = value.string;
      data = int.tryParse(val!);
      if(data==null){
        data = value.toNumber();
      }
    }else{
      data = null;
    }
    return data;
  }

  // 执行JS
  JSValue? evaluate(String code){
    if(jsContext==null){
      return null;
    }
    try{
      return jsContext!.evaluate(code);
    }catch(e){
      print(e);
    }
    return null;
  }

  evaluateToDart(String code){
    if(jsContext==null){
      return null;
    }
    try{
      JSValue ret =  jsContext!.evaluate(code);
      return JsCoreEngine.convertJsValue(ret);
    }catch(e){
      print(e);
    }
    return null;
  }

  resolveJavascriptMessage(messageId,resolveData){
    if(jsContext==null){
      return null;
    }
    jsContext!.evaluate('if(__NativeResolveMessage){ __NativeResolveMessage("'+messageId+'"'+(resolveData==null?'':','+json.encode(resolveData))+');}');
  }

  addMessagesHandle(handle){
    _globalMessageHandles.add(handle);
  }

  removeMessagesHandle(handle){
    _globalMessageHandles.remove(handle);
  }

  // 添加消息处理
  addMessageHandle(String name,Function handle){
    
    if(_messageHandles.containsKey(name)){
      _messageHandles[name]!.add(handle);
    }else{
      _messageHandles[name] = [handle];
    }
  }
  // 删除消息处理
  removeMessageHandle(String name,Function handle){
    if(_messageHandles.containsKey(name) && _messageHandles[name] is List && _messageHandles[name]!.contains(handle)){
      _messageHandles[name]!.remove(handle);
    }
  }
  // 清除消息处理
  clearMessageHandle(String name){
    if(_messageHandles.containsKey(name)){
      _messageHandles[name]!.clear();
    }
  }

  release(){
    _timeroutTimers.forEach((id, timer) {
      timer.cancel();
    });
    _intervalTimers.forEach((id, timer) { 
      timer.cancel();
    });
    
    JsCoreEngine.instances.remove(id);
    jsContext!.release();
  }

}


class JsMessage{

  final String id;
  final String name;
  final dynamic data;

  JsMessage(this.id,this.name,this.data);

  @override
  String toString() {
    return '{id:$id, name:$name, data:$data}';
  }
  
}
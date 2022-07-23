import 'dart:convert';

import '../js_runtime.dart';
import '../module.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;


class TWebSocketPlugin{
  final TWebSocket instance;
  final IOWebSocketChannel channel;
  final Map<dynamic,dynamic> wsConfig;
  TWebSocketPlugin(this.instance,this.channel,this.wsConfig);
}

/// WebSocket状态
enum SocketStatus {
  SocketStatusConnecting,
  SocketStatusConnected, // 已连接
  SocketStatusFailed, // 失败
  SocketStatusClosed, // 连接关闭
}


class TWebSocket extends ScriptModule{
  TWebSocket() : super("TWebSocket");

  static Map<String,TWebSocketPlugin> instances = {};

  // 重连
  reconnect(id,jsRuntime){
    TWebSocketPlugin? plugin = TWebSocket.instances[id];
    if(plugin!=null){
      plugin.channel.sink.close(status.goingAway);
      openWs(id,plugin.wsConfig,jsRuntime);
    }
  }
  // 连接ws
  openWs(id,data,jsRuntime){

    TWebSocketPlugin? plugin = TWebSocket.instances[id];
    Iterable<String>? protocols;
    
    if(data.containsKey("protocols") && data['protocols'] is List){
      protocols = data['protocols'];
    }
    var channel = IOWebSocketChannel.connect(data['url'], protocols:protocols,headers: data['headers'],pingInterval:(data.containsKey('pingInterval')?Duration(milliseconds:data['pingInterval']):null));
    
    channel.stream.listen((message) {
      // print(message);
      resolveCall(id, "onMessage",jsRuntime,data: message);
    },onDone: (){
      resolveCall(id, "onClose",jsRuntime);
      // resolveCall(id, "onMessage",data: '{"status":"opened"}',jsRuntime: jsRuntime);
    },onError: (e){
      // print(e);
      resolveCall(id, "onError",jsRuntime,data:e.toString());
      // channel.sink.close();
    });

    plugin = TWebSocketPlugin(this,channel,data);
    TWebSocket.instances[id] = plugin;
  }

  @override
  methodCall(String id, String method, data, JsRuntime jsRuntime) async{
    jsRuntime.registDispose((){
      TWebSocket.instances.remove(id);
    });

    TWebSocketPlugin? plugin = TWebSocket.instances[id];

    if(method=='_onCreated'){
      // 存储实例
      if(plugin == null && data is Map){
        openWs(id, data, jsRuntime);
      }
      resolveCall(id, "onInited",jsRuntime,data: {"code":0,"message":"success"});
    }

    if(plugin !=null){
      switch(method){
        case "close":
          await plugin.channel.sink.close(status.goingAway,data);
          resolveCall(id, "onClose",jsRuntime,data: {"code":status.goingAway,"reason":data});
          break;
        case "sendMessage":
          String dataStr;
          if(data is String){
            dataStr = data;
          }else{
            dataStr = json.encode(data);
          }
          // print(dataStr);
          plugin.channel.sink.add(dataStr);
          break;
        case "reconnect":
          reconnect(id, jsRuntime);
          break;
      }
    }else{
      return {"error":404,"message":"socket instance not exist or not inited."};
    }
  }
}
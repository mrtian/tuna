import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuna3/js_runtime.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/module.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tuna3/widgets.dart';
import 'package:tuna3/widgets/widgets/xbuilder.dart';
import 'package:tuna3/widgets/xwidget.dart';
import './page.dart';
import 'jscore/engine.dart';


// 页面组件
class TPageController extends GetxController{
  Map<String,dynamic> data;
  String route;
  static Map<String,dynamic>? instances;
  TPageController(this.route,this.data);
}


class TunaNavigatorObserver extends NavigatorObserver{
  @override
  void didPop(Route route, Route? previousRoute) {
    try{
      String? routeName = route.settings.name;
      if(JsCoreEngine.instances.containsKey(routeName)){
        JsCoreEngine.instances[routeName]!.release();
      }

     

      // if(TPageController.instances!.containsKey(routeName)){
      //   if(TPageController.instances![routeName] !=null){
      //     TPageController.instances![routeName].dispose();
      //   }
      // }

      // if(XWidgetController.instances.containsKey(routeName)){
      //   XWidgetController.instances[routeName]!.forEach((XWidgetController _c) { 
      //     if(!_c.isClosed){
            
      //     }
      //   });
      // }

      // dynamic popResult;
      // try{
      //   if(route.currentResult!=null){
      //     popResult = json.encode(route.currentResult);
      //   }
      // }catch(e){
      //   debugPrint(e.toString());
      // }
      // 页面已经没了
      JsRuntime.instances.forEach((id, jsRuntime) {
        var data = {
          "name":routeName,
          "arguments":route.settings.arguments
          // "result":route.currentResult
        };
        jsRuntime.evaluateFunc('T._resolvePageDidPop',data);
      });
      
    }catch(e){
      // ignore: avoid_print
      print(e.toString());
    }
  }

  @override 
  didRemove(Route route, Route? previousRoute){

  }
  @override 
  didReplace({ Route<dynamic>? newRoute, Route<dynamic>? oldRoute }) {

  }

  /// The [Navigator]'s routes are being moved by a user gesture.
  ///
  /// For example, this is called when an iOS back gesture starts, and is used
  /// to disabled hero animations during such interactions.
  @override 
  didStartUserGesture(Route<dynamic> route, Route<dynamic>? previousRoute) {

  }

  /// User gesture is no longer controlling the [Navigator].
  ///
  /// Paired with an earlier call to [didStartUserGesture].
  @override 
  didStopUserGesture() {

  }

}

class TunaAppConfig{
  String? title;
  Widget home;

  ThemeData? theme;
  ThemeData? darkTheme;
  Color? color;
  Locale? locale;

  TunaAppConfig({
    this.title,
    required this.home,
    this.theme,
    this.darkTheme,
    this.color,
    this.locale
  });
}


class Tuna3 {

  // 文件目录
  static String appDocPath = "/";
  static String appTempPath = "/";

  static TWidgets widgetParser = TWidgets();

  static const MethodChannel _channel = MethodChannel('tuna3');

  static JsCoreEngine jsCore =  JsCoreEngine("RootJsCore");
  
  static late GetMaterialApp app;
  static  GetHttpClient? httpClient;
  static Map<String,dynamic>? appHttpConfig;

  static Map<String,bool> initedRoutes = {};

  // 自定义javascript交互模块
  static List<ScriptModule> scriptModuleInstances = [];

  static String toMd5(String val){
    return md5.convert(utf8.encode(val).toList()).toString();
  }

  // app 默认 http请求
  static Future<Response> request(url,{Map<String,dynamic>? options}){
    appHttpConfig ??= {
      "userAgent":"tuna3-http-client",
      "timeout":10
    };
    httpClient ??= GetHttpClient(
      userAgent: appHttpConfig!['userAgetn'] ?? 'tuna3-http-client',
      timeout:Duration(seconds: (appHttpConfig!['timeout']?? 10)),
      followRedirects:appHttpConfig!['followRedirects'] ??  true,
      maxRedirects: appHttpConfig!['maxRedirects'] ?? 5,
      sendUserAgent: appHttpConfig!['sendUserAgent'] ?? false,
      maxAuthRetries: appHttpConfig!['maxAuthRetries'] ??  1,
      allowAutoSignedCert : appHttpConfig!['allowAutoSignedCert'] ?? false,
      baseUrl:appHttpConfig!['baseUrl'],
      trustedCertificates:appHttpConfig!['trustedCertificates'],
      withCredentials:appHttpConfig!['withCredentials'] ?? false,
      findProxy:appHttpConfig!['proxy']
    );
   
    options ??= {
        "method":"GET"
      };

    return httpClient!.request(url, options['method'],
      body: options['body'], 
      contentType: options['contentType'],
      headers: options['headers'],
      query:options['query'],
      decoder:options['decoder'],
      uploadProgress:options['uploadProgress']
    );
  }

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<dynamic> get deviceInfo async{
    if(Platform.isIOS){
      return await _channel.invokeMethod("getIosDeviceInfo");
    }else if(Platform.isAndroid){
      return await _channel.invokeMethod("getAndroidDeviceInfo");
    }
  }

  static Future<dynamic> get packageInfo async{
    return await _channel.invokeMethod('getPackageInfo');
  }

  ///
  /// Returns the IPv4-Address the device is aware of
  /// (depending on your network configuration)
  /// Can be null
  static Future<String> get ipV4 async {
    return await _channel.invokeMethod('getIpV4');
  }

  ///
  /// Returns the users IPv6-Address the device is aware of
  /// (depending on your network configuration)
  /// Is null on iOS
  static Future<String> get ipV6 async {
    return await _channel.invokeMethod('getIpV6');
  }

  // 获取页面
  static Future<Widget> httpPage(url,arguments,{
    Map<String,String>? headers,
    method = 'GET',
    Map<String,dynamic>? data
  }) async{
    if(url is String){
      url = Uri.parse(url);
    }
    String? resTxt;
    try{
      if(method=='GET'){
        var response = await Tuna3.request(url,options:{"headers":headers});
        if(response.statusCode == 200 && response.bodyString!=null){
          resTxt = response.bodyString;
        }
      }else if(method=='POST'){
        var response = await Tuna3.request(url,options:{"method":"POST","body":data,"headers":headers});
        if(response.statusCode == 200 && response.bodyString!=null){
          resTxt = response.bodyString;
        }
      }
    }catch(e){
      debugPrint(e.toString());
    }
    if(resTxt!=null){
      return TunaPage(string: resTxt,);
    }else{
      NullThrownError();
    }

    return  ErrorTWidget("Page loaed error!");
  }

  static Future<Widget> assetsPage(assetsPath,arguments) async{
    String? resTxt;
    try{
      resTxt = await rootBundle.loadString(assetsPath);
      // print("hihihi");
      return TunaPage(string: resTxt,);
    }catch(e){
      // ignore: avoid_print
      print(e);
      // NullThrownError();
    }
    
    return  ErrorTWidget("Page loaed error!");
  }

  static Future<Widget> filePage(filePath,arguments) async{
    String? resTxt;
    resTxt = await rootBundle.loadString(filePath);

    return  ErrorTWidget("Page loaed error!");
  }

  
  // 广播消息
  static broadcast(name,data){
    JsRuntime.instances.forEach((id, jsRutime) {
      if(!jsRutime.onDispose){
        jsRutime.evaluateFunc("T._resolveBroadcast", {"name":name,"data":data});
      }
    });
  }

  static parseWidget(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}){
    if(node.attributes.containsKey("id") && node.localName=="x:builder"){
      return XBuilder(node, jsRuntime,styleSheet: styleSheet,);
    }else if(node.attributes.containsKey("id") && node.localName!.startsWith("x:")){
      return XWidget(element: node, jsRuntime: jsRuntime,styleSheet: styleSheet,);
    }
    return widgetParser.parse(node,jsRuntime,styleSheet:styleSheet);
  }

  static parseWidgets(List<dom.Element> nodes,JsRuntime jsRuntime,{TStyleSheet? styleSheet}){
    List<Widget> ret = [];
    // ignore: avoid_function_literals_in_foreach_calls
    nodes.forEach((node) {
      var w = parseWidget(node,jsRuntime,styleSheet: styleSheet);
      if(w!=null){
        ret.add(w);
      }
    });
    return ret;
  }

  static parseTemplate(String tpl,{Map<String,dynamic>? data,Map<String,dynamic>? options,String? cacheKey}){
    var opt = options??{};
    if (cacheKey != null) {
      opt["filename"] = cacheKey;
    }
    String script = 'template('+json.encode(tpl.trim())+','+json.encode(data)+','+json.encode(opt)+');';
    // print(script);
    return runJavascript(script);
  }

  // 执行 javascript 并返回结果
  static runJavascript(String script){
    try{
      return  jsCore.evaluate(script);
    }on PlatformException catch(e){
      debugPrint('[JsRuntime]$e');
    }
    return null;
  }
  
  // 生成APP
  static Future<GetMaterialApp> createApp(name,TunaAppConfig config,{
    onInit,
    onReady,
    onDispose,
    routingCallback,
    enableLog = false,
    showDebugMode = false,
    showDebugMaterialGrid = false,
    popGesture,
    Map<String,dynamic>? httpConfig,
    List<ScriptModule> scriptModules = const []
  }) async{

    if (Platform.isAndroid) {
      SystemUiOverlayStyle systemUiOverlayStyle =
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent);
      SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
    }
    // 加载模板解析js
    // load template js
    try{
      String tplJsCode = await rootBundle.loadString("packages/tuna3/javascripts/template.js");
      jsCore.evaluate(tplJsCode);
    }catch(e){
      debugPrint(e.toString());
    }

    // config.theme = config.theme ?? ThemeData(
    //   fontFamily: "PingFang"
    // );

    if(httpConfig!=null){
      appHttpConfig = httpConfig ;
    }

    appDocPath = (await getApplicationDocumentsDirectory()).path;
    appTempPath = (await getTemporaryDirectory()).path;

    // jsRuntime pageBaseCode
    scriptModuleInstances = scriptModules;

    try{
      JsRuntime.pageBaseCode = await rootBundle.loadString("packages/tuna3/javascripts/tuna3.js");
      if(scriptModules.isNotEmpty){
        for(var i=0;i<scriptModules.length;i++){
          ScriptModule module = scriptModules[i];
          if(module.jsAssets.isNotEmpty){
            try{
              String code = await rootBundle.loadString(module.jsAssets);
              if(code.isNotEmpty){
                JsRuntime.pageBaseCode += code;
              }
            }catch(e){
              // ignore: avoid_print
              print("module[${module.moduleName}] script[${module.jsAssets}] load error");
            }
          }
        }
      }
    }catch(e){
      debugPrint(e.toString());
    }

    app =   GetMaterialApp(
      title: config.title!,
      home: config.home,
      theme: config.theme,
      darkTheme: config.darkTheme,
      color:config.color,
      locale:config.locale,
      onInit:onInit,
      onReady:onReady,
      onDispose:onDispose,
      popGesture: popGesture,
      navigatorObservers:  [TunaNavigatorObserver()],
      routingCallback:(route){
        
        if(route!=null){
          var r = route.route;
          if(r!=null){
            var setting = r.settings;
            var name = setting.name;
            var args = setting.arguments;
            var result = r.currentResult;
            // ignore: invalid_use_of_protected_member
            Tuna3.broadcast("routingCallback",{
              "name":name,
              "arguments":args,
              "result":result,
              "isActive":r.isActive,
              "isBack":route.isBack,
              "isCurrent":r.isCurrent,
              "isFirst":r.isFirst,
              "isBlank":r.isBlank,
              // "popped":r.popped,
              // "runtimeType":r.runtimeType,
              "isDialog":route.isDialog,
              "isBottomSheet":route.isBottomSheet,
              "removed":route.removed,
              "previous":route.previous,
              // "current":route.current,
              // "isSnackbar":route.isSnackbar??false
            });
          }
        }
      },
      enableLog:enableLog,
      debugShowMaterialGrid:showDebugMaterialGrid,
      debugShowCheckedModeBanner:showDebugMode
    );

    
    return app;

  }
}


class ErrorTWidget extends StatelessWidget{
  final String errorInfo;
  ErrorTWidget(this.errorInfo);
  @override
  Widget build(BuildContext context) {
    return  Container(alignment: Alignment.center,child: Text(errorInfo));
  }
  
}

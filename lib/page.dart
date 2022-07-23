import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/jscore/core/js_value.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import './js_runtime.dart';

import 'tuna3.dart';
import 'utils/animate_parse.dart';

// 模板
class TunaTemplate{
  
  static Map<String,TunaTemplate> routes = {};

  String string;
  Map<String,dom.Element> pages = {};
  String? route;
  String? name;
  late dom.Element doc;
  late List<dom.Element> scripts;
  late List<dom.Element> styles;
  dynamic data;
  dynamic arguments;

  TunaTemplate(this.string,{
    this.data,
    this.arguments
  }){
    dom.DocumentFragment fragment = parseFragment(string);
    
    if(fragment.children.isNotEmpty){

      doc = fragment.children[0];
      route = doc.attributes['route'];
      name = doc.attributes['name'];

      scripts = doc.getElementsByTagName("script");
      styles = doc.getElementsByTagName("style");
      
      // contains other page string
      if(fragment.children.length>1){
        for (var i = 1; i < fragment.children.length; i++) {
          dynamic _routeName = fragment.children[i].attributes['route'];
          // print(_routeName);
          if(_routeName!=null){
            // print(fragment.children[i].outerHtml);
            TunaTemplate(fragment.children[i].outerHtml);
          }
        }
      }

      // save route
      if(route!=null){
        TunaTemplate.routes[route!] = this;
      }

    }
  }
}



// ignore: must_be_immutable
class TunaPage extends GetView<TPageController>{

  late JsRuntime jsRuntime;
  late TStyleSheet styleSheet;
  String? route;
  String? string;
  dynamic arguments;
  Map<String,dynamic>? data;
  List<String> styles = [];
  // bool isBindingReady = false;

  TunaPage({Key? key, 
    this.route,
    this.string,
    this.data,
    this.arguments
  }) : super(key: key);

  // 组件渲染成功后回调
  bindingPost(fn){
    // 页面渲染完成后执行
    var widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback(fn);
  }
  

  // 解析执行javascript
  evalScripts(List<Map<String,String>>scripts)async{
    bindingPost((_){
      // print("eval page args and data1");
      String resolvePageDatacode = 'T._resolvePageArgsData('+json.encode(arguments)+','+json.encode(data)+');';
      jsRuntime.evaluate(resolvePageDatacode);
      // print("eval page args and data2");
    });
    // List<String> codes = [];
    for(var i=0;i<scripts.length;i++){
      if(scripts[i].containsKey("code")){
        // codes.add(scripts[i]['code']!);
        if(scripts[i]['code']!=null && scripts[i]['code']!.isNotEmpty){
          bindingPost((_t){
            jsRuntime.evaluate(scripts[i]['code']!);
          });
        }
      }else if(scripts[i].containsKey("src")){
        try{
          var response = await Tuna3.request(scripts[i]['src']);
          if(response.statusCode==200 && response.bodyString!=null){
            bindingPost((_t){
              jsRuntime.evaluate(response.bodyString!);
            });
          }
        }catch(e){
          // ignore: avoid_print
          print(e);
        }
      }
    }
  }

  // 初始化消息监听
  _evalJsRuntimeBaseListen(){
    // 打开页面
    jsRuntime.addJavascriptMessageHandle("T.openPage", (message)async{
      if(message is Map){

        var args = message['args'];
        var data = message['data'];
        String? url = message['url'];
        var route = message['route'];
        
        Map<String,dynamic> setting = message['setting']??{};

        bool? off = setting["off"]??false;
        bool? offAll = setting["off"] ?? false;

        bool fullscreenDialog = setting['fullscreenDialog']  ?? false;

        dynamic curve = setting['curve'];
        dynamic transition = setting['transition'];
        
        if(curve !=null){
          curve = AnimateParse.curve(curve);
        }

        if(transition !=null){
          transition = _parseTransition(transition);
        }
        
        dynamic page;
        
        if(route!=null && TunaTemplate.routes.containsKey(route)){
          // print("here am i!");
          page = TunaPage(route: route, arguments: args, data: data,);
        }else{
          
          if(url!.startsWith("http") || url.startsWith("fttp")){
            page = await Tuna3.httpPage(url, args,data:data);
          }else if(url.startsWith("file://")){
            page = await Tuna3.filePage(url.replaceAll("file:/", ""), args);
          }else if(url.startsWith("assets:/")){
            page = await Tuna3.httpPage(url.replaceAll("assets://", ""), args,data:data);
          }else{
            page = TunaPage(string: url,route: route, arguments: args, data: data);
          }
        }

        if(page!=null){
          var bakData;
          if(off!=null && off){
            bakData =  await Get.off(page, routeName:route, fullscreenDialog: fullscreenDialog, curve: curve, transition: transition);
          }else if(offAll!=null && offAll){
            bakData =  Get.offAll(page, routeName:route, fullscreenDialog: fullscreenDialog, curve: curve, transition: transition);
          }
          bakData =  await Get.to(page, routeName:route, fullscreenDialog: fullscreenDialog, curve: curve, transition: transition);
          
          if(bakData!=null){
            return bakData;
          }
        }else{
          
        }
      }
    });
    
    // 跳转路由
    jsRuntime.addJavascriptMessageHandle("T.toPage", (message){
      if(message is Map && message.containsKey("name")){
        var args = message['args'];
        var params = message['params'];
        
        return Get.toNamed(message['name'],arguments: args,parameters: params);
      }
    });
    // 退回 
    jsRuntime.addJavascriptMessageHandle("T.back", (message){
      // print(message);
      if(message!=null && message is Map && message.containsKey("data")){
        return Get.back(result:message['data']);
      }
      return Get.back();
      
    });

    jsRuntime.addJavascriptMessageHandle("T.unfocus", (message){
      FocusScope.of(Get.context!).requestFocus(FocusNode());
      return true;
    });
    
    // launch
    jsRuntime.addJavascriptMessageHandle("T.launch", (url)async{
      if(await canLaunch(url)){
        if(Platform.isIOS && url.startsWith("http")){
          return await launch(url,forceSafariVC:true);
        }else{
          return await launch(url);
        }
      }else{
        Get.showSnackbar(const GetSnackBar(
          title: "无法打开此链接",
          borderRadius:8.0,
          duration: Duration(microseconds: 1500),
          backgroundColor: Color(0xF9000000),
        ));
        return false;
      }
    });
    // 广播消息
    jsRuntime.addJavascriptMessageHandle("T.broadcast", (Map<String,dynamic>message){
      String name = message['name'];
      dynamic data = message['data'];
      Tuna3.broadcast(name, data);
      return true;
    });

    // http 请求
    jsRuntime.addJavascriptMessageHandle("T.request", (message)async{
      String url = message['url'];
      Map<String,dynamic>? options = message['options'];
      Response? ret;
      
      try{
        ret = await Tuna3.request(url,options: options);
        // print(ret);
      }catch(e){
        debugPrint(e.toString());
        return false;
      }
      
      return {
        "statusCode":ret.statusCode,
        "data":ret.bodyString,
        "hasError":ret.hasError,
        "headers":ret.headers
      };
      
    });

  }

  @override
  Widget build(BuildContext context) {
    
    // 模板
    TunaTemplate? template;
    late String pid;
    if(route!=null && TunaTemplate.routes.containsKey(route)){
      template = TunaTemplate.routes[route];
    }else if(string!=null){
      template = TunaTemplate(string!);
    }

    if(template!=null){
      // js执行环境
      if(template.route!=null){
        jsRuntime = JsRuntime(template.route!,template.route!);
        pid = template.route!;
      }else{
        pid = Tuna3.toMd5(string!);
        jsRuntime = JsRuntime(pid, pid);
      }
      
      // eval base message hds
      _evalJsRuntimeBaseListen();

      dom.Element doc = template.doc;

      Color? backgroundColor;
      if(doc.attributes.containsKey("backgroundColor")){
        // backgroundColor = StyleUtils.parseColor(doc.attributes['backgroundColor']);
      }
      bool? resizeToAvoidBottomInset;
      if(doc.attributes['resizeToAvoidBottomInset']=='true'){
        resizeToAvoidBottomInset = true;
      }else if(doc.attributes['resizeToAvoidBottomInset']=='false'){
        resizeToAvoidBottomInset = false;
      }

      Color? drawerScrimColor;
      if(doc.attributes.containsKey("drawerScrimColor")){
        // drawerScrimColor = StyleUtils.parseColor(doc.attributes['drawerScrimColor']);
      }

      double? drawerEdgeDragWidth;
      if(doc.attributes.containsKey("drawerEdgeDragWidth")){
        // drawerEdgeDragWidth = double.parse(doc.attributes['drawerEdgeDragWidth']);
      }

      
      if(doc.localName=='template'){
        // --------------------- 解析 javascript and css ----------------------------
        // script 
        List<Map<String,String>> scriptsCode = [];
        if(template.scripts.isNotEmpty){
          for (var element in template.scripts) { 
            String code = element.innerHtml.trim();
            String? type = element.attributes['type'];
            String? src = element.attributes['src'];
            
            if(type=='text/template'){
              if(element.attributes.containsKey("id")){
                String _id = element.attributes['id']!;
                jsRuntime.scriptsTemplates[_id] = code;
                jsRuntime.evaluate('if(typeof(__pageTempates__)=="undefined"){var __pageTempates__={};};__pageTempates__["'+_id+'"]='+json.encode(code)+';');
              }
              
            }else if(type=='data/json'){
              if(element.innerHtml.trim().isNotEmpty){
                dynamic _data;
                try{
                  _data = json.decode(element.innerHtml);
                }catch(e){
                  debugPrint(e.toString());
                }
                // widget init Data
                
                if(element.attributes.containsKey("id")){
                  var widgetId = element.attributes['id']!;
                  jsRuntime.widgetsData[widgetId] = _data;
                }else{
                  // page data extend
                  if(data==null){
                    data = _data;
                  }else{
                    // 扩展和必写数据
                    for(var p in _data){
                      data![p] = _data[p];
                    }
                  }
                }
              }
            }else{
              if(src!=null){
                scriptsCode.add({"src":src});
              }else if(code.isNotEmpty){
                scriptsCode.add({"code":code});
              }
            }
          }
        }

        // 解析javascript
        if(scriptsCode.isNotEmpty){
          evalScripts(scriptsCode);
        }

        // style
        if(template.styles.isNotEmpty){
          for(var s=0;s<template.styles.length;s++){
            styles.add(template.styles[s].innerHtml);
          }
        }
        if(styles.isNotEmpty){
          styleSheet  = TStyleSheet(styles.join(""),templateId: pid);
        }else{
          styleSheet = TStyleSheet("",templateId: pid);
        }

        // --------------------- 解析Widget ----------------------------
        // 然后再解析组件，因为组件需要数据和样式表

        // appbar 头部UI
        List<dom.Element> appbarEls = doc.getElementsByTagName("appbar");
        dynamic appbar;
        if(appbarEls.isNotEmpty){
          appbar = Tuna3.parseWidget(appbarEls[0],jsRuntime,styleSheet:styleSheet);
        }
        
        // 主UI
        Widget? body;
        List<dom.Element> bodyEls = doc.getElementsByTagName("appbody");
        
        if(bodyEls.isNotEmpty){
          // if(bodyEls[0].children[0].localName=="text"){
          //   body =  Container(alignment:Alignment.center,child: Text(bodyEls[0].children[0].innerHtml));
          // }else{
            body = Tuna3.parseWidget(bodyEls[0].children[0],jsRuntime,styleSheet:styleSheet);
          // }
          
        }else{
          body = Container(alignment: Alignment.center,child: const Text("Not set app body content!"));
        }

        // 底部navbar
        Widget? btNavBar;
        List<dom.Element> btNavBarEls = doc.getElementsByTagName("bottomNavigationBar");
        if(btNavBarEls.isNotEmpty){
          btNavBar = Tuna3.parseWidget(btNavBarEls[0],jsRuntime,styleSheet:styleSheet);
        }

        // floatingactionbutton
        Widget? flgatBtn;
        List<dom.Element> flgatBtnEls = doc.getElementsByTagName("floatingactionbutton");
        if(flgatBtnEls.isNotEmpty){
          flgatBtn = Tuna3.parseWidget(flgatBtnEls[0],jsRuntime,styleSheet:styleSheet);
        }
        // drawer
        Widget? drawer;
        List<dom.Element> drawerEls = doc.getElementsByTagName("drawer");
        if(drawerEls.isNotEmpty){
          drawer = Tuna3.parseWidget(drawerEls[0],jsRuntime,styleSheet:styleSheet);
        }
        // drawer
        Widget? endDrawer;
        List<dom.Element> enddrawerEls = doc.getElementsByTagName("enddrawer");
        if(enddrawerEls.isNotEmpty){
          endDrawer = Tuna3.parseWidget(enddrawerEls[0],jsRuntime,styleSheet:styleSheet);
        }
        // drawer
        Widget? bottomSheet;
        List<dom.Element> bottomsheetEls = doc.getElementsByTagName("bottomsheet");
        if(bottomsheetEls.isNotEmpty){
          bottomSheet = Tuna3.parseWidget(bottomsheetEls[0],jsRuntime,styleSheet:styleSheet);
        }

        dynamic _page = Scaffold(
          backgroundColor:backgroundColor,
          appBar: appbar,
          body: body,
          bottomNavigationBar: btNavBar,
          floatingActionButton: flgatBtn,
          drawer: drawer,
          endDrawer:endDrawer,
          bottomSheet: bottomSheet,
          drawerEnableOpenDragGesture:drawer==null?false:true,
          endDrawerEnableOpenDragGesture:endDrawer==null?false:true,
          onDrawerChanged:(isOpen){
            jsRuntime.evaluate('T.resolveDrawerChange('+(isOpen?'true':'false')+')');
          },
          onEndDrawerChanged:(isOpen){
            jsRuntime.evaluate('T.resolveEndDrawerChange('+(isOpen?'true':'false')+')');
          },
          resizeToAvoidBottomInset:resizeToAvoidBottomInset,
          drawerScrimColor:drawerScrimColor,
          drawerEdgeDragWidth:drawerEdgeDragWidth
        );

        dynamic brightness;
        if(doc.attributes.containsKey("brightness") && doc.attributes["brightness"]!.isNotEmpty){
          brightness = doc.attributes['brightness'];
          if(brightness == 'dark' || brightness == 'light'){
            _page = AnnotatedRegion<SystemUiOverlayStyle>(
              value: brightness == 'dark'?SystemUiOverlayStyle.dark:SystemUiOverlayStyle.light,
              child:_page
            );
          }
        }

        var ret =  WillPopScope(child: _page, onWillPop: (){
          String code = '(function(){ return T.onPagePop();})();';
          JSValue s = jsRuntime.evaluate(code);
          if(s.isBoolean){
            return Future.value(s.toBoolean);
          }
          // 默认返回true,直接返回
          return Future.value(true);
        });

        return ret;
        

      }else{
        // --------------------- 非完整page ,单一 widget ----------------------------
        try{
          return Tuna3.parseWidget(doc,jsRuntime);
        }catch(e){
          debugPrint(e.toString());
        }
      }

    }

    return   Container(alignment: Alignment.center,child: const Text("Page render error!"));
  }

  _parseTransition(String transition){
    switch(transition){
      case "fade":
        return Transition.fade;
      case "fadeIn":
        return Transition.fadeIn;
      case "rightToLeft":
        return Transition.rightToLeft;
      case "leftToRight":
        return Transition.leftToRight;
      case "upToDown":
        return Transition.upToDown;
      case "downToUp":
        return Transition.downToUp;
      case "rightToLeftWithFade":
        return Transition.rightToLeftWithFade;
      case "leftToRightWithFade":
        return Transition.leftToRightWithFade;
      case "zoom":
        return Transition.zoom;
      case "topLevel":
        return Transition.topLevel;
      case "noTransition":
      case "no":
        return Transition.noTransition;
      case "cupertino":
        return Transition.cupertino;
      case "cupertinoDialog":
        return Transition.cupertinoDialog;
      case "size":
        return Transition.size;
      default:
        return Transition.native;
    }
  }
}
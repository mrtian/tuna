import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/utils/style_parse.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter/platform_interface.dart';

import '../../js_runtime.dart';
import '../../style_sheet.dart';
import '../../tuna3.dart';
import '../widget.dart';

class TWidgetWebview  extends TWidget{
  
  TWidgetWebview():super(tagName: 'webview');

  static clearCookies() {
    CookieManager().clearCookies();
  }
  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}) {
    Map<String,dynamic> attrs = getAttributes(node);
    return IWebViewWidget(node,jsRuntime,attrs,styleSheet:styleSheet);
  }
  
}

class IWebViewWidget extends StatefulWidget{
	final dom.Element node;
  final JsRuntime jsRuntime;
  final Map<String,dynamic> attrs;
  final TStyleSheet? styleSheet;
  
	// ignore: prefer_const_constructors_in_immutables
	IWebViewWidget(this.node,this.jsRuntime,this.attrs,{
    Key? key,
    this.styleSheet
  }):super(key:key);

	@override
	_IWebViewWidgetState createState() => _IWebViewWidgetState();
}

class _IWebViewWidgetState extends State<IWebViewWidget> with AutomaticKeepAliveClientMixin{

	WebViewController? webview;
	String? widgetUrl;
	
  dynamic onLoadingWidget;
  
  String? title;
	bool? canBack;
	bool? canForward;
  bool isDebug = false;
  Map<String,String> headers = {};
	Map<String,dynamic>? attrs;
  String? prevUrl;
  String pageStatus = "onCreate";

  String? initJsCode;
  String? initCss;
  String? webviewName;
  bool isReady = false;

  // 错误信息
  bool hasError = false;
  dynamic errors;

  var _readyCheckTimer;
  bool hasBinding = false;

  @override
  bool get wantKeepAlive => true;

	@override
	initState(){
		attrs = widget.attrs;

    webviewName = attrs!["name"];
    canBack = false;
		canForward = false;

    bool surfaceOn = attrs!.containsKey("surfaceOn")?attrs!['surfaceOn']=="false"?false:true:true;
    
    isDebug = attrs!.containsKey("isDebug")?StyleParse.bool(attrs!["isDebug"]):(const bool.fromEnvironment('dart.vm.product')?false:true);

    widgetUrl = attrs!["url"];

    if(attrs!.containsKey("headers") && attrs!['headers'].isNotEmpty && StyleParse.convertAttr(attrs!['headers']) is Map){
      var _headers = StyleParse.convertAttr(attrs!['headers']);
      _headers.forEach((k,v){
        headers[k] = v;
      });
    }

    // 事件监听
    if(webviewName!=null && !hasBinding){
      widget.jsRuntime.addWidgetMessageHandle("WebView", webviewName!, _handelWidgetEvent);
      // 页面渲染完成后执行
      var widgetsBinding = WidgetsBinding.instance;
      widgetsBinding.addPostFrameCallback((callback)async{
          if(!hasBinding &&  !widget.jsRuntime.onDispose ){
            hasBinding =  true;
            widget.jsRuntime.resolveWidgetReady("WebView", webviewName!);
          }
      });
    }
    // 解决键盘问题
    if (Platform.isAndroid && attrs!=null && surfaceOn ){
      WebView.platform = SurfaceAndroidWebView();
    } 

		super.initState();
	}

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
  }

	@override
	dispose(){
		super.dispose();
	}

  // 处理组件事件
  _handelWidgetEvent(params)async{
    if(params is Map && params["method"]!=null){
      var method = params["method"];
      var data = params["data"];
      switch(method){
        case "clearCookies":
          CookieManager().clearCookies();
          return true;
        case "eval":
          return await webview!.runJavascript(data);
        case "goBack":
          if(await webview!.canGoBack()){
            webview!.goBack();
            return true;
          }
          return false;
        case "goForward":
          if(await webview!.canGoForward()){
            webview!.goForward();
            return true;
          }
          return false;
        case "reload":
          webview!.reload();
          return true;
        case "canGoForward":
          return webview!.canGoForward();
        case "canGoBack":
          return webview!.canGoBack();
        case "getTitle":
          return await webview!.getTitle();
        case "getScrollX":
          return await webview!.getScrollX();
        case "getScrollY":
          return await webview!.getScrollY();
        case "currentUrl":
          return await webview!.currentUrl();
        case "scrollTo":
          return await webview!.scrollTo(data["x"], data["y"]);
        case "loadUrl":
          return await webview!.loadUrl(data);
        case "clearCache":
          return await webview!.clearCache();
        
      }
    }
  }
  
  resolveJsWebViewListen(){
    if(webviewName!=null){
      try{
        var message = {
          "status":pageStatus,
          "url":widgetUrl,
          "prevUrl":prevUrl,
          "error":errors,
          "title":title,
          "canGoBack":canBack,
          "canGoForward":canForward
        };
        
        String code = '!(function(){ var webview = T.getWebView("'+webviewName!+'"); if(webview){webview.resolveListeners('+json.encode(message)+');} })();';
        widget.jsRuntime.evaluate(code);
      }catch(e){
        print(e);
      }
    }
  }

	@override
	Widget build(BuildContext context) {
    super.build(context);
    return WebView(
          onWebViewCreated: (controller) async{
            webview = controller;
            if(attrs!.containsKey("cache") && attrs!['cache']=="false"){
              webview!.clearCache();
            }
            if(widgetUrl!=null){
              // 判断url类型
              if(widgetUrl!.startsWith("assets://")){
                var url = widgetUrl!.replaceAll("assets://", "");
                var data = await rootBundle.loadString(url);
                if(data.isNotEmpty){
                  loadData(data,headers: headers);
                }
              }else if(widgetUrl!.startsWith("file://")){
                //todo open file data
                File file = File(widgetUrl!.replaceAll("file://", ""));
                if(file.existsSync()){
                  var data = file.readAsBytesSync();
                  if(data.isNotEmpty){
                    webview!.loadUrl(Uri.dataFromBytes(data).toString(),headers: headers);
                  }
                }
              }else{
                webview!.loadUrl(widgetUrl!,headers:headers);
              }
            }
            resolveJsWebViewListen();
          },
          javascriptMode: attrs!['js-disabled']=="true"? JavascriptMode.disabled : JavascriptMode.unrestricted,
          userAgent: attrs!['user-agent']!=null && attrs!['user-agent'].isNotEmpty?attrs!['user-agent']:null,
          onPageStarted: ( String url) async{
            // print(url);
            errors = null;
            isReady = false;
            _readyCheckTimer = null;
            debugPrint("[Webview] onloadUrl\t$url");
            prevUrl = widgetUrl.toString();
            widgetUrl = url;

            canBack = await webview!.canGoBack();
            canForward = await webview!.canGoForward();
            title = null;

            pageStatus = "onLoadStart";
            resolveJsWebViewListen();

            _checkLoadReady();

          },
          javascriptChannels:<JavascriptChannel>{
            _tunaChannel(context)
          },
          navigationDelegate:(NavigationRequest request)async{
            if(webviewName!=null){
              var ret = await widget.jsRuntime.evaluate('(function(){ var r = T.getWebView("'+webviewName!+'"); if(r){ return r.navigationDelegate('+json.encode({"url":request.url,"isHome":request.isForMainFrame})+'); }else{return true;}  })();');
              if(ret!=null && ret.string.isNotEmpty  && ret.string=="false") {
                pageStatus = "onLoadPrevent";
                resolveJsWebViewListen();
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
          onPageFinished:(String url) async{
            isReady = true;
            widgetUrl = url;
            debugPrint("[Webview] onLoadFinish\t$url");

            try{
              title = await webview!.getTitle();
              canBack = await webview!.canGoBack();
              canForward = await webview!.canGoForward();
            }catch(e){
              debugPrint(e.toString());
            }
            pageStatus = "onLoadFinish";
            resolveJsWebViewListen();
          },

          debuggingEnabled:isDebug,
          
          initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
          onWebResourceError:(WebResourceError error)async{
            debugPrint("出错了！");
            debugPrint(error.errorCode.toString());
            debugPrint(error.description );
            // 直接调缓存时情况
            if(error.errorCode.toString()=="-999"){
              isReady = true;
              title = await webview!.getTitle();
              canBack = await webview!.canGoBack();
              canForward = await webview!.canGoForward();
              widgetUrl = await webview!.currentUrl();
              pageStatus = "onLoadFinish";
              resolveJsWebViewListen();
            }else{
              isReady = true;
              errors = {
                "type":"onLoadError",
                "url":widgetUrl,
                "code":error.errorCode.toString(),
                "message":error.description.toString(),
                "domain":error.domain.toString()
              };
              pageStatus = "onLoadError";
              resolveJsWebViewListen();
            }
          },
        );
	}

  // 使用是否可以往webview 发送消息来判断页面是否已经 domeReady
  _checkLoadReady(){
    if(!isReady){
      _readyCheckTimer = Timer.periodic(const Duration(milliseconds: 100), (timer){
        try{
          if(pageStatus=="onLoadStart" ){
            webview!.runJavascript('!(function(){try{ if(document && tunaJs ){  tunaJs.postMessage("TunaWebViewReadyStatusCheck.isReady"); } }catch(e){};})();');
          }else if(_readyCheckTimer!=null){
            _readyCheckTimer.cancel();
          }
        }catch(e){}
      });
    }else if(_readyCheckTimer!=null){
      _readyCheckTimer.cancel();
    }
    
  }

  // 直接加载html源码
  loadData(String code,
      {
        Map<String, String>? headers,
        String mimeType = 'text/html',
        Encoding? encoding,
        Map<String, String>? parameters,
        bool base64 = false
      }
    ) {
    return webview!.loadUrl(
        Uri.dataFromString(code,
                base64: base64,
                parameters: parameters,
                mimeType: mimeType,
                encoding: encoding ?? Encoding.getByName('utf-8'))
            .toString(),
        headers: headers);
  }

  // JavascriptChannel _postChannel(BuildContext context){
  //   return JavascriptChannel(name: "dataPost",onMessageReceived: (JavascriptMessage msgObj)async{
  //     var message = msgObj.message;
  //     // data:video/webm;base64,
  //     var regExp = RegExp(r"^data:([^;]+);base64,");
  //     if(regExp.hasMatch(message)){
  //       var mimeType = regExp.allMatches(message);
  //       if(mimeType!=null && mimeType.first!=null){
  //         var ftype = mimeType.first.group(1);
  //         Uint8List bytes = base64Decode(message.replaceAll(regExp, ""));
  //       }
  //     }
  //   });
  // }

  JavascriptChannel _tunaChannel(BuildContext context){
    return JavascriptChannel(
      name:"tunaJs",
      onMessageReceived:(JavascriptMessage message)async{

        if(webviewName==null){
          return;
        }

        dynamic msg = message.message;
        dynamic msgName;
        dynamic msgData;
       
        // webview is Ready
        if(msg=="TunaWebViewReadyStatusCheck.isReady"){
          if(!isReady){
            debugPrint("[Webview] onDomReady");
            isReady = true;
          
            if(_readyCheckTimer!=null){
              _readyCheckTimer.cancel();
            }
            // 开始解析dom了
            pageStatus  = "onDomReady";
            // Future.delayed(Duration(milliseconds: 150),()async{  
            title = await webview!.getTitle();
            canBack = await webview!.canGoBack();
            canForward = await webview!.canGoForward();
            resolveJsWebViewListen();
            // });
          }
          return;
        }
        

        if(msg is String){
          try{
            msgData = json.decode(msg);
          }catch(e){
            msgName = msg;
          }
        }
        // 处理blob数据传输
        if(msgData is Map 
          && msgData['name']=="BlobDataTrans" 
          && msgData['data']!=null 
          && msgData['data'].isNotEmpty
        ){
          var appDocPath = Tuna3.appDocPath;
          var tempBlobFile = appDocPath+"/_webview_blob_";
          var regExp = RegExp(r"^data:([^;]+);base64,");
          if(regExp.hasMatch(msgData['data'])){
            dynamic mimeType = regExp.allMatches(msgData['data']);
            
            if(mimeType!=null && mimeType.first!=null){
              var ftype = mimeType.first.group(1);
              Uint8List bytes = base64Decode(msgData['data'].replaceAll(regExp, ""));
              if(msgData['fileName']!=null){
                tempBlobFile += msgData['fileName']+"."+ftype!.replaceAll("/", ".");
              }else{
                tempBlobFile += "tempfile."+ftype!.replaceAll("/", ".");
              }
              File file = File(tempBlobFile);
              file.writeAsBytesSync(bytes);
              msgData['data'] = tempBlobFile;
            }
          }
        }
    
        if(msgData !=null && msgData is Map && msgData.containsKey("name")){
          msgName = msgData['name'];
          msgData = msgData["data"];
        }
       

        if(msgName!=null){
          Map retMap = {
            "data":msgData,
            "name":msgName,
            "currentUrl":widgetUrl,
            "prevUrl":prevUrl
          };
          widget.jsRuntime.evaluate('!(function(){ var r = T.getWebView("'+webviewName!+'");if(r){r.resolveJsMessage('+json.encode(retMap)+');} })();');
        }
        
      }
    );
  }
}

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:easy_refresh/easy_refresh.dart';
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/utils/style_parse.dart';

import 'icon.dart';
import '../../js_runtime.dart';
import '../../style_sheet.dart';
import '../widget.dart';


class TWidgetRefresh  extends TWidget{
  
  TWidgetRefresh():super(tagName: 'refresh');

  @override
  parse(dom.Element node, JsRuntime jsRuntime, {TStyleSheet? styleSheet}){

    Map<String,dynamic>? attrs = getAttributes(node);
    // ignore: prefer_typing_uninitialized_variables
    var header;
    // ignore: prefer_typing_uninitialized_variables
    var footer;
    
    List<Widget> children = [];
    node.children.forEach((item) {
      children.add(Tuna3.parseWidget(item,jsRuntime,styleSheet:styleSheet));
    });

    if(attrs.containsKey("refreshStyle")){
      var refreshStyle = attrs['refreshStyle'];
      var bgColor = attrs.containsKey("backgroundColor")?StyleParse.hexColor(attrs["backgroundColor"]):Colors.transparent;
      var color = attrs.containsKey("color")?StyleParse.hexColor(attrs["color"]):Colors.blue;

      if(refreshStyle=="bezier"){
        header = BezierHeader(
          backgroundColor: bgColor,
          foregroundColor: color
        );
        footer = BezierFooter(backgroundColor: bgColor,foregroundColor: color);
      }else if(refreshStyle=="bezierCircle"){
        header = BezierCircleHeader(backgroundColor: bgColor,foregroundColor: color);
        footer = BezierFooter(backgroundColor: bgColor,foregroundColor: color);
      }else if(refreshStyle=="phoenix"){
        header = PhoenixHeader(skyColor:color);
        footer = PhoenixFooter(skyColor:color);
      }else if(refreshStyle=="taurus"){
        header = TaurusHeader(skyColor: bgColor);
        footer = TaurusFooter(skyColor: bgColor);
      }else if(refreshStyle=="delivery"){
        header = DeliveryHeader(skyColor: bgColor);
      }else if(refreshStyle=="Cupertino"){
        header = CupertinoHeader(backgroundColor: bgColor,foregroundColor: color);
      }else if(refreshStyle=="Material") {
        header = MaterialHeader(backgroundColor: bgColor);
      } 
    }
    
    // 获取默认样式
    header ??= _getDefaultHeader(attrs);
    footer ??= _getDefaultFooter(attrs);

    EasyRefreshController? controller;
    // ScrollController? scrollController;

    var widgetName = attrs["name"];
    

    if(widgetName!=null){

      controller = EasyRefreshController(controlFinishRefresh:true,controlFinishLoad:false);
      // scrollController = ScrollController(initialScrollOffset:0.0,keepScrollOffset:true);

      // 事件监听
      jsRuntime.addJavascriptMessageHandle("TunaRefreshEvent."+widgetName, (params){
        if(params is Map && params.containsKey("method")){
          dynamic method = params["method"];
          dynamic data = params["data"];
          switch(method){
            case "finishLoad":
              bool success = data!=null && data.containsKey('success') && data["success"] is bool?data['success']:true;
              controller!.finishLoad(success?IndicatorResult.success:IndicatorResult.fail);
              return true;
            case "finishRefresh":
              bool success = data!=null && data.containsKey('success') && data["success"] is bool?data['success']:true;
              bool noMore = data!=null && data.containsKey('noMore') && data["noMore"] is bool?data['noMore']:false;
              
              IndicatorResult result  =  IndicatorResult.success;
              if(noMore){
                result = IndicatorResult.noMore;
              }else if(success==false){
                result = IndicatorResult.fail;
              }
              controller!.finishRefresh(result);
              return true;
            // case "resetLoadState":
            //   controller!();
            //   return true;
            // case "resetRefreshState":
            //   controller!.resetRefreshState();
            //   return true;
            case "resetFooter":
              controller!.resetFooter();
              // print("resetFooter");
              return true;
            case "resetHeader":
              controller!.resetHeader();
              return true;
            case "refresh":
              controller!.callRefresh(duration: const Duration(milliseconds: 120));
              return true;
            case "load":
              controller!.callLoad(duration: const Duration(milliseconds: 120));
              return true;
            // case "jumpTo":
            //   if(scrollController!=null && data!=null){
            //     scrollController.jumpTo(double.parse(data.toString()));
            //   }
            //   return true;
            // case "animateTo":
            //   if(scrollController!=null && data!=null){
            //     if(data is String || data is int || data is double){
            //       scrollController.animateTo(double.parse(data.toString()), duration: const Duration(milliseconds: 250), curve: Curves.linear);
            //     }else if(data is Map && data.containsKey("offset")){
            //       var offset = double.parse(data["offset"].toString());
            //       var duration = data.containsKey("duration")?Duration(milliseconds: data['duration']):const Duration(milliseconds: 250);
            //       var curve = data.containsKey("curve")?AnimateParse.curve(data["curve"]):Curves.linear;
            //       scrollController.animateTo(offset, duration: duration, curve: curve);
            //     }
            //     return true;
            //   }
            //   return false;
            // case "position":
            //   if(scrollController!=null){
            //     ScrollPosition pos =  scrollController.position;
            //     return {
            //       "pixes":pos.pixels,
            //       "max":pos.maxScrollExtent,
            //       "min":pos.minScrollExtent
            //     };
            //   }
            //   return null;
            // case "listen":
            //   if(scrollController!=null){
            //     scrollController.addListener(() { 
            //       var code = 'T.getRefresh("'+widgetName+'").resolveScrollListen();';
            //       jsRuntime.evaluate(code);
            //     });
            //   }
            //   return true;
            // case "offset":
            //   if(scrollController!=null){
            //     return scrollController.offset;
            //   }
            //   return null;
          }
        }
      });
    }

    String onRefreshJsCode = '!(function(){var r = T.getRefresh("'+widgetName+'");if(r.onRefresh){r.onRefresh();}else{r.finishRefresh();}})();';
    String onLoadJsCode = '!(function(){var r = T.getRefresh("'+widgetName+'"); if(r.onLoad){ return r.onLoad();}else{ return r.finishLoad()}})();';
    NotRefreshHeader notRefreshHeader = const NotRefreshHeader();
    NotLoadFooter notLoadFooter = const NotLoadFooter();

    return EasyRefresh(
      // childBuilder:(context, physics){
      //   return children[0];
      // },
      // controlFinishRefresh:true,
      child:children[0],
      header: header,
      footer: footer,
      controller: controller,
      notRefreshHeader:notRefreshHeader,
      notLoadFooter:notLoadFooter,
      simultaneously : false,
      noMoreRefresh : false,
      noMoreLoad : false,
      resetAfterRefresh : true,
      refreshOnStart : false,
      refreshOnStartHeader:null,
      callRefreshOverOffset : 20,
      callLoadOverOffset : 20,
      fit : StackFit.loose,
      clipBehavior : Clip.hardEdge,
      // enableControlFinishRefresh:enableFinishRefresh,
      // enableControlFinishLoad: enableFinishLoad,
      // headerIndex:headerIndex,
      // firstRefresh:firstRefresh,
      // firstRefreshWidget: firstRefreshWidget,
      // emptyWidget:emptyWidget,
      // scrollController:scrollController,
      onRefresh:attrs["noRefresh"]=="true"?null:(){
        // print("today is refresh!");
        jsRuntime.evaluate(onRefreshJsCode);
        return IndicatorResult.success;
      } ,
      onLoad: attrs["noLoad"]=="true"?null:(){
        jsRuntime.evaluate(onLoadJsCode);
        return IndicatorResult.success;
      },
    );
  }

  _getDefaultHeader(attrs){
    var dragText = attrs['dragText'] ?? "下拉刷新";
    var readyText = attrs['readyText'] ?? "释放立即刷新";
    var armedText = attrs['armedText'] ?? "加载中...";
    var processingText = attrs['processingText'] ?? "正在加载";
    var processedText = attrs['processedText'] ?? "加载成功";
    var failedText = attrs['failedText'] ?? "刷新失败";
    var messageText = attrs['messageText'] ?? "上次更新于 %T";
    var noMoreText = attrs['noMoreText'] ?? "已全部加载";
    var bgColor = attrs.containsKey("backgroundColor")?StyleParse.hexColor(attrs["backgroundColor"]):Colors.transparent;
      
    // AlignmentGeometry align = attrs['align'] !=null?StyleParse.alignment(attrs['align']):Alignment.center;
    var triggerDistance = attrs['distance'] !=null?double.parse(attrs['distance']):75.0;
    double? textDimension = attrs['textDimension']!=null?double.parse(attrs['textDimension']):null;
    double? progressIndicatorSize = attrs['progressIndicatorSize']!=null?double.parse(attrs['progressIndicatorSize']):null;
    double? progressIndicatorStrokeWidth = attrs['progressStrokeWidth']!=null?double.parse(attrs['progressStrokeWidth']):null;

    int processedDuration = attrs['processedDuration']!=null ? int.parse(attrs['processedDuration']):100;

    Icon? succeededIcon = attrs['succeededIcon']!=null? TWidgetIcon.parseIconName(attrs['succeededIcon']):null;
    Icon? failedIcon = attrs['failedIcon']!=null? TWidgetIcon.parseIconName(attrs['failedIcon']):null;
    Icon? noMoreIcon = attrs['noMoreIcon']!=null? TWidgetIcon.parseIconName(attrs['noMoreIcon']):null;
    // Icon? failedIcon = attrs['failedIcon']!=null? TWidgetIcon.parseIconName(attrs['failedIcon']):null;
    IconThemeData? iconTheme;
    if(attrs['iconTheme']!=null){
      iconTheme = StyleParse.iconThemeData(StyleParse.convertAttr(attrs['iconTheme']));
      // Map<String,dynamic> themeMap = StyleParse.convertAttr(attrs['iconTheme']);
      // iconTheme = IconThemeData(
      //   color: themeMap.containsKey("color")? StyleParse.hexColor(themeMap['color']): null,
      //   shadows: themeMap.containsKey("shadows")?StyleParse.shadow(themeMap['shadows']):null,
      //   size: themeMap.containsKey("size")?double.parse(themeMap['size']):null
      // );
    }
    TextStyle? textStyle;
    if(attrs['textStyle']!=null){
      textStyle = StyleParse.textStyle( StyleParse.convertAttr(attrs['textStyle']));
    }
    TextStyle? messageStyle;
    if(attrs['messageStyle']!=null){
      messageStyle = StyleParse.textStyle(StyleParse.convertAttr(attrs['messageStyle']));
    }

    // double triggerOffset = 70,
    // bool clamping = false,
    // IndicatorPosition position = IndicatorPosition.above,
    // Duration processedDuration = const Duration(seconds: 1),
    // SpringDescription? spring,
    // SpringBuilder? readySpringBuilder,
    // bool springRebound = true,
    // FrictionFactor? frictionFactor,
    // bool safeArea = true,
    // double? infiniteOffset,
    // bool? hitOver,
    // bool? infiniteHitOver,
    // bool hapticFeedback = false,
    // bool triggerWhenReach = false,
    // this.mainAxisAlignment = MainAxisAlignment.center,
    // this.backgroundColor,
    // this.dragText,
    // this.armedText,
    // this.readyText,
    // this.processingText,
    // this.processedText,
    // this.noMoreText,
    // this.failedText,
    // this.showText = true,
    // this.messageText,
    // this.showMessage = true,
    // this.textDimension,
    // this.iconDimension = 24,
    // this.spacing = 16,
    // this.succeededIcon,
    // this.failedIcon,
    // this.noMoreIcon,
    // this.pullIconBuilder,
    // this.textStyle,
    // this.textBuilder,
    // this.messageStyle,
    // this.messageBuilder,
    // this.clipBehavior = Clip.hardEdge,
    // this.iconTheme,
    // this.progressIndicatorSize,
    // this.progressIndicatorStrokeWidth

    return ClassicHeader(
      triggerOffset: triggerDistance,
      backgroundColor:bgColor,
      // position: position,
      processedDuration: Duration(milliseconds: processedDuration),
      dragText:dragText,
      armedText:armedText,
      readyText:readyText,
      processingText:processingText,
      processedText:processedText,
      noMoreText:noMoreText,
      failedText:failedText,
      showText : true,
      messageText:messageText,
      showMessage : true,
      textDimension:textDimension,
      iconDimension : 24,
      spacing : 16,
      succeededIcon:succeededIcon,
      failedIcon:failedIcon,
      noMoreIcon:noMoreIcon,
      // pullIconBuilder,
      textStyle:textStyle,
      // textBuilder,
      messageStyle:messageStyle,
      // messageBuilder,
      // clipBehavior = Clip.hardEdge,
      iconTheme:iconTheme,
      progressIndicatorSize:progressIndicatorSize,
      progressIndicatorStrokeWidth:progressIndicatorStrokeWidth
    );
  }
  _getDefaultFooter(attrs){

    var dragText = attrs['ftDragText'] ?? "上拉加载更多";
    var readyText = attrs['ftReadyText'] ?? "释放立即加载";
    var armedText = attrs['ftArmedText'] ?? "加载中...";
    var processingText = attrs['ftProcessingText'] ?? "正在加载";
    var processedText = attrs['ftProcessedText'] ?? "加载成功";
    var failedText = attrs['ftFailedText'] ?? "刷新失败";
    var messageText = attrs['ftFmessageText'] ?? "上次更新于 %T";
    var noMoreText = attrs['noMoreText'] ?? "没有更多了";
    var bgColor = attrs.containsKey("ftBgColor")?StyleParse.hexColor(attrs["ftBgColor"]):null;
      
    // AlignmentGeometry align = attrs['align'] !=null?StyleParse.alignment(attrs['align']):Alignment.center;
    var triggerDistance = attrs['distance'] !=null?double.parse(attrs['distance']):74.0;
    double? textDimension = attrs['textDimension']!=null?double.parse(attrs['textDimension']):null;
    double? progressIndicatorSize = attrs['progressIndicatorSize']!=null?double.parse(attrs['progressIndicatorSize']):null;
    double? progressIndicatorStrokeWidth = attrs['progressStrokeWidth']!=null?double.parse(attrs['progressStrokeWidth']):null;

    int processedDuration = attrs['processedDuration']!=null ? int.parse(attrs['processedDuration']):100;

    Icon? succeededIcon = attrs['succeededIcon']!=null? TWidgetIcon.parseIconName(attrs['succeededIcon']):null;
    Icon? failedIcon = attrs['failedIcon']!=null? TWidgetIcon.parseIconName(attrs['failedIcon']):null;
    Icon? noMoreIcon = attrs['noMoreIcon']!=null? TWidgetIcon.parseIconName(attrs['noMoreIcon']):null;
    // Icon? failedIcon = attrs['failedIcon']!=null? TWidgetIcon.parseIconName(attrs['failedIcon']):null;
    IconThemeData? iconTheme;
    if(attrs['ftIconTheme']!=null){
      iconTheme = StyleParse.iconThemeData(StyleParse.convertAttr(attrs['ftIconTheme']));
      // Map<String,dynamic> themeMap = StyleParse.convertAttr(attrs['iconTheme']);
      // iconTheme = IconThemeData(
      //   color: themeMap.containsKey("color")? StyleParse.hexColor(themeMap['color']): null,
      //   shadows: themeMap.containsKey("shadows")?StyleParse.shadow(themeMap['shadows']):null,
      //   size: themeMap.containsKey("size")?double.parse(themeMap['size']):null
      // );
    }
    TextStyle? textStyle;
    if(attrs['ftTextStyle']!=null){
      textStyle = StyleParse.textStyle(StyleParse.convertAttr(attrs['ftTextStyle']));
    }
    TextStyle? messageStyle;
    if(attrs['ftMessageStyle']!=null){
      messageStyle = StyleParse.textStyle(StyleParse.convertAttr(attrs['ftMessageStyle']));
    }

    
    // AlignmentGeometry align = attrs['align'] !=null?StyleParse.alignment(attrs['align']):Alignment.center;
    return ClassicFooter(
      triggerOffset: triggerDistance,
      processedDuration: Duration(milliseconds: processedDuration),
      backgroundColor: bgColor,
      dragText:dragText,
      armedText:armedText,
      readyText:readyText,
      processingText:processingText,
      processedText:processedText,
      noMoreText:noMoreText,
      failedText:failedText,
      showText : true,
      messageText:messageText,
      showMessage : true,
      textDimension:textDimension,
      iconDimension : 24,
      spacing : 16,
      succeededIcon:succeededIcon,
      failedIcon:failedIcon,
      noMoreIcon:noMoreIcon,
      // pullIconBuilder,
      textStyle:textStyle,
      // textBuilder,
      messageStyle:messageStyle,
      // messageBuilder,
      // clipBehavior = Clip.hardEdge,
      iconTheme:iconTheme,
      progressIndicatorSize:progressIndicatorSize,
      progressIndicatorStrokeWidth:progressIndicatorStrokeWidth,
    );
  }
}

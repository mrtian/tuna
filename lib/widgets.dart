// import 'package:flutter/material.dart';
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/utils/style_parse.dart';
import 'package:tuna3/widgets/widgets/custom_scroll.dart';
import 'package:tuna3/widgets/widgets/list_more.dart';
import 'package:tuna3/widgets/widgets/refresh_notification.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/widgets/widgets/animator.dart';
import 'package:tuna3/widgets/widgets/bottom_navigation_bar.dart';
import 'package:tuna3/widgets/widgets/button.dart';
import 'package:tuna3/widgets/widgets/center.dart';
import 'package:tuna3/widgets/widgets/chip.dart';
import 'package:tuna3/widgets/widgets/card.dart';
import 'package:tuna3/widgets/widgets/column.dart';
import 'package:tuna3/widgets/widgets/container.dart';
import 'package:tuna3/widgets/widgets/cupertino_controls.dart';
import 'package:tuna3/widgets/widgets/custom_clip.dart';
import 'package:tuna3/widgets/widgets/divider.dart';
import 'package:tuna3/widgets/widgets/expanded.dart';
import 'package:tuna3/widgets/widgets/form.dart';
import 'package:tuna3/widgets/widgets/icon.dart';
import 'package:tuna3/widgets/widgets/image.dart';
import 'package:tuna3/widgets/widgets/indexed_stack.dart';
import 'package:tuna3/widgets/widgets/js_template.dart';
import 'package:tuna3/widgets/widgets/list_view.dart';
import 'package:tuna3/widgets/widgets/listener.dart';
import 'package:tuna3/widgets/widgets/meterial.dart';
import 'package:tuna3/widgets/widgets/offstage.dart';
import 'package:tuna3/widgets/widgets/padding.dart';
import 'package:tuna3/widgets/widgets/page.dart';
import 'package:tuna3/widgets/widgets/preferred_size.dart';
import 'package:tuna3/widgets/widgets/refresh.dart';
import 'package:tuna3/widgets/widgets/repaint.dart';
// import 'package:tuna3/widgets/widgets/richText.dart';
import 'package:tuna3/widgets/widgets/row.dart';
import 'package:tuna3/widgets/widgets/safe_area.dart';
import 'package:tuna3/widgets/widgets/scroll.dart';
import 'package:tuna3/widgets/widgets/sign_pad.dart';
import 'package:tuna3/widgets/widgets/size.dart';
import 'package:tuna3/widgets/widgets/slivers.dart';
import 'package:tuna3/widgets/widgets/spinkit.dart';
import 'package:tuna3/widgets/widgets/stack.dart';
import 'package:tuna3/widgets/widgets/swiper.dart';
import 'package:tuna3/widgets/widgets/tab.dart';
import 'package:tuna3/widgets/widgets/table.dart';
import 'package:tuna3/widgets/widgets/text.dart';
import 'package:tuna3/widgets/widgets/webview.dart';
import 'package:tuna3/widgets/widgets/wrap.dart';

import 'widgets/widget.dart';
import 'package:html/dom.dart' as dom;

import 'widgets/widgets/appbar.dart';

class TWidgets{

  static Map<String,dynamic> tagParsers = {};
  static regWidget(dynamic tags,TWidget widget){
    if(tags is String){
      tagParsers[tags.toLowerCase()] = widget;
    }else if (tags is List){
      for(var i=0;i<tags.length;i++){
        tagParsers[tags[i].toLowerCase()] = widget;
      }
    }
  }

  TWidgets(){
    // appbar
    TWidgetAppBar();
    // IndexedStack
    TWidgetIndexedStack();
    TWidgetAnimator();
    TWidgetBottomNavigationBar();
    TWidgetButton();
    

    TWidgetCenter();
    TWidgetChip();
    TWidgetCard();
    // TWidgetCodeText();
    TWidgetColumn();
    TWidgetContainer();
    TWidgetCupertinoSwitch();
    TWidgetClipPath();
    TWidgetCustomScroll();

    TWidgetDivider();
    
    TWidgetExpanded();

    TWidgetIcon();
    TWidgetImage();
    TWidgetIndexedStack();
    TWidgetInput();
    TWidgetJsTemplate();
    TWidgetListView();
    TWidgetListMore();
    TWidgetListener();

    TWidgetMeterial();
    TWidgetOffstage();
    
    TWidgetPadding();
    TWidgetPage();
    TWidgetPositioned();
    TWidgetPreferredSize();

    TWidgetRefresh();
    TWidgetRefreshNotification();
    TWidgetRefreshContainer();
    TWidgetRepaint();
    // TWidgetRichText();
    TWidgetRow();

    TWidgetSafeArea();
    TWidgetScrollView();
    TWidgetSliverPadding();
    TWidgetSpinKit();
    TWidgetStack();
    TWidgetSwiper();
    TWidgetSignPad();
    TWidgetSize();

    TWidgetTabBar();
    TWidgetTabView();
    TWidgetTable();
    TWidgetText();

    TWidgetWebview();
    TWidgetWrap();

  }

  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}){
    
    var tagName = node.localName!.toLowerCase();
    if(tagParsers.containsKey(tagName)){
      TWidget parser = tagParsers[tagName];
      var ret =  parser.parse(node,jsRuntime,styleSheet:styleSheet);
      Map<String,dynamic> attrs = parser.getAttributes(node);

      if(attrs.containsKey("VISITOR") && attrs['VISITOR'] is Map && attrs['VISITOR'].containsKey("ON")){
        // print(attrs);
        var r = parseGuestureWidget(ret, attrs["VISITOR"]["ON"],jsRuntime,styleSheet:styleSheet);
        return r;
      }else if(attrs.containsKey("href") && attrs['href'].isNotEmpty){
        
        Map<String,dynamic> params = {};
        String href = attrs['href'];
        Uri uri = Uri.parse(href);
        params['params'] = uri.queryParameters;
        
        if(uri.scheme.isNotEmpty){
          params["HREF"] = href;
        }else{
          params['HREF'] = uri.path;
          params['isRoute'] = true;
        }

        if(attrs.containsKey("target")){
          if(attrs['target']=='launch'){
            params['LAUNCH'] = href;
          }
        }
        
        var r = parseGuestureWidget(ret, params,jsRuntime,styleSheet:styleSheet);
        return r;
      }
      return ret;
    }else{
      // ignore: avoid_unnecessary_containers
      // return Container(child:Text("Can't render "+tagName+" node."));
    }
  }

  parseGuestureWidget(Widget widget,Map<String,dynamic>map,JsRuntime jsRuntime,{TStyleSheet? styleSheet,bool hideKeyboard=false}){
    
    dynamic onTap;
    BuildContext? context = Get.context;
    
    if(map.containsKey("LAUNCH") && map['LAUNCH'].isNotEmpty){
      onTap = (){
        String launchVal = map['LAUNCH'];
        _launch() async{
          if(await canLaunch(launchVal)){
            if(Platform.isIOS && launchVal.startsWith("http")){
                await launch(launchVal,forceSafariVC:true);
            }else{
              await launch(launchVal);
            }
          }else{
            // Fluttertoast.showToast(msg:"无法打开链接$launchVal");
          }
        }
        _launch();
      };
    }else if(!map.containsKey("HREF") || map["HREF"].isEmpty){
     
     onTap = map.containsKey("tap") ?
          _parseVisitorOnValue("tap",map,context,jsRuntime:jsRuntime,hideKeyboard: hideKeyboard):null;
    }else{
      var target = map['target'];
      var options;
      if(target!=null && target.isNotEmpty){
        options = StyleParse.convertAttr(target);
      }
      onTap = (){
        // 执行点击事件
        if(map.containsKey("tap")){
          var ret = _parseVisitorOnValue("tap",map,context,jsRuntime:jsRuntime,hideKeyboard: hideKeyboard)();
         
          if(ret==false){
            return;
          }
        }
        // 打开页面
        if(map.containsKey("isRoute") && map['isRoute']){
          if(options!=null){
            jsRuntime.evaluate('T.openPageByName("'+map['HREF']+'",'+json.encode(map["params"])+',null,'+json.encode(options)+');');
          }else{
            jsRuntime.evaluate('T.openPageByName("'+map['HREF']+'",'+json.encode(map["params"])+');');
          }
        }else{
          if(options!=null){
            jsRuntime.evaluate('T.openPage("'+map['HREF']+'",'+json.encode(map["params"])+',null,null,'+json.encode(options)+');');
          }else{
            jsRuntime.evaluate('T.openPage("'+map['HREF']+'",'+json.encode(map["params"])+');');
          }
        }
        
      };
    }
    
    createGestureDetector(context){
      if(map['onHighlightColor']!=null){
        var color = StyleParse.hexColor(map['onHighlightColor']);
        return InkWell(
          onTapDown:map.containsKey("tapDown")?
          (detail){
            _parseVisitorOnValue("tapDown",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				  onTap:onTap,
				  onTapCancel:map.containsKey("tapCancel")?
            _parseVisitorOnValue("tapCancel",map,context,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard):null,
          // splashColor: color,
          borderRadius: const BorderRadius.all(Radius.circular(0)),
          // splashColor: color,
          // splashFactory: InteractiveInkFeatureFactory(),
          hoverColor: color,
          highlightColor: color,
          // onHighlightChanged: ,
          child: widget,
        );
      }

			return GestureDetector(
				// key:map.containsKey(XMLKeys.key)?map[XMLKeys.key]:null,
				child: widget,
				onTapDown:map.containsKey("tapDown")?
          (detail){
            _parseVisitorOnValue("tapDown",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onTapUp:map.containsKey("tapUp")?
          (detail){
            _parseVisitorOnValue("tapUp",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onTap:onTap,
				onTapCancel:map.containsKey("tapCancel")?
          _parseVisitorOnValue("tapCancel",map,context,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard):null,
				onSecondaryTapDown:map.containsKey("econdaryTapDown")?
          (detail){
            _parseVisitorOnValue("econdaryTapDown",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onSecondaryTapUp:map.containsKey("secondaryTapUp")?
          (detail){
            _parseVisitorOnValue("secondaryTapUp",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onSecondaryTapCancel:map.containsKey("secondaryTapCancel")?
          _parseVisitorOnValue("secondaryTapCancel",map,context,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard):null,
				onDoubleTap:map.containsKey("doubleTap")?
          _parseVisitorOnValue("doubleTap",map,context,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard):null,
				onLongPress:map.containsKey("longPress")?
          _parseVisitorOnValue("longPress",map,context,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard):null,
				onLongPressStart:map.containsKey("longPressStart")?
          (detail){
            _parseVisitorOnValue("longPressStart",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onLongPressMoveUpdate:map.containsKey("longPressMoveUpdate")?
          (detail){
            _parseVisitorOnValue("longPressMoveUpdate",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onLongPressUp:map.containsKey("longPressUp")?
          _parseVisitorOnValue("longPressUp",map,context,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard):null,
				onLongPressEnd:map.containsKey("longPressEnd")?
          (detail){
            _parseVisitorOnValue("longPressEnd",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onVerticalDragDown:map.containsKey("verticalDragDown")?
          (detail){
            _parseVisitorOnValue("verticalDragDown",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onVerticalDragStart:map.containsKey("verticalDragStart")?
          (detail){
            _parseVisitorOnValue("verticalDragStart",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onVerticalDragUpdate:map.containsKey("verticalDragUpdate")?
          (detail){
            _parseVisitorOnValue("verticalDragUpdate",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onVerticalDragEnd:map.containsKey("verticalDragEnd")?
          (detail){
            _parseVisitorOnValue("verticalDragEnd",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onVerticalDragCancel:map.containsKey("verticalDragCancel")?
          _parseVisitorOnValue("verticalDragCancel",map,context,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard):null,
				onHorizontalDragDown:map.containsKey("horizontalDragDown")?
          (detail){
            _parseVisitorOnValue("horizontalDragDown",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onHorizontalDragStart:map.containsKey("horizontalDragStart")?
          (detail){
            _parseVisitorOnValue("horizontalDragStart",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onHorizontalDragUpdate:map.containsKey("orizontalDragUpdate")?
          (detail){
            _parseVisitorOnValue("orizontalDragUpdate",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onHorizontalDragEnd:map.containsKey("orizontalDragEnd")?
          (detail){
            _parseVisitorOnValue("orizontalDragEnd",map,context,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onHorizontalDragCancel:map.containsKey("orizontalDragCancel")?
         _parseVisitorOnValue("orizontalDragCancel",map,context,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard):null,
				onForcePressStart:map.containsKey("forcePressStart")?
          (detail){
            _parseVisitorOnValue("forcePressStart",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onForcePressPeak:map.containsKey("forcePressPeak")?
          (detail){
            _parseVisitorOnValue("forcePressPeak",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onForcePressUpdate:map.containsKey("forcePressUpdate")?
          (detail){
            _parseVisitorOnValue("forcePressUpdate",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onForcePressEnd:map.containsKey("forcePressEnd")?
          (detail){
            _parseVisitorOnValue("forcePressEnd",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onPanDown:map.containsKey("panDown")?
          (detail){
            _parseVisitorOnValue("panDown",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onPanStart:map.containsKey("panStart")?
          (detail){
            _parseVisitorOnValue("panStart",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onPanUpdate:map.containsKey("panUpdate")?
          (detail){
            _parseVisitorOnValue("panUpdate",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onPanEnd:map.containsKey("panEnd")?
          (detail){
            _parseVisitorOnValue("panEnd",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onPanCancel:map.containsKey("panCancel")?
          _parseVisitorOnValue("panCancel",map,context,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard):null,
				onScaleStart:map.containsKey("scaleStart")?
          (detail){
            _parseVisitorOnValue("scaleStart",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onScaleUpdate:map.containsKey("scaleUpdate")?
          (detail){
            _parseVisitorOnValue("scaleUpdate",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null,
				onScaleEnd:map.containsKey("scaleEnd")?
          (detail){
            _parseVisitorOnValue("scaleEnd",map,context,detail: detail,jsRuntime:jsRuntime,hideKeyboard:hideKeyboard);
          }:null
			);
		}

    return Builder(
				builder:createGestureDetector
    );
  }

  _parseVisitorOnValue(key,map,context,{detail,required JsRuntime jsRuntime,bool? hideKeyboard}){
    
		if(map.containsKey(key) && map[key]!=null){
      
      var params = StyleParse.convertAttr(map[key]);
      var callHandle;
      var args;
      bool isCanEval = false;
      bool isApply = false;

      // ignore: prefer_function_declarations_over_variables
      var _call = (){
        
        if(hideKeyboard!){
          FocusScope.of(context).requestFocus(FocusNode());
        }
        if(params is Map){
          callHandle = params["handle"];
          // params.remove("handle");
          args = Map.from(params);
          args.remove("handle");
          // print(args);
          if(args is Map && args.containsKey("arguments")){
            args = args['arguments'];
            isApply = true;
          }
        }else if(params is String && params.isNotEmpty){
          params = params.trim();
          if(params.endsWith(";") || params.endsWith(")")){
            isCanEval = true;
          }
          callHandle = params;
          args = null;
        }
        if(callHandle==null || callHandle=="false" || callHandle.isEmpty ){
          return;
        }
        
        try{
          if(callHandle!=null){
            if(isCanEval){
              jsRuntime.evaluate(callHandle);
            }else{
              dynamic code;
              // print(args);
              if(isApply){
                code = callHandle+".apply(this,"+args+")";
              }else{
                code = callHandle+'('+json.encode(args)+');';
              }
              jsRuntime.evaluate(code);
            }
          }
        }catch(e){
          print(callHandle);
          print(e);
        }
      };
      
      if(detail!=null){
        if(params is String){
          params = {
            "handle":params
          };
        }
        try{
          params["__positionDetail"] = {
            "global":{
              "dx":detail.globalPosition.dx,
              "dy":detail.globalPosition.dy
            },
            "local":{
              "dx":detail.localPosition.dx,
              "dy":detail.localPosition.dy
            }
          };
        }catch(e){
          print(e);
        }
        return _call();
      }
      return _call;
      
		}
	}

}
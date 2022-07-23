import 'dart:collection';

import 'package:flutter/material.dart';
import '../utils/style_parse.dart';
import 'package:styled_widget/styled_widget.dart';

class StyledWidgetParse{

  // 支持的样式
  static Map<String,dynamic> stylePropertys = {
    "padding":1,
    "opacity":1,
    "alignment":1,
    "background":1,
    "radius":1,
    "clipRRect":1,
    "clipOval":1,
    "border":1,
    "elevation":1,
    "shadow":1,
    "width":1,
    "height":1,
    "ripple":1,
    "rotate":1,
    "scale":1,
    "translate":1,
    "transform":1,
    "overflow":1,
    "scrollable":1
  };

  static Map<String,dynamic> gestures = {
    "tap":1,

  };

  // 解析样式，生成新的带有样式的widget
  static Widget parse(Widget widget,LinkedHashMap<Object, String>? attrs,Map<String,dynamic>? styles){

    if(attrs!=null && attrs.isEmpty || (styles==null || styles.isEmpty)){
      return widget;
    }

    bool hasMargin = false;
    dynamic margin;

    bool hasOpacity = false;
    dynamic opacityVal;

    // 解析style
    Widget _ret = widget;

    if(styles.isNotEmpty){

      if(styles.containsKey("margin")){
        hasMargin = true;
        margin = styles['margin'];
      }

      if(styles.containsKey("opacity")){
        hasOpacity = true;
        opacityVal = styles['opacity'];
      }
      // 解析样式
      _ret = parseStyle(widget,styles);
    }

    // decorated
    Widget _decoratedRet = _ret;
    if(attrs!=null && attrs.containsKey("decorated")){
      _decoratedRet = _parseDecorated(_ret,attrs["decorated"]);
    }
    
    Widget _opacityRet = _decoratedRet;
    if(hasOpacity){
      _opacityRet = _decoratedRet.opacity(double.parse(opacityVal));
    }
    
    // 外边距
    Widget _marginRet = _opacityRet;
    if(hasMargin){
      _marginRet =  _parsePadding(_opacityRet,margin);
    }

    return _marginRet;
    
  }


  static parseStyle(Widget ret,Map<String,dynamic>? styleMap,{debug=false}){
    
    // print(styleMap);
    if(styleMap!=null && styleMap.isEmpty){
      return ret;
    }
    // 内边距
    Widget? _paddingRet;
    if(styleMap!=null && styleMap.containsKey("padding")){
      _paddingRet = _parsePadding(ret,styleMap["padding"]);
    }else{
       _paddingRet = ret;
    }
    //  排列
    Widget? _alignRet;
    if(styleMap!=null &&  (styleMap.containsKey("items") || styleMap.containsKey("align"))){
      if(styleMap["align"] is Map && styleMap["align"].containsKey("items")){
        _alignRet = _paddingRet!.alignment(StyleParse.alignment(styleMap["align"]["items"]));
      }else{
        _alignRet = _paddingRet!.alignment(StyleParse.alignment(styleMap["alignment"]));
      }
      
    }else{
      _alignRet = _paddingRet;
    }


    // border 边框
    Widget? _borderRet;
    if(styleMap!=null &&  styleMap.containsKey("border") && styleMap["border"].isNotEmpty){
      var value = styleMap["border"];
      if(value is String){
        value = value.trim();
        if(value=="none"){
          _borderRet = _alignRet;
          return;
        }
        var val = value.split(RegExp(r"[\t\s]+"));
        if(val.length>1){
          dynamic color = val[1];
          dynamic width = val[0];
          if(color!=null && width!=null){
            _borderRet =  _alignRet!.border(
              all: double.parse(width),
              color: StyleParse.hexColor(color),
              style: val.length<=2?BorderStyle.solid:val[2]=='none'?BorderStyle.none:BorderStyle.solid
            );
          }
        }
      }else if(value is Map){
        if(value.containsKey("width") && value.containsKey("color")){
          _borderRet =  _alignRet!.border(
              all: double.parse(value["width"]),
              color: StyleParse.hexColor(value["color"]),
              style: value.containsKey("style")?value['style']=="none"?BorderStyle.none:BorderStyle.solid:BorderStyle.solid
          );
        }else if(value.containsKey("radius")){
          _borderRet = _parseClipRRect(_alignRet!,styleMap["border"]['radius']);
        }else{
          var keys = value.keys;
          var left;
          var right;
          var top;
          var bottom;
          var all;
          var color;
          var style;

          keys.forEach((k) {
            var val = value[k].trim();
            if(val!=null && val.isNotEmpty){
              val = val.split(RegExp(r"[\t\s]+"));
              if(val.length==2){
                color = val[1];
              }else if(val.length==3){
                color = val[2];
                style = val[1];
              }
              
              if(k=="left"){
                left = double.parse(val[0]);
              }else if(k=="right"){
                right = double.parse(val[0]);
              }else if(k=="bottom"){
                bottom = double.parse(val[0]);
              }else if(k=="top"){
                top = double.parse(val[0]);
              }else if(k=="all"){
                all = double.parse(val[0]);
              }
            }
          });

          if(value.containsKey("color") && value['color'].isNotEmpty){
            color = value["color"];
          }
          if(value.containsKey("style") && value['style'].isNotEmpty){
            color = value["style"];
          }

          keys.forEach((element) { });
          _borderRet =  _alignRet!.border(
            all: all,
            left: left ,
            right: right ,
            top: top,
            bottom: bottom ,
            color: color!=null?StyleParse.hexColor(color):null,
            style: style=="none"?BorderStyle.none:BorderStyle.solid
          );
        }
      }else{
        _borderRet = _alignRet;
      }
      
    }else{
      _borderRet = _alignRet;
    }

    // 背景
    Widget? _bgRet;
    if(styleMap!=null &&  styleMap.containsKey("background") && styleMap["background"] is Map){
      _bgRet = _parseBackground(_borderRet!,styleMap["background"]);
    }else{
      _bgRet = _borderRet;
    }

    // 圆角 
    Widget? _radiusRet;
    if(styleMap!=null &&  styleMap.containsKey("radius")  && styleMap["radius"].isNotEmpty){
      var value = styleMap["radius"];
      if(value is String){
        var val = value.split(RegExp(r"[\t\s]+"));
        if(val.length==1){
          _radiusRet = _bgRet!.borderRadius(all: double.parse(value.trim()));
        }else if(val.length==2){
          _radiusRet = _bgRet!.borderRadius(
            topLeft: double.parse(val[0]),
            topRight: double.parse(val[0]),
            bottomLeft: double.parse(val[1]),
            bottomRight: double.parse(val[1])
          );
        }else if(val.length==4){
          _radiusRet = _bgRet!.borderRadius(
            topLeft: double.parse(val[0]),
            topRight: double.parse(val[1]),
            bottomLeft: double.parse(val[2]),
            bottomRight: double.parse(val[3])
          );
        }
      }else if(value is Map){
        _radiusRet = _bgRet!.borderRadius(
          topLeft: value.containsKey("topLeft")?double.parse(value["topLeft"]):null,
          topRight: value.containsKey("topRight")?double.parse(value["topRight"]):null,
          bottomLeft: value.containsKey("bottomLeft")?double.parse(value["bottomLeft"]):null,
          bottomRight: value.containsKey("bottomRight")?double.parse(value["bottomRight"]):null
        );
      }else{
        _radiusRet = _bgRet;
      }
    }else{
      _radiusRet = _bgRet;
    }

    // clipRRect 边角裁剪
    Widget? _clipRRectRet;
    if(styleMap!=null && (
      (styleMap.containsKey("clipRRect") && styleMap["clipRRect"].isNotEmpty) ||
      (styleMap.containsKey("border") && styleMap["border"] is Map && styleMap["border"].containsKey("radius") && styleMap["border"]["radius"].isNotEmpty)
    )
    ){
      if(styleMap['clipRRect']!=null){
        _clipRRectRet = _parseClipRRect(_radiusRet!,styleMap["clipRRect"]);
      }else{
        _clipRRectRet = _parseClipRRect(_radiusRet!,styleMap["border"]['radius']);
      }
      
    }else{
      _clipRRectRet = _radiusRet;
    }

    // clipOval  圆形裁剪
    Widget? _clipOvalRet;
    if(styleMap!=null &&  styleMap.containsKey("clipOval")){
      _clipOvalRet = _clipRRectRet!.clipOval();
    }else{
      _clipOvalRet = _clipRRectRet;
    }
    

    // 底边阴影
    Widget? _elevationRet;
    if(styleMap!=null &&  styleMap.containsKey("elevation")){
      _elevationRet = _clipOvalRet!.elevation(double.parse(styleMap["elevation"]));
    }else{
      _elevationRet = _clipOvalRet;
    }

    // boxshadow
    Widget? _shadowRet;
    if(styleMap!=null &&  styleMap.containsKey("shadow")){
      var value = styleMap["shadow"];
      if(value is String){
        // 1,2,3,#dddddd;   1 2 3 #dddddd;
        List _shadowList = value.split(RegExp(r"[\s\t,]"));
        if(_shadowList.length == 4){
          _shadowRet = _elevationRet!.boxShadow(
            color: StyleParse.hexColor( _shadowList[3]),
            offset: Offset(double.parse(_shadowList[0]), double.parse(_shadowList[1])),
            blurRadius: double.parse(_shadowList[2])
            // spreadRadius: double.parse( _shadowList[1]),
          );
        }else{
          _shadowRet = _elevationRet;
        }
      }else if(value is Map){
        _shadowRet = _elevationRet!.boxShadow(
          color: value.containsKey("color")?StyleParse.hexColor(value["color"]):null,
          offset: value.containsKey("offset")? StyleParse.offset( value['offset'] ):Offset.zero,
          blurRadius: value.containsKey("blur")?double.parse(value['blur']):0,
          spreadRadius: value.containsKey("spread")?double.parse(value['spread']):0,
        );
      }
    }else{
      _shadowRet = _elevationRet;
    }

    // 宽width
    Widget? _widthRet;
    if(styleMap!=null &&  styleMap.containsKey("width")){
      _widthRet = _shadowRet!.width(double.parse(styleMap["width"]));
    }else{
      _widthRet = _shadowRet;
    }
    // 高
    Widget? _heightRet;
    if(styleMap!=null &&  styleMap.containsKey("height")){
      _heightRet = _widthRet!.height(double.parse(styleMap["height"]));
    }else{
      _heightRet = _widthRet;
    }
    // ripple
    Widget? _rippleRet;
    if(styleMap!=null &&  styleMap.containsKey("ripple") && styleMap["ripple"] is Map){
      var value = styleMap["ripple"];
      _rippleRet = _heightRet!.ripple(
        focusColor: value.containsKey("focusColor")?StyleParse.hexColor(value["focusColor"]):null,
        hoverColor: value.containsKey("hoverColor")?StyleParse.hexColor(value["hoverColor"]):null,
        highlightColor: value.containsKey("highlightColor")?StyleParse.hexColor(value["highlightColor"]):null,
        radius: value.containsKey("radius")?double.parse(value["radius"]):null,
        splashColor:value.containsKey("splashColor")?StyleParse.hexColor(value["splashColor"]):null,
      );
    }else{
      _rippleRet = _heightRet;
    }

    // rotate
    Widget? _rotateRet;
    if(styleMap!=null && styleMap.containsKey("rotate") && styleMap["rotate"] is Map){
      var value = styleMap["rotate"];
      _rotateRet = _rippleRet!.rotate(
        angle: value.containsKey("angle")?double.parse(value["angle"]):0,
        origin:value.containsKey("origin")?StyleParse.offset(value["origin"]):null,
        alignment:value.containsKey("align")?StyleParse.alignment(value["align"]):null
      );
    }else{
      _rotateRet = _rippleRet;
    }

    // 缩放
    Widget? _scaleRet;
    if(styleMap!=null && styleMap.containsKey("scale") && styleMap["scale"] is Map){
      Map<String,dynamic> value = styleMap["scale"];
      _scaleRet = _rotateRet!.scale(
        all:value.containsKey("all")?double.parse(value["all"]):null,
        x: value.containsKey("x")?double.parse(value["x"]):null,
        y: value.containsKey("y")?double.parse(value["y"]):null,
        origin:value.containsKey("origin")?StyleParse.offset(value["origin"]):null,
        alignment:value.containsKey("align")?StyleParse.alignment(value["align"]):null
      );
    }else{
      _scaleRet = _rotateRet;
    }

    // translate 矩阵变化
    Widget? _translateRet;
    if(styleMap!=null && styleMap.containsKey("translate")){
      _translateRet = _scaleRet!.translate(
        offset: StyleParse.offset(styleMap["translate"])
      );
    }else{
      _translateRet = _scaleRet;
    }

    // transform 矩阵变化 
    Widget? _transformRet;
    if(styleMap!=null && styleMap.containsKey("transform") && styleMap["transform"] is Map){
      var value = styleMap["transform"];
      _transformRet = _translateRet!.transform(
        transform: value.containsKey("matrix")?StyleParse.matrix(value['matrix']):null,
        origin:value.containsKey("origin")?StyleParse.offset(value["origin"]):null,
        alignment:value.containsKey("align")?StyleParse.alignment(value["align"]):null
      );
    }else{
      _transformRet = _translateRet;
    }

    // overflow
    Widget? _overflowRet;
    if(styleMap!=null && styleMap.containsKey("overflow") && styleMap["overflow"] is Map){
      var value = styleMap["overflow"];
      _overflowRet = _transformRet!.overflow(
        alignment:value.containsKey("align")?StyleParse.alignment(value['align']):null,
        maxWidth:value.containsKey("maxWidth")?double.parse("maxWidth"):null,
        minWidth:value.containsKey("minWidth")?double.parse("minWidth"):null,
        maxHeight:value.containsKey("maxHeight")?double.parse("maxHeight"):null,
        minHeight: value.containsKey("minHeight")?double.parse("minHeight"):null,
      );
    }else{
      _overflowRet = _transformRet;
    }

    // scrollable
    Widget? _scrollableRet;
    if(styleMap!=null && styleMap.containsKey("scrollable")){
      var value = styleMap["scrollable"];
      if(value is Map){
        _scrollableRet = _overflowRet!.scrollable(
          scrollDirection:value.containsKey("direction")? (value["direction"]=="vertical"?Axis.vertical:Axis.horizontal):Axis.vertical,
          reverse:value.containsKey("reverse")?StyleParse.bool(value['reverse']):false
        );
      }else{
        _scrollableRet = _overflowRet!.scrollable();
      }
    }else{
      _scrollableRet = _overflowRet;
    }

    return _scrollableRet;
    
  }

  // padding
  static _parsePadding(Widget? ret,padding){
    if(ret!=null && padding!=null && padding.isNotEmpty){
      if(padding is String && padding.isNotEmpty){
        var plist = padding.split(RegExp(r","));
        if(plist.length==1){
          return ret.padding(all:double.parse(padding));
        }else if(plist.length==2){
          padding = {
            "vertical":plist[0].trim(),
            "horizontal":plist[1].trim()
          };
        }else if(plist.length==4){
          padding = {
            "top":plist[0].trim(),
            "right":plist[1].trim(),
            "bottom":plist[2].trim(),
            "left":plist[3].trim()
          };
        }
      }

      if(padding is Map){
        return ret.padding(
          all: padding.containsKey("all") ?double.parse(padding['all']):null,
          top: padding.containsKey("top") ?double.parse(padding['top']):null,
          left: padding.containsKey("left") ?double.parse(padding['left']):null,
          right: padding.containsKey("right") ?double.parse(padding['right']):null,
          bottom: padding.containsKey("bottom") ?double.parse(padding['bottom']):null,
          vertical: padding.containsKey("vertical") ?double.parse(padding['vertical']):null,
          horizontal: padding.containsKey("horizontal") ?double.parse(padding['horizontal']):null,
        );
      }
    }
    return ret;
  }

  // decorated 样式
  static _parseDecorated(Widget? ret,decorated){
    if(ret!=null && decorated!=null && decorated.isNotEmpty){
      var dMap = StyleParse.convertAttr(decorated);
      if(dMap is Map && dMap.isNotEmpty){
        return ret.decorated(
          color:StyleParse.hexColor(dMap['color']), 
          image:StyleParse.decorationImage(dMap['image']), 
          border:StyleParse.border(dMap["border"]), 
          borderRadius:StyleParse.borderRadius(dMap['radius']), 
          boxShadow:StyleParse.boxShadow(dMap['shadows']), 
          gradient:StyleParse.gradient(dMap['gradient']), 
          backgroundBlendMode:StyleParse.blendMode(dMap['blendMode']), 
          shape:StyleParse.boxShape(dMap['shape']),
          animate:StyleParse.bool(dMap['animate'])
        );
      }
    }

    return ret;
  }

  // 裁剪
  static Widget _parseClipRRect(Widget ret,rect){
    if(rect!=null && rect.isNotEmpty){
      if(rect is String){
        var rectList = rect.split(RegExp(r"[\t\s,]"));
        if(rectList.length==1){
          return ret.clipRRect(all:double.parse(rectList[0]));
        }else if(rectList.length==2){
          return ret.clipRRect(
            topLeft:double.parse(rectList[0]),
            topRight:double.parse(rectList[0]),
            bottomLeft:double.parse(rectList[1]),
            bottomRight:double.parse(rectList[1])
          );
        }else if(rectList.length==4){
          return ret.clipRRect(
            topLeft:double.parse(rectList[0]),
            topRight:double.parse(rectList[1]),
            bottomLeft:double.parse(rectList[2]),
            bottomRight:double.parse(rectList[3])
          );
        }else{
          return ret;
        }
      }else if(rect is Map){
        return ret.clipRRect(
          all: rect["all"],
          topLeft: rect.containsKey("topLeft")?double.parse(rect["topLeft"]):null,
          topRight: rect.containsKey("topRight")?double.parse(rect["topRight"]):null,
          bottomLeft: rect.containsKey("bottomLeft")?double.parse(rect["bottomLeft"]):null,
          bottomRight: rect.containsKey("bottomRight")?double.parse(rect["bottomRight"]):null,
        );
      }
      
    }
    return ret;
  }

  // 背景
  static Widget _parseBackground(Widget ret,Map<String,dynamic>background){
    // 背景色
    Widget _bgColorRet;
    if(background.containsKey("color")){
      _bgColorRet = ret.backgroundColor(StyleParse.hexColor(background["color"]));
    }else{
      _bgColorRet = ret;
    }

    // 背景图片
    Widget _bgImgRet;
    if(background.containsKey("image")){
      _bgImgRet = _bgColorRet.backgroundImage(StyleParse.decorationImage(background['image']));
    }else{
      _bgImgRet = _bgColorRet;
    }
    // 背景渐变色
    Widget _bgGradientRet;
    if( background.containsKey("gradient")){
        _bgGradientRet = _bgImgRet.backgroundGradient(StyleParse.gradient(background['gradient']));
    }else{
      _bgGradientRet = _bgImgRet;
    }

    //backgroundLinearGradient  直线渐变
    Widget _bgLgRet;
    if(background.containsKey("linearGradient") && background["linearGradient"] is Map){
      var value = background["linearGradient"];
      _bgLgRet = _bgGradientRet.backgroundLinearGradient(
        begin:value.containsKey("begin")?StyleParse.alignment(value["begin"]):Alignment.centerLeft, 
        end:value.containsKey("end")?StyleParse.alignment(value["end"]):Alignment.centerRight,
        colors:value.containsKey("colors")?value["colors"].split(",").forEach((color){
          return StyleParse.hexColor(color.trim());
        }).toList():null, 
        stops:value.containsKey("stops")?value["stops"].split(",").forEach((stop){
          return double.parse(stop.trim());
        }).toList():null,
      );
    }else{
      _bgLgRet = _bgGradientRet;
    }

    // backgroundSweepGradient 中心点渐变
    Widget _bgSgRet;
    if(background.containsKey("sweepGradient") && background["sweepGradient"] is Map){
      var value = background["sweepGradient"];
      _bgSgRet = _bgLgRet.backgroundSweepGradient(
        center: value.containsKey("center")?StyleParse.alignment(value["center"]):Alignment.center,
        startAngle:value.containsKey("startAngle")?double.parse(value["startAngle"]):0.0,
        endAngle: value.containsKey("endAngle")?double.parse(value["endAngle"]):0,
        colors:value.containsKey("colors")?value["colors"].split(",").forEach((color){
          return StyleParse.hexColor(color.trim());
        }).toList():null, 
        stops:value.containsKey("stops")?value["stops"].split(",").forEach((stop){
          return double.parse(stop.trim());
        }).toList():null,
      );
    }else{
      _bgSgRet = _bgLgRet;
    }

    // backgroundRadialGradient 圆角渐变
    Widget _bgRgRet;
    if( background.containsKey("radialGradient") &&  background["radialGradient"] is Map){
      var value = background["radialGradient"];
      _bgRgRet = _bgSgRet.backgroundRadialGradient(
        center: value.containsKey("center")?StyleParse.alignment(value["center"]):Alignment.center,
        radius:value.containsKey("radius")?double.parse(value["radius"]):0,
        colors:value.containsKey("colors")?value["colors"].split(",").forEach((color){
          return StyleParse.hexColor(color.trim());
        }).toList():null, 
        stops:value.containsKey("stops")?value["stops"].split(",").forEach((stop){
          return double.parse(stop.trim());
        }).toList():null,
      );
    }else{
      _bgRgRet = _bgSgRet;
    }
    // backgroundBlendMode
    Widget  _bgBmRet;
    if( background.containsKey("blendMode")){
      _bgBmRet = _bgRgRet.backgroundBlendMode(StyleParse.blendMode(background["blendMode"]));
    }else{
      _bgBmRet = _bgRgRet;
    }
    // backgroundBlur
    Widget _bgBlurRet;
    if(background.containsKey("blur")){
      _bgBlurRet = _bgBmRet.backgroundBlur(double.parse(background["blur"]));
    }else{
      _bgBlurRet = _bgBmRet;
    }
    return _bgBlurRet;
  }

}
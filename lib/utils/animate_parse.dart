import 'package:flutter/material.dart';
import 'package:tuna3/utils/style_parse.dart';
import '../compontents/animateSet/animation_set.dart';
import '../compontents/animateSet/animator.dart';

import 'package:html/dom.dart' as dom;

class AnimateParse{

  static AnimationType animationType(String? type){
    AnimationType ret;
    switch(type){
      case"true":
        ret = AnimationType.repeat;
        break;
      case"false":
        ret = AnimationType.once;
        break;
      case"reverse":
        ret = AnimationType.reverse;
        break;
      default:
        ret = AnimationType.once;
        break;
    }
    return ret;
  }
  // list 接受map而非templateMap
  static animationSetMap(List sets,{duration=450}){
    List<Animator<dynamic>> _rets = [];
    sets.forEach((item) { 
      switch(item["type"]){
          case "delay":
            var ret = _parseDelay(item,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "width":
            var ret = _parseWidth(item,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "height":
            var ret = _parseHeight(item,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "padding":
            var ret = _parsePadding(item,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "opacity":
            var ret = _parseOpacity(item,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "sx":
          case "scaleX":
            var ret = _parseScaleX(item,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "sy":
          case "scaleY":
            var ret = _parseScaleY(item,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "rx":
          case "rotateX":
            var ret  = _parseRotateX(item,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "ry":
          case "rotateY":
            var ret = _parseRotateY(item,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "rz":
          case "rotateZ":
            var ret = _parseRotateZ(item,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "x":
          case "transitionX":
            var ret = _parseTransitionX(item,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "y":
          case "transitionY":
            var ret = _parseTransitionY(item,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "color":
            var ret = _parseColor(item,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "border":
            var ret = _parseBorder(item,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "s":
          case "serial":
            var ret = parseSerialMap(item,duration: duration);
            if(ret!=null){
              _rets.add(ret);
            }
        }
    });
    return _rets;
  }

  static List<Animator<dynamic>> amimationSet(List sets,{duration=450}){
    List<Animator<dynamic>> _rets = [];
    sets.forEach((item) {
      if(item.localName=="set"){
        var attrs = item.attributes;
        switch(attrs["type"]){
          case "delay":
            var ret = _parseDelay(attrs,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "width":
            var ret = _parseWidth(attrs,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "height":
            var ret = _parseHeight(attrs,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "padding":
            var ret = _parsePadding(attrs,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "opacity":
            var ret = _parseOpacity(attrs,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "sx":
          case "scaleX":
            var ret = _parseScaleX(attrs,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "sy":
          case "scaleY":
            var ret = _parseScaleY(attrs,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "rx":
          case "rotateX":
            var ret  = _parseRotateX(attrs,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "ry":
          case "rotateY":
            var ret = _parseRotateY(attrs,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "rz":
          case "rotateZ":
            var ret = _parseRotateZ(attrs,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "x":
          case "transitionX":
            var ret = _parseTransitionX(attrs,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "y":
          case "transitionY":
            var ret = _parseTransitionY(attrs,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "color":
            var ret = _parseColor(attrs,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
          case "border":
            var ret = _parseBorder(attrs,duration:duration);
            if(ret!=null){
              _rets.add(ret);
            }
            break;
        }
      }else if(item.localName=="serial"){
        var ret = parseSerial(item,duration: duration);
        if(ret!=null){
          _rets.add(ret);
        }
      }
    });
    return _rets;
  }

  static _parseDelay(Map item,{duration=450}){
    var _duration = item.containsKey("duration")?int.parse(item["duration"].toString()):duration;
    return Delay(duration: _duration);
  }

  static parseSerialMap(Map serial,{duration=450}){
    if(serial.containsKey("sets") && serial['sets'] is List && serial['sets'].length>0){
      duration = serial.containsKey("duration")?int.parse(serial["duration"].toString()):duration;
      List<Animator<dynamic>> sets = animationSetMap(serial['sets'],duration:duration);
      if(sets is List && sets.length>0){
        return Serial(
          duration: duration,
          delay: serial.containsKey("delay")?int.parse(serial["delay"].toString()):0,
          serialList: sets,
        );
      }
    }
  }

  static parseSerial(dynamic item,{duration=450}){
    
    dynamic attrs;
    dynamic children;
    

    if(item is dom.Element){
      attrs = item.attributes;
      children = item.children;
    }else if(item is dom.Element){
      attrs = item.attributes;
      children = item.children;
    }
      
    if(children is List && children.length>0){
      duration = attrs.containsKey("duration")?int.parse(attrs["duration"].toString()):duration;
      var sets = amimationSet(children,duration:duration);
      if(sets is List && sets.length>0){
        return Serial(
          duration: duration,
          delay: attrs.containsKey("delay")?int.parse(attrs["delay"].toString()):0,
          serialList: sets,
        );
      }
    }
    
  }

  static _parseWidth(Map item,{duration=450}){
    if(item.containsKey("from") && item.containsKey("to")){
      return W(
        from: double.parse(item["from"].toString()), 
        to: double.parse(item["to"].toString()), 
        duration: item.containsKey("duration")?int.parse(item["duration"].toString()):duration, 
        delay: item.containsKey("delay")?int.parse(item["delay"].toString()):0, 
        curve: item.containsKey("curve")?curve(item["curve"]):Curves.linear
      );
    }
  }
  static _parseHeight(Map item,{duration=450}){
    if(item.containsKey("from") && item.containsKey("to")){
      return H(
        from: double.parse(item["from"].toString()), 
        to: double.parse(item["to"].toString()), 
        duration: item.containsKey("duration")?int.parse(item["duration"].toString()):duration, 
        delay: item.containsKey("delay")?int.parse(item["delay"].toString()):0, 
        curve: item.containsKey("curve")?curve(item["curve"]):Curves.linear
      );
    }
  }
  static _parsePadding(Map item,{duration=450}){
    if(item.containsKey("from") && item.containsKey("to")){
      return P(
        from: StyleParse.edgeInsetsGeometry(item["from"].toString()), 
        to: StyleParse.edgeInsetsGeometry(item["to"].toString()), 
        duration: item.containsKey("duration")?int.parse(item["duration"].toString()):duration, 
        delay: item.containsKey("delay")?int.parse(item["delay"].toString()):0, 
        curve: item.containsKey("curve")?curve(item["curve"]):Curves.linear
      );
    }
  }
  static _parseOpacity(Map item,{duration=450}){
    if(item.containsKey("from") && item.containsKey("to") ){
      return O(
        from: double.parse(item["from"].toString()), 
        to: double.parse(item["to"].toString()), 
        duration: item.containsKey("duration")?int.parse(item["duration"].toString()):duration, 
        delay: item.containsKey("delay")?int.parse(item["delay"].toString()):0, 
        curve: item.containsKey("curve")?curve(item["curve"]):Curves.linear
      );
    }
  }

  static _parseScaleX(Map item,{duration=450}){
    if(item.containsKey("from") && item.containsKey("to") ){
      return SX(
        from: double.parse(item["from"].toString()), 
        to: double.parse(item["to"].toString()), 
        duration: item.containsKey("duration")?int.parse(item["duration"].toString()):duration, 
        delay: item.containsKey("delay")?int.parse(item["delay"].toString()):0, 
        curve: item.containsKey("curve")?curve(item["curve"]):Curves.linear
      );
    }
  }
  static _parseScaleY(Map item,{duration=450}){
    if(item.containsKey("from") && item.containsKey("to")){
      return SY(
        from: double.parse(item["from"].toString()), 
        to: double.parse(item["to"].toString()), 
        duration: item.containsKey("duration")?int.parse(item["duration"].toString()):duration, 
        delay: item.containsKey("delay")?int.parse(item["delay"].toString()):0, 
        curve: item.containsKey("curve")?curve(item["curve"]):Curves.linear
      );
    }
  }
  static _parseRotateX(Map item,{duration=450}){
    if(item.containsKey("from") && item.containsKey("to")){
      return RX(
        from: double.parse(item["from"].toString()), 
        to: double.parse(item["to"].toString()), 
        duration: item.containsKey("duration")?int.parse(item["duration"].toString()):duration, 
        delay: item.containsKey("delay")?int.parse(item["delay"].toString()):0, 
        curve: item.containsKey("curve")?curve(item["curve"]):Curves.linear
      );
    }
  }
  static _parseRotateY(Map item,{duration=450}){
    if(item.containsKey("from") && item.containsKey("to")){
      return RY(
        from: double.parse(item["from"].toString()), 
        to: double.parse(item["to"].toString()), 
        duration: item.containsKey("duration")?int.parse(item["duration"].toString()):duration, 
        delay: item.containsKey("delay")?int.parse(item["delay"].toString()):0, 
        curve: item.containsKey("curve")?curve(item["curve"]):Curves.linear
      );
    }
  }
  static _parseRotateZ(Map item,{duration=450}){
    if(item.containsKey("from") && item.containsKey("to")){
      return RZ(
        from: double.parse(item["from"].toString()), 
        to: double.parse(item["to"].toString()), 
        duration: item.containsKey("duration")?int.parse(item["duration"].toString()):duration, 
        delay: item.containsKey("delay")?int.parse(item["delay"].toString()):0, 
        curve: item.containsKey("curve")?curve(item["curve"]):Curves.linear
      );
    }
  }
  static _parseTransitionX(Map item,{duration=450}){
    if(item.containsKey("from") && item.containsKey("to")){
      return TX(
        from: double.parse(item["from"].toString()), 
        to: double.parse(item["to"].toString()), 
        duration: item.containsKey("duration")?int.parse(item["duration"].toString()):duration, 
        delay: item.containsKey("delay")?int.parse(item["delay"].toString()):0, 
        curve: item.containsKey("curve")?curve(item["curve"]):Curves.linear
      );
    }
  }
  static _parseTransitionY(Map item,{duration=450}){
    if(item.containsKey("from") && item.containsKey("to")){
      return TY(
        from: double.parse(item["from"].toString()), 
        to: double.parse(item["to"].toString()), 
        duration: item.containsKey("duration")?int.parse(item["duration"].toString()):duration, 
        delay: item.containsKey("delay")?int.parse(item["delay"].toString()):0, 
        curve: item.containsKey("curve")?curve(item["curve"]):Curves.linear
      );
    }
  }
  static _parseColor(Map item,{duration=450}){
    if(item.containsKey("from") && item.containsKey("to")){
      return C(
        from: StyleParse.hexColor(item["from"]), 
        to: StyleParse.hexColor(item["to"]), 
        duration: item.containsKey("duration")?int.parse(item["duration"].toString()):duration, 
        delay: item.containsKey("delay")?int.parse(item["delay"].toString()):0, 
        curve: item.containsKey("curve")?curve(item["curve"]):Curves.linear
      );
    }
  }
  static _parseBorder(Map item,{duration=450}){
    if(item.containsKey("from") && item.containsKey("to")){
      return B(
        from: StyleParse.borderRadius(item["from"].toString()), 
        to: StyleParse.borderRadius(item["to"].toString()), 
        duration: item.containsKey("duration")?int.parse(item["duration"].toString()):duration, 
        delay: item.containsKey("delay")?int.parse(item["delay"].toString()):0, 
        curve: item.containsKey("curve")?curve(item["curve"]):Curves.linear
      );
    }
  }

  static curve(curve){
    switch(curve){
      case "bounceIn":
        return Curves.bounceIn;
      case "bounceInOut":
        return Curves.bounceInOut;
      case "bounceOut":
        return Curves.bounceOut;
      case "decelerate":
        return Curves.decelerate;
      case "ease":
        return Curves.ease;
      case "easeIn":
        return Curves.easeIn;
      case "easeInBack":
        return Curves.easeInBack;
      case "easeInCirc":
        return Curves.easeInCirc;
      case "easeInCubic":
        return Curves.easeInCubic;
      case "easeInExpo":
        return Curves.easeInExpo;
      case "easeInOut":
        return Curves.easeInOut;
      case "easeInOutBack":
        return Curves.easeInOutBack;
      case "easeInOutCirc":
        return Curves.easeInOutCirc;
      case "easeInOutCubic":
        return Curves.easeInOutCubic;
      case "easeInOutExpo":
        return Curves.easeInOutExpo;
      case "easeInOutQuad":
        return Curves.easeInOutQuad;
      case "easeInOutQuart":
        return Curves.easeInOutQuart;
      case "easeInOutQuint":
        return Curves.easeInOutQuint;
      case "easeInOutSine":
        return Curves.easeInOutSine;
      case "easeInQuad":
        return Curves.easeInQuad;
      case "easeInQuart":
        return Curves.easeInQuart;
      case "easeInQuint":
        return Curves.easeInQuint;
      case "easeInSine":
        return Curves.easeInSine;
      case "easeInToLinear":
        return Curves.easeInToLinear;
      case "easeOut":
        return Curves.easeOut;
      case "easeOutBack":
        return Curves.easeOutBack;
      case "easeOutCirc":
        return Curves.easeOutCirc;
      case "easeOutCubic":
        return Curves.easeOutCubic;
      case "easeOutExpo":
        return Curves.easeOutExpo;
      case "easeOutQuad":
        return Curves.easeOutQuad;
      case "easeOutQuart":
        return Curves.easeOutQuart;
      case "easeOutQuint":
        return Curves.easeOutQuint;
      case "easeOutSine":
        return Curves.easeOutSine;
      case "fastLinearToSlowEaseIn":
        return Curves.fastLinearToSlowEaseIn;
      case "elasticIn":
        return Curves.elasticIn;
      case "elasticInOut":
        return Curves.elasticInOut;
      case "elasticOut":
        return Curves.elasticOut;
      case "slowMiddle":
        return Curves.slowMiddle;
      case "linear":
      default:
        return Curves.linear;
    }
  }

}
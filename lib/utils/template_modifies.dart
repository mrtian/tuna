import 'package:intl/intl.dart';

class TemplateModify{
  static Map<String,dynamic> methods = {
    "replace":(String? val,List<dynamic>params){
      if(params.length==2){
          String match = params[0];
          String replace = params[1];
          
          if(replace==r'""' || replace==r"''"){
            replace = "";
          }
          var reg = RegExp(r"^/.*/$");
          if(reg.hasMatch(match)){
            match = match.replaceAll(RegExp(r"^/"),"");
            match = match.replaceAll(RegExp(r"/$"),"");
            var _matchRe = RegExp(r""+match);
            return val!.replaceAll(_matchRe,replace);
          }else{
            return val!.replaceAll(match,replace);
          }
          
      }
      
      return val;
    },
    "toFixed":(String? val,List<dynamic>params){
      String fixed = params[0];
      var _trueVal;
      var _fixed;
      try{
        _trueVal = double.parse(val!);
        _fixed = int.parse(fixed);
        if(_trueVal!=null && _fixed>0){
          return _trueVal.toStringAsFixed(_fixed);
        }
      }catch(e){
        print(e);
      }
      return "null";
    },
    "default":(String? val,List<dynamic>params){
      String defaultStr = params[0].toString();
      if(val==null || val.isEmpty){
        return defaultStr;
      }
      return val;
    },
    "+":(String val,List<dynamic>params){
      val = val.toString();
      String num = params[0].toString();
      if(_isNumberic(val) && _isNumberic(num) ){
        if(_isInt(val) && _isInt(num)){
          return int.parse(val)+int.parse(num);
        }
        return double.parse(val)+double.parse(num);
      }
      return "$val"+"$num";
    },
    "-":(val,List<dynamic>params){
      val = val.toString();
      String num = params[0].toString();
      if(_isNumberic(val) && _isNumberic(num) ){
        if(_isInt(val) && _isInt(num)){
          return int.parse(val)-int.parse(num);
        }
        return double.parse(val)-double.parse(num);
      }
      return null;
    },
    "*":(val,List<dynamic>params){
      val = val.toString();
      String num = params[0].toString();
      if(_isNumberic(val) && _isNumberic(num) ){
        if(_isInt(val) && _isInt(num)){
          return int.parse(val)*int.parse(num);
        }
        return double.parse(val)*double.parse(num);
      }
      return null;
    },
    "/":(val,List<dynamic>params){
      val = val.toString();
      String num = params[0].toString();
      if(_isNumberic(val) && _isNumberic(num) ){
        return double.parse(val)/double.parse(num);
      }
      return null;
    },
    "%":(val,List<dynamic>params){
      val = val.toString();
      String num = params[0].toString();
      if(_isNumberic(val) && _isNumberic(num) ){
        if(_isInt(val) && _isInt(num)){
          return int.parse(val)%int.parse(num);
        }
        return double.parse(val)%double.parse(num);
      }
      return null;
    },
    "parseInt":(val,List<dynamic>params){
      val = val.toString();
      if(_isNumberic(val)){
        return double.parse(val).toStringAsFixed(0);
      }
      return null;
    },
    "?":(val,List<dynamic>params){
      if(val!=null && val!=false){
        return params[0];
      }else{
        return params[1];
      }
    },
    "ceil":(val,List<dynamic>params){
      val = val.toString();
      if(_isNumberic(val)){
        return double.parse(val).ceil();
      }
      return null;
    },
    "round":(val,List<dynamic>params){
      val = val.toString();
      if(_isNumberic(val)){
        return double.parse(val).round();
      }
      return null;
    },
    "trim":(val,List<dynamic>params){
      return val.trim();
    },
    "truncate":(val,List<dynamic>params){
      dynamic maxLen =  params.isNotEmpty? params[0]:null;
      dynamic truncate;
      if(params.length>1){
        truncate = "...";
      }
      try{
        maxLen = int.parse(maxLen);
        if(val.length>maxLen){
          return val.substring(0,maxLen)+truncate;
        }
      }catch(e){
        return val;
      }
    },
    "substr":(val,List<dynamic>params){
      try{
        int start = int.parse(params[0]);
        int end = int.parse(params[1]);
        return val.substring(start,end);
      }catch(e){
        return val;
      }
      
    },
    "toDateFormat":(timestamp,List<dynamic>params){
      var time;
      String? formatStr = params.isNotEmpty?params[0]:null;
      if(_isInt(timestamp)){
        timestamp = int.parse(timestamp);
      }else{
        timestamp = int.parse((DateTime.now().millisecondsSinceEpoch).toStringAsFixed(0));
      }
      if(formatStr==null || formatStr.isEmpty){
        formatStr = "y-M-d";
      }
      
      var format =  DateFormat(formatStr);
      var date =  DateTime.fromMillisecondsSinceEpoch(timestamp);
      // print(date);
      time = format.format(date);
      return time;
    },
    "toPubTime":(timestamp,List<dynamic>params){
      String language = params.isNotEmpty?params[0]:"cn";
      timestamp  = int.parse(timestamp);
      var yearsFoward = language=="en"?" years ago":"天前";
      var yearsLater = language=="en"?" years later":"天后";
      var monthsFoward = language=="en"?" months ago":"天前";
      var monthsLater = language=="en"?" months later":"天后";
      var weeksFoward = language=="en"?" days ago":"天前";
      var weeksLater = language=="en"?" days later":"天后";
      var daysFoward = language=="en"?" days ago":"天前";
      var daysLater = language=="en"?" days later":"天后";
      var hoursFoward = language=="en"?" hours ago":"小时前";
      var hoursLater = language=="en"?" hours later":"小时后";
      var minsFoward = language=="en"?" minutes ago":"分钟前";
      var minsLater = language=="en"?" minutes later":"分钟后";
      
      var now = DateTime.now();
      var time = DateTime.fromMillisecondsSinceEpoch(timestamp);
     
      var diff = now.difference(time);
      var days = diff.inDays;
      var minutes = diff.inMinutes;
      var hours = diff.inHours;

      if(now.millisecondsSinceEpoch - timestamp >= 0 ){
        if(days>0){
          if(days>365){
            return (days/365).toStringAsFixed(0)+yearsFoward;
          }else if(days>=30){
            return (days/30).toStringAsFixed(0)+monthsFoward;
          }else if(days>=7){
            return (days/7).toStringAsFixed(0)+weeksFoward;
          }else{
            return days.toString()+daysFoward;
          }
        }else{
          if(hours>0){
            return hours.toString()+hoursFoward;
          }else if(minutes>=30){
            return (language=="en"?" half":"半")+hoursFoward;
          }else if(minutes>0){
            return minutes.toString()+minsFoward;
          }else{
            return language=="en"?"a moment ago":"刚刚";
          }
        }
      }else{
        if(days>0){
          if(days>365){
            return (days/365).toStringAsFixed(0)+yearsLater;
          }else if(days>=30){
            return (days/30).toStringAsFixed(0)+monthsLater;
          }else if(days>=7){
            return (days/7).toStringAsFixed(0)+weeksLater;
          }else{
            return days.toString()+daysLater;
          }
        }else{
          if(hours>0){
            return hours.toString()+hoursLater;
          }else if(minutes>=30){
            return (language=="en"?" half":"半")+hoursLater;
          }else if(minutes>0){
            return minutes.toString()+minsLater;
          }else{
            return language=="en"?"now":"刚刚";
          }
        }
      }
    },
    "min":(value,List<dynamic>params){
      dynamic max = params[0];
      if(value==null){
        return value;
      }
      double? maxVal;
      double? val;
      
      if(value is String){
        val = double.parse(value);
      }else{
        val = value;
      }
      if(max is String){
        maxVal = double.parse(max);
      }
      if(val!>maxVal!){
        return max;
      }
      return value;
    },
    "max":(value,List<dynamic>params){
      dynamic min = params[0];
      if(value==null){
        return value;
      }
      double? maxVal;
      double? val;
      
      if(value is String){
        val = double.parse(value);
      }else{
        val = value;
      }
      if(min is String){
        maxVal = double.parse(min);
      }
      if(val!<maxVal!){
        return min;
      }
      return value;
    }
  };

  static _isNumberic(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  static _isInt(String s){
    if(s==null){
      return false;
    }
    return int.tryParse(s) !=null;
  }
  
  static bool isListEqual(List a, List b) {
    if (a == b) return true;
    if (a == null || b == null || a.length != b.length) return false;
    int i = 0;
    return a.every((e) => b[i++] == e);
  }

}
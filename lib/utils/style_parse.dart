
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';

class StyleParse{

  static const double infinity = 9999999999;

  static convertAttr(attr){
    if (attr is Map) {
      return attr;
    }
    
    if(attr==null) {
      return null;
    }

    Map<String,dynamic> ret = {};
    var propertyList = attr.split(";");
    if(propertyList.isNotEmpty){
      propertyList.forEach((propertyStr) {
        propertyStr = propertyStr.trim();
        if(propertyStr.trim().isNotEmpty){
          RegExp re = RegExp(r"([^:]+):(.*)");
          var matches = re.allMatches(propertyStr).toList();

          if(matches.length==1){
            var key = matches[0].group(1);
            var val = matches[0].group(2)!.trim();
            try{
              val = json.decode(val);
            }catch(e){}

            var keys = key!.split("-");
            // 有子属性
            if(keys.length>1){
              StyleParse.initAttrMap(ret,keys,val);
            }else{
              ret[key]  = val;
            }
          }
        }
      });
    }

    if(ret.isEmpty){
      return attr;
    }
    
    return ret;
  }

  // 获取子属性
  static initAttrMap(map,keys,val){
    _initVal(_m,_k,_nk,_val){
      if(_m.containsKey(_k)){
        _m[_k][_nk] = _val;
      }else{
        Map<String,dynamic> subMap = {};
        subMap[_nk] = _val;
        _m[_k] = subMap;
      }
    }

    var j = 1;
    var max = keys.length-1;
    var data = map;
    for(var i=0;i<max;i++){
      if(j<max){
        _initVal(data, keys[i], keys[j], {});
      }else{
        _initVal(data, keys[i], keys[j], val);
      }
      j++;
      data = data[keys[i]];
    }
    return map;
  }

  static colorFilter( String colorFilter,{matrix,color,blendMode}){
    switch(colorFilter){
      case "linearToSrgbGamma":
        return const ColorFilter.linearToSrgbGamma();
      case "matrix":
        return ColorFilter.matrix(matrix);
      case "mode":
        return ColorFilter.mode(color,blendMode);
      case "srgbToLinearGamma":
        return const ColorFilter.srgbToLinearGamma();
    }
  }

  static matrix(str){
    var args = str.split(RegExp(r"[\s\t,]"));
    if(args.length==16){
      return Matrix4(
        double.parse(args[0].trim()), 
        double.parse(args[1].trim()), 
        double.parse(args[2].trim()), 
        double.parse(args[3].trim()), 
        double.parse(args[4].trim()), 
        double.parse(args[5].trim()), 
        double.parse(args[6].trim()), 
        double.parse(args[7].trim()), 
        double.parse(args[8].trim()),  
        double.parse(args[9].trim()), 
        double.parse(args[10].trim()), 
        double.parse(args[11].trim()), 
        double.parse(args[12].trim()), 
        double.parse(args[13].trim()), 
        double.parse(args[14].trim()), 
        double.parse(args[15].trim()), 
      );
    }
    return null;
    
  }

  static bool(String? boolstr){
    if(boolstr!=null && boolstr.trim()=="true"){
      return true;
    }else{
      return false;
    }
  }

  static textAlign(String textAlignString){
    TextAlign textAlign = TextAlign.left;
    switch (textAlignString) {
      case "left":
        textAlign = TextAlign.left;
        break;
      case "right":
        textAlign = TextAlign.right;
        break;
      case "center":
        textAlign = TextAlign.center;
        break;
      case "justify":
        textAlign = TextAlign.justify;
        break;
      case "start":
        textAlign = TextAlign.start;
        break;
      case "end":
        textAlign = TextAlign.end;
        break;
      default:
        textAlign = TextAlign.left;
    }
    return textAlign;
  }

  static textOverflow(String textOverflowString) {
    TextOverflow textOverflow = TextOverflow.ellipsis;
    switch (textOverflowString) {
      case "ellipsis":
        textOverflow = TextOverflow.ellipsis;
        break;
      case "clip":
        textOverflow = TextOverflow.clip;
        break;
      case "fade":
        textOverflow = TextOverflow.fade;
        break;
      default:
        textOverflow = TextOverflow.ellipsis;
    }
    return textOverflow;
  }

  static textDirection(String textDirectionString) {
    TextDirection textDirection = TextDirection.ltr;
    switch (textDirectionString) {
      case 'ltr':
        textDirection = TextDirection.ltr;
        break;
      case 'rtl':
        textDirection = TextDirection.rtl;
        break;
      default:
        textDirection = TextDirection.ltr;
    }
    return textDirection;
}

static hexColor(String? hexColorString) {
  if (hexColorString == null) {
    return null;
  }
  if(hexColorString.startsWith("#")){
    hexColorString = hexColorString.toUpperCase().replaceAll("#", "").replaceAll(RegExp(r";$"), "");
    if (hexColorString.length == 6) {
      hexColorString = "FF" + hexColorString;
    }
    int colorInt = int.parse(hexColorString, radix: 16);
    return Color(colorInt);
  }else if(hexColorString.startsWith("rgb")){
    // print(hexColorString);
    hexColorString = hexColorString.trim().replaceAll(RegExp(r"^rgba|rgb|\(|\)|;"), "");
    // print(hexColorString);
    if(hexColorString.isNotEmpty){
      dynamic rgba = hexColorString.split(",");
      dynamic red;
      dynamic green;
      dynamic blue;
      dynamic opacity = 255;
      if(rgba.length==3){
        red = int.parse(rgba[0].trim());
        green = int.parse(rgba[1].trim());
        blue = int.parse(rgba[2].trim());
      }else if(rgba.length==4){
        red = int.parse(rgba[0].trim());
        green = int.parse(rgba[1].trim());
        blue = int.parse(rgba[2].trim());
        opacity = (double.parse(rgba[3].trim())*255).toInt();
      }
      if(red !=null && blue !=null && green!=null && opacity!=null){
        red = red>255?255:red;
        green = green>255?255:green;
        blue = blue>255?255:blue;
        opacity = opacity>255?255:opacity;
        return Color.fromARGB(opacity,red,green,blue);
      }
    }
  }else{
    return StyleParse.nameColor(hexColorString);
  }
  return null;
}

static iconThemeData(Map<String,dynamic>map){
  return IconThemeData(
      color: map.containsKey("color")?hexColor(map['color']):null, //修改颜色
      opacity:map.containsKey("opacity")?double.parse(map['opacity']):1.0,
      size:map.containsKey("size")?double.parse(map['size']):null
  );
}

static nameColor(String name){
  switch(name){
    // case "scaffoldBg":
    //   var ctx = Tuna.getRootPage().context;
    //   return Theme.of(ctx).scaffoldBackgroundColor;
    // case "primary":
    //   var ctx = Tuna.getRootPage().context;
    //   return Theme.of(ctx).primaryColor;
    // case "accent":
    //   var ctx = Tuna.getRootPage().context;
    //   return Theme.of(ctx).accentColor;
    // case "bg":
    //   var ctx = Tuna.getRootPage().context;
    //   return Theme.of(ctx).backgroundColor;
    // case "bottomAppBar":
    //   var ctx = Tuna.getRootPage().context;
      // return Theme.of(ctx).bottomAppBarColor;
    case "accents":
      return Colors.accents;
    case "amber":
      return Colors.amber;
    case "amberAccent":
      return Colors.amberAccent;
    case "black":
      return Colors.black;
    case "black12":
      return Colors.black12;
    case "black26":
      return Colors.black26;
    case "black38":
      return Colors.black38;
    case "black45":
      return Colors.black45;
    case "black54":
      return Colors.black54;
    case "black87":
      return Colors.black87;
    case "blue":
      return Colors.blue;
    case "blueAccent":
      return Colors.blueAccent;
    case "blueGrey":
      return Colors.blueGrey;
    case "brown":
      return Colors.brown;
    case "cyan":
      return Colors.cyan;
    case "cyanAccent":
      return Colors.cyanAccent;
    case "deepOrange":
      return Colors.deepOrange;
    case "deepOrangeAccent":
      return Colors.deepOrangeAccent;
    case "deepPurple":
      return Colors.deepPurple;
    case "deepPurpleAccent":
      return Colors.deepPurpleAccent;
    case "green":
      return Colors.green;
    case "greenAccent":
      return Colors.greenAccent;
    case "grey":
      return Colors.grey;
    case "indigo":
      return Colors.indigo;
    case "indigoAccent":
      return Colors.indigoAccent;
    case "lightBlue":
      return Colors.lightBlue;
    case "lightBlueAccent":
      return Colors.lightBlueAccent;
    case "lightGreen":
      return Colors.lightGreen;
    case "lightGreenAccent":
      return Colors.lightGreenAccent;
    case "lime":
      return Colors.lime;
    case "limeAccent":
      return Colors.limeAccent;
    case "orange":
      return Colors.orange;
    case "orangeAccent":
      return Colors.orangeAccent;
    case "pink":
      return Colors.pink;
    case "pinkAccent":
      return Colors.pinkAccent;
    case "primaries":
      return Colors.primaries;
    case "purple":
      return Colors.purple;
    case "purpleAccent":
      return Colors.purpleAccent;
    case "red":
      return Colors.red;
    case "redAccent":
      return Colors.redAccent;
    case "teal":
      return Colors.teal;
    case "tealAccent":
      return Colors.tealAccent;
    case "transparent":
      return Colors.transparent;
    case "white":
      return Colors.white;
    case "white10":
      return Colors.white10;
    case "white12":
      return Colors.white12;
    case "white24":
      return Colors.white24;
    case "white30":
      return Colors.white30;
    case "white54":
      return Colors.white54;
    case "white60":
      return Colors.white60;
    case "white70":
      return Colors.white70;
    case "yellow":
      return Colors.yellow;
    case "yellowAccent":
      return Colors.yellowAccent;
  }
}


static textStyle(Map<String, dynamic>? map) {
  if(map==null){
    return null;
  }

  String? color =  map['color'];
  String? debugLabel = map['debugLabel'];

  String? fontFamily;
  double? fontSize;
  FontStyle? fontStyle;
  FontWeight? fontWeight;
  if(map.containsKey("font") && map["font"] is Map){
    var font = map["font"];
    fontFamily = font.containsKey("family")?font['family']:null;
    fontSize = font.containsKey('size')?double.parse(font['size']):14.0;
    fontStyle = 'italic' == font['style'] ? FontStyle.italic : FontStyle.normal;
    fontWeight = font.containsKey('weight')?StyleParse.fontWeight(font['weight']):null;
  }

  double? letterSpacing = map.containsKey("letterSpacing")?double.parse(map['letterSpacing']):null;
  double? wordSpacing = map.containsKey("wordSpacing")?double.parse(map['wordSpacing']):null;
  double? height = map.containsKey("line-height")?double.parse(map['line-height']):null;
  TextBaseline? textBaseline = map.containsKey("textBaseline")?StyleParse.textBaseline(map['textBaseline']):null;
  TextDecoration? decoration = map.containsKey("decoration")?StyleParse.textDecoration(map['decoration']):TextDecoration.none;
  double? decorationThickness = map.containsKey("decorationThickness")?double.parse(map['decorationThickness']):null;
  Color? decorationColor = map.containsKey("decorationColor")?StyleParse.hexColor(map['decorationColor']):null;
  TextDecorationStyle? decorationStyle = map.containsKey("decorationStyle")?StyleParse.decorationStyle(map['decorationStyle']):null;
  List<Shadow> shadows = <Shadow>[];
  
  // for shadow
  if(map.containsKey('shadows')){
    // shadow string like this: 0,0,1,#FF000000;0,0,1,#FF000000;0,0,1,#FF000000;0,0,1,#FF000000
    var _shadows = map['shadows'].split(";");
    if(_shadows.length==1){
      _shadows = [_shadows[0],_shadows[0],_shadows[0],_shadows[0]];
    }else if(_shadows.length==2){
      _shadows = [_shadows[0],_shadows[0],_shadows[1],_shadows[1]];
    }else if(_shadows.length==3){
      _shadows = [_shadows[0],_shadows[1],_shadows[1],_shadows[2]];
    }
    if(_shadows.length>0){
      _shadows.forEach((_shadow){
        shadows.add(StyleParse.shadow(_shadow));
      });
    }
  }

  return TextStyle(
      color: hexColor(color),
      debugLabel: debugLabel,
      fontSize: fontSize,
      fontFamily: fontFamily,
      fontStyle: fontStyle,
      shadows: shadows,
      fontWeight:fontWeight,
      letterSpacing:letterSpacing,
      textBaseline:textBaseline,
      height:height,
      wordSpacing: wordSpacing,
      decoration:decoration,
      decorationThickness:decorationThickness,
      decorationColor:decorationColor,
      decorationStyle:decorationStyle
    );
}

static textDecoration(String decoration){
  switch(decoration){
    case "through":
      return TextDecoration.lineThrough;
    case "overline":
      return TextDecoration.overline;
    case "underline":
      return TextDecoration.underline;
  }
  return TextDecoration.none;
}

static decorationStyle(String style) {
  switch(style){
    case "double":
      return TextDecorationStyle.double;
    case "dotted":
      return TextDecorationStyle.dotted;
    case "dashed":
      return TextDecorationStyle.dashed;
    case "wavy":
      return TextDecorationStyle.wavy;
  }
  return TextDecorationStyle.solid;
}

static textBaseline(String baseline){
  switch(baseline){
    case "alphabetic":
      return TextBaseline.alphabetic;
    case "ideographic":
      return TextBaseline.ideographic;
  }
  return null;
}

static fontWeight(String? weight){
  if(weight==null){
    return null;
  }
  switch(weight){
    case "bold":
      return FontWeight.bold;
    case "100":
      return FontWeight.w100;
    case "200":
      return FontWeight.w200;
    case "300":
      return FontWeight.w300;
    case "400":
      return FontWeight.w400;
    case "500":
      return FontWeight.w500;
    case "600":
      return FontWeight.w600;
    case "700":
      return FontWeight.w700;
    case "800":
      return FontWeight.w800;
    case "900":
      return FontWeight.w900;
  }
}

static boxShape(String shape){
  switch(shape){
    case "circle":
      return BoxShape.circle;
    case "rectangle":
      return BoxShape.rectangle;
  }
  return BoxShape.rectangle;
}


static borderRadius(String? radius){
  if(radius ==null || radius.trim().isEmpty){
    return null;
  }
  List _radius = radius.trim().split(RegExp(r"[\s\t,]+"));
  if(_radius.length==1){
    var trueRadius = double.parse(_radius[0]);
    return BorderRadius.all(new Radius.circular(trueRadius));
  }else if(_radius.length>1){
    var topleft = Radius.circular(double.parse(_radius[0]));
    var topright = Radius.circular(double.parse(_radius[1]));
    var bottomright = _radius.length>2?Radius.circular(double.parse(_radius[2])):Radius.zero;
    var bottomleft = _radius.length>3?Radius.circular(double.parse(_radius[3])):Radius.zero;
    return BorderRadius.only(
      topLeft: topleft, 
      topRight: topright, 
      bottomLeft: bottomleft, 
      bottomRight: bottomright
    );
  }
}

static shadow(String shadowString){

  var offset = [0.0,0.0];
  var blurRadius = 1.0;
  var scolor = Color(0XFF000000);
  var shadowValue = shadowString.split(RegExp(r"[\s\t,]+"));
  var vLen = shadowValue.length;

  if(vLen>=1){
    offset[0] = double.parse(shadowValue[0]);
    if(vLen>=2){
      offset[1] = double.parse(shadowValue[1]);
    }
    if(vLen>=3){
      blurRadius = double.parse(shadowValue[2]);
    }
    if(vLen>=4){
      scolor = hexColor(shadowValue[3]);
    }
  }
  return Shadow(
    offset: Offset(offset[0], offset[1]),
    blurRadius: blurRadius,
    color: scolor,
  );

}

static offset(offset){
  if(offset!=null){
    var dl = offset.splig(RegExp(r"[\s\t,]+"));
    if(dl.length==2){
      return Offset(double.parse(dl[0].trim()), double.parse(dl[1].trim()));
    }
  }
  return null;
}


static placeHolderAlign(String alignVal){
  switch(alignVal){
    case 'aboveBaseline':
      return PlaceholderAlignment.aboveBaseline;
    case 'baseline':
      return PlaceholderAlignment.baseline;
    case 'top':
      return PlaceholderAlignment.top;
    case 'middle':
      return PlaceholderAlignment.middle;
    
    case 'belowBaseline':
      return PlaceholderAlignment.belowBaseline;
    case 'bottom':
    default:
      return PlaceholderAlignment.bottom;
  }
}

static alignment(String alignmentString) {
  Alignment alignment = Alignment.topLeft;
  switch (alignmentString) {
    case 'topLeft':
      alignment = Alignment.topLeft;
      break;
    case 'topCenter':
      alignment = Alignment.topCenter;
      break;
    case 'topRight':
      alignment = Alignment.topRight;
      break;
    case 'centerLeft':
      alignment = Alignment.centerLeft;
      break;
    case 'center':
      alignment = Alignment.center;
      break;
    case 'centerRight':
      alignment = Alignment.centerRight;
      break;
    case 'bottomLeft':
      alignment = Alignment.bottomLeft;
      break;
    case 'bottomCenter':
      alignment = Alignment.bottomCenter;
      break;
    case 'bottomRight':
      alignment = Alignment.bottomRight;
      break;
  }
  return alignment;
}

static indicatorSize(String sizeType){
    if(sizeType=='label'){
      return TabBarIndicatorSize.label;
    }
    if(sizeType=='tab'){
      return TabBarIndicatorSize.tab;
    }
  }

static boxConstraints(Map<String, dynamic>? map) {
  double minWidth = 0.0;
  double maxWidth = double.infinity;
  double minHeight = 0.0;
  double maxHeight = double.infinity;

  if (map != null) {
    if (map.containsKey('minWidth')) {
      dynamic minWidthValue = double.parse(map['minWidth']);

      if (minWidthValue != null) {
        if (minWidthValue >= infinity) {
          minWidth = double.infinity;
        } else {
          minWidth = minWidthValue;
        }
      }
    }

    if (map.containsKey('maxWidth')) {
      dynamic maxWidthValue = double.parse(map['maxWidth']);

      if (maxWidthValue != null) {
        if (maxWidthValue >= infinity) {
          maxWidth = double.infinity;
        } else {
          maxWidth = maxWidthValue;
        }
      }
    }

    if (map.containsKey('minHeight')) {
      dynamic minHeightValue = double.parse(map['minHeight']);

      if (minHeightValue != null) {
        if (minHeightValue >= infinity) {
          minHeight = double.infinity;
        } else {
          minHeight = minHeightValue;
        }
      }
    }

    if (map.containsKey('maxHeight')) {
      dynamic maxHeightValue = double.parse(map['maxHeight']);

      if (maxHeightValue != null) {
        if (maxHeightValue >= infinity) {
          maxHeight = double.infinity;
        } else {
          maxHeight = maxHeightValue;
        }
      }
    }
  }else{
    return null;
  }

  return BoxConstraints(
    minWidth: minWidth,
    maxWidth: maxWidth,
    minHeight: minHeight,
    maxHeight: maxHeight,
  );
}

static boxDecoration(Map<String,dynamic>? map){
    if(map==null){
      return  null;
    }
    dynamic radius;
    if (map.containsKey('radius')) {
      String radiu = map['radius'];
      var doubles = radiu.split(RegExp(r"[\s\t,]+"));
      if (doubles.length > 1) {
        radius = BorderRadius.only(
            topLeft:  Radius.circular(double.parse(doubles[0])),
            topRight: Radius.circular(double.parse(doubles[1])),
            bottomRight:  Radius.circular(double.parse(doubles[2])),
            bottomLeft:  Radius.circular(double.parse(doubles[3])));

      } else {
        radius = BorderRadius.all(Radius.circular(double.parse(map['radius'])));
      }
    }
    return BoxDecoration(
      image:StyleParse.decorationImage(map['image']),
      borderRadius:radius,
      color: map.containsKey('color')
        ? hexColor(map['color'])
        : null,
      border: StyleParse.border(map['border']),
      gradient: map.containsKey('gradient')?StyleParse.gradient(map['gradient']):null,
      boxShadow: map.containsKey('boxShadow')?StyleParse.boxShadow(map['boxShadow']):null,
     );
}


static boxShadow(boxShadow) {
  List<BoxShadow> shadows = [];

  _createBoxShadow(map) {
    var offsetList = StyleParse.doubleList(map["offset"]);
    var offset;
    if (offsetList != null && offsetList.length >= 2) {
      offset = Offset(offsetList[0], offsetList[1]);
    } else {
      offset = Offset.zero;
    }
    return BoxShadow(
        color: map.containsKey('color')
            ? hexColor(map['color'])
            : Color(0xFF000000),
        offset: offset,
        blurRadius: map.containsKey("blurRadius")
            ? double.parse(map["blurRadius"])
            : 0.0,
        spreadRadius: map.containsKey("spreadRadius")
            ? double.parse(map["spreadRadius"])
            : 0.0);
  }

  if (boxShadow is Map) {
    shadows.add(_createBoxShadow(boxShadow));
  } else if (boxShadow is List) {
    boxShadow.forEach((f) {
      shadows.add(_createBoxShadow(f));
    });
  }

  return shadows.length > 0 ? shadows : null;
}

static gradient(Map<String, dynamic>? gradient) {
  
  if (gradient!=null && gradient.containsKey("type")) {
    switch (gradient["type"]) {
      case "radial":
        return StyleParse.radialGradient(gradient);
      case "linear":
        return StyleParse.linearGradient(gradient);
    }
  }
  return null;
}

//线性渐变
static linearGradient(Map<String, dynamic> gradient) {
  var colors = StyleParse.colorsList(gradient['colors']);
  if (colors != null && colors.length > 0) {
    return LinearGradient(
      stops: StyleParse.doubleList(gradient['stops']),
      begin: gradient.containsKey("begin")
          ? StyleParse.alignment(gradient["begin"])
          : Alignment.topCenter,
      end: gradient.containsKey("end")
          ? StyleParse.alignment(gradient["end"])
          : Alignment.bottomCenter,
      colors: colors,
    );
  } else {
    return null;
  }
}

//圆角阴影
static radialGradient(Map<String, dynamic> gradient) {
  var colors = StyleParse.colorsList(gradient['colors']);
  if (colors != null && colors.length > 0) {
    var center = gradient.containsKey('center')
        ? gradient['center'].split(RegExp(r"[\s\t,]+"))
        : ["-0.5", "-0.5"];
    return RadialGradient(
      center: Alignment(
          double.parse(center[0].trim()), double.parse(center[1].trim())),
      radius: gradient.containsKey('radius')
          ? double.parse(gradient['radius'])
          : 0.5,
      colors: StyleParse.colorsList(gradient['colors']),
      stops: StyleParse.doubleList(gradient['stops']),
    );
  } else {
    return null;
  }
}

static doubleList(doubleStrings) {
  if (doubleStrings != null) {
    List<double> doubleList = [];
    doubleStrings.split(RegExp(r"[\s\t,]+")).forEach((f) {
      doubleList.add(double.parse(f.trim()));
    });
    return doubleList;
  } else {
    return null;
  }
}

static colorsList(colors) {
  if (colors != null) {
    List<Color> retColors = [];
    colors.split(RegExp(r"[\s\t,]+")).forEach((f) {
      retColors.add(hexColor(f));
    });
    if (retColors.length > 0) {
      return retColors;
    }
  }
  return null;
}

static iconData(code,{fontFamily,name}){
    if(code!=null){
      code = int.parse(code.toString());
    }
    return IconData(
      code,
      fontFamily: fontFamily==null?'MaterialIcons':fontFamily,
    );
}

static decorationImage(String? image){
  if(image==null || image.isEmpty){
    return null;
  }
 
  image = image.trim();
  List imageStyle = image.split(RegExp(r"[\s\t]+"));

  if(imageStyle.length==1){
    imageStyle.add('cover');
  }
  String imagePath = imageStyle[0];

  imagePath = imagePath.replaceAll("url(","");
  imagePath = imagePath.replaceAll(RegExp(r"\)$"),"");
  var img;
  RegExp  isNet = RegExp(r"^http");
  if(isNet.hasMatch(imagePath)){
    img = NetworkImage(imagePath);
  }else{
    img = AssetImage(imagePath);
  }

  return DecorationImage(
    image : img,
    fit: StyleParse.boxFit(imageStyle[1]),
    alignment:imageStyle.length>2 ? alignment(imageStyle[2]) : Alignment.center,
    repeat: imageStyle.length>3 ? StyleParse.imageRepeat(imageStyle[3]) : ImageRepeat.noRepeat,
    matchTextDirection:imageStyle.length>4 ? imageStyle[4] : false
  );
}


static border(border){

  if(border is String){
    var _border  =  StyleParse.borderStyle(border);
    if(_border!=null){
      return Border(
        top:BorderSide(width:_border['width'],color:_border['color']),
        left:BorderSide(width:_border['width'],color:_border['color']),
        right:BorderSide(width:_border['width'],color:_border['color']),
        bottom:BorderSide(width:_border['width'],color:_border['color'])
      );
    }
  }else if(border is Map){
    
    var top;
    var left;
    var right;
    var bottom;

    if(border.containsKey('top')){
      top  = StyleParse.borderStyle(border['top']);
    }else{
      top = {"width":0.0,"color":Colors.transparent,"style":BorderStyle.none};
    }
    if(border.containsKey('bottom')){
      bottom  = StyleParse.borderStyle(border['bottom']);
    }else{
      bottom = {"width":0.0,"color":Colors.transparent,"style":BorderStyle.none};
    }
    if(border.containsKey('left')){
      left  = StyleParse.borderStyle(border['left']);
    }else{
      left = {"width":0.0,"color":Colors.transparent,"style":BorderStyle.none};
    }
    if(border.containsKey('right')){
      right  = StyleParse.borderStyle(border['right']);
    }else{
      right = {"width":0.0,"color":Colors.transparent,"style":BorderStyle.none};
    }

    if(top==null && left==null && right==null && bottom==null){
      return null;
    }
    
    return  Border(
      top: BorderSide(width: top['width'], color: top['color']),
      left: BorderSide(width: left['width'], color: left['color']),
      right: BorderSide(width: right['width'], color: right['color']),
      bottom: BorderSide(width: bottom['width'], color: bottom['color']),
    );
  }

  return null;
}

static borderStyle(String borderString){
  RegExp  reg = RegExp(r"[\s\t,]+");
  List style = borderString.split(reg);
  if(style.length>1){
    var width = style[0].trim();
    var color = style[1].trim();
    return {
      "width":double.parse(width),
      "color":hexColor(color)
    };
  }
}


static controlAffinity(String controlAffinity){
  switch(controlAffinity){
    case "leading":
      return ListTileControlAffinity.leading;
      // break;
    case "platform":
      return ListTileControlAffinity.platform;
      // break;
    case "trailing":
      return ListTileControlAffinity.trailing;
      // break;
  }
}


static edgeInsetsGeometry(String? edgeInsetsGeometryString) {
  //left,top,right,bottom
  if (edgeInsetsGeometryString == null ||
      edgeInsetsGeometryString.trim() == '') {
    return null;
  }
  var values = edgeInsetsGeometryString.split(RegExp("[\s\t,]+"));
  if(values.length==1){
    return  EdgeInsets.all(double.parse(values[0]));
  }else if(values.length==2){
    return EdgeInsets.only(
      top: double.parse(values[0]),
      right: double.parse(values[1]),
      bottom: double.parse(values[0]),
      left: double.parse(values[1]),
    );
  }else if(values.length==3){
    return EdgeInsets.only(
      top: double.parse(values[0]),
      right: double.parse(values[1]),
      bottom: double.parse(values[2]),
      left: double.parse(values[1]),
    );
  }else{
    return EdgeInsets.only(
      top: double.parse(values[0]),
      right: double.parse(values[1]),
      bottom: double.parse(values[2]),
      left: double.parse(values[3]),
    );
  }
}

static crossAxisAlignment(String crossAxisAlignmentString) {
  switch (crossAxisAlignmentString) {
    case 'start':
      return CrossAxisAlignment.start;
    case 'end':
      return CrossAxisAlignment.end;
    case 'center':
      return CrossAxisAlignment.center;
    case 'stretch':
      return CrossAxisAlignment.stretch;
    case 'baseline':
      return CrossAxisAlignment.baseline;
  }
  return CrossAxisAlignment.center;
}

static mainAxisAlignment(String mainAxisAlignmentString) {
  switch (mainAxisAlignmentString) {
    case 'start':
      return MainAxisAlignment.start;
    case 'end':
      return MainAxisAlignment.end;
    case 'center':
      return MainAxisAlignment.center;
    case 'spaceBetween':
      return MainAxisAlignment.spaceBetween;
    case 'spaceAround':
      return MainAxisAlignment.spaceAround;
    case 'spaceEvenly':
      return MainAxisAlignment.spaceEvenly;
  }
  return MainAxisAlignment.start;
}

static mainAxisSize(String mainAxisSizeString) =>
    mainAxisSizeString == 'min' ? MainAxisSize.min : MainAxisSize.max;

static verticalDirection(String verticalDirectionString) =>
    'up' == verticalDirectionString
        ? VerticalDirection.up
        : VerticalDirection.down;

static blendMode(String? blendModeString) {
  if (blendModeString == null || blendModeString.trim().length == 0) {
    return null;
  }

  switch (blendModeString.trim()) {
    case 'clear':
      return BlendMode.clear;
    case 'src':
      return BlendMode.src;
    case 'dst':
      return BlendMode.dst;
    case 'srcOver':
      return BlendMode.srcOver;
    case 'dstOver':
      return BlendMode.dstOver;
    case 'srcIn':
      return BlendMode.srcIn;
    case 'dstIn':
      return BlendMode.dstIn;
    case 'srcOut':
      return BlendMode.srcOut;
    case 'dstOut':
      return BlendMode.dstOut;
    case 'srcATop':
      return BlendMode.srcATop;
    case 'dstATop':
      return BlendMode.dstATop;
    case 'xor':
      return BlendMode.xor;
    case 'plus':
      return BlendMode.plus;
    case 'modulate':
      return BlendMode.modulate;
    case 'screen':
      return BlendMode.screen;
    case 'overlay':
      return BlendMode.overlay;
    case 'darken':
      return BlendMode.darken;
    case 'lighten':
      return BlendMode.lighten;
    case 'colorDodge':
      return BlendMode.colorDodge;
    case 'colorBurn':
      return BlendMode.colorBurn;
    case 'hardLight':
      return BlendMode.hardLight;
    case 'softLight':
      return BlendMode.softLight;
    case 'difference':
      return BlendMode.difference;
    case 'exclusion':
      return BlendMode.exclusion;
    case 'multiply':
      return BlendMode.multiply;
    case 'hue':
      return BlendMode.hue;
    case 'saturation':
      return BlendMode.saturation;
    case 'color':
      return BlendMode.color;
    case 'luminosity':
      return BlendMode.luminosity;

    default:
      return BlendMode.srcIn;
  }
}

static boxFit(String? boxFitString) {
  if (boxFitString == null) {
    return null;
  }

  switch (boxFitString) {
    case 'fill':
      return BoxFit.fill;
    case 'contain':
      return BoxFit.contain;
    case 'cover':
      return BoxFit.cover;
    case 'fitWidth':
      return BoxFit.fitWidth;
    case 'fitHeight':
      return BoxFit.fitHeight;
    case 'none':
      return BoxFit.none;
    case 'scaleDown':
      return BoxFit.scaleDown;
  }

  return null;
}

static flexFit(String? flexFixString) {
  if (flexFixString == null) {
    return null;
  }

  switch (flexFixString) {
    case 'loose':
      return FlexFit.loose;
    case 'tight':
      return FlexFit.tight;
  }

  return null;
}

static imageRepeat(String? imageRepeatString) {
  if (imageRepeatString == null) {
    return null;
  }

  switch (imageRepeatString) {
    case 'repeat':
      return ImageRepeat.repeat;
    case 'repeatX':
      return ImageRepeat.repeatX;
    case 'repeatY':
      return ImageRepeat.repeatY;
    case 'noRepeat':
      return ImageRepeat.noRepeat;

    default:
      return ImageRepeat.noRepeat;
  }
}

static rect(String fromLTRBString) {
  var strings = fromLTRBString.split(',');
  return Rect.fromLTRB(double.parse(strings[0]), double.parse(strings[1]),
      double.parse(strings[2]), double.parse(strings[3]));
}

static clipRRect(rrect){
  if(rrect is String){
    rrect = double.parse(rrect);
    return {
      "all":rrect
    };
  }else if(rrect is Map){
    return rrect;
  }
}


static paintingStyle(style){
  switch(style){
    case "fill":
      return PaintingStyle.fill;
    case "stroke":
    default:
      return PaintingStyle.stroke;
  }
}

static strokeCap(String strokeCap){
  switch(strokeCap){
    case "round":
      return StrokeCap.round;
    case "square":
      return StrokeCap.square;
    case "butt":
    default:
      return StrokeCap.butt;
  }
}

static strokeJoin(String strokeJoin){
  switch(strokeJoin){
    case "round":
      return StrokeJoin.round;
    case "miter":
      return StrokeJoin.miter;
    case "bevel":
    default:
      return StrokeJoin.bevel;
  }
}

static filterQuality(String? filterQualityString) {
  if (filterQualityString == null) {
    return null;
  }
  switch (filterQualityString) {
    case 'none':
      return FilterQuality.none;
    case 'low':
      return FilterQuality.low;
    case 'medium':
      return FilterQuality.medium;
    case 'high':
      return FilterQuality.high;
    default:
      return FilterQuality.low;
  }
}

static stackFit(String? value) {
  if (value == null) return null;

  switch (value) {
    case 'loose':
      return StackFit.loose;
    case 'expand':
      return StackFit.expand;
    case 'passthrough':
      return StackFit.passthrough;
    default:
      return StackFit.loose;
  }
}

// static overflow(String? value) {
//   if (value == null) {
//     return null;
//   }

//   switch (value) {
//     case 'visible':
//       return Overflow.visible;
//     case 'clip':
//       return Overflow.clip;
//     default:
//       return Overflow.clip;
//   }
// }

static axis(String? axisString) {
  if (axisString == null) {
    return Axis.horizontal;
  }

  switch (axisString) {
    case "horizontal":
      return Axis.horizontal;
    case "vertical":
      return Axis.vertical;
  }
  return Axis.horizontal;
}

//WrapAlignment
static wrapAlignment(String? wrapAlignmentString) {
  if (wrapAlignmentString == null) {
    return WrapAlignment.start;
  }

  switch (wrapAlignmentString) {
    case "start":
      return WrapAlignment.start;
    case "end":
      return WrapAlignment.end;
    case "center":
      return WrapAlignment.center;
    case "spaceBetween":
      return WrapAlignment.spaceBetween;
    case "spaceAround":
      return WrapAlignment.spaceAround;
    case "spaceEvenly":
      return WrapAlignment.spaceEvenly;
  }
  return WrapAlignment.start;
}

//WrapCrossAlignment
static wrapCrossAlignment(String? wrapCrossAlignmentString) {
  if (wrapCrossAlignmentString == null) {
    return WrapCrossAlignment.start;
  }

  switch (wrapCrossAlignmentString) {
    case "start":
      return WrapCrossAlignment.start;
    case "end":
      return WrapCrossAlignment.end;
    case "center":
      return WrapCrossAlignment.center;
  }

  return WrapCrossAlignment.start;
}

static clipBehavior(String? clipBehaviorString){
  if (clipBehaviorString == null) {
    return Clip.antiAlias;
  }
  switch(clipBehaviorString) {
    case "antiAlias":
      return Clip.antiAlias;
    case "none":
      return Clip.none;
    case "hardEdge":
      return Clip.hardEdge;
    case "antiAliasWithSaveLayer":
      return Clip.antiAliasWithSaveLayer;
  }
  return Clip.antiAlias;
}

static actionBtnLocation(String location){
  switch(location){
    case "centerDocked":
      return FloatingActionButtonLocation.centerDocked;
    case "centerFloat":
      return FloatingActionButtonLocation.centerFloat;
    case "endDocked":
      return FloatingActionButtonLocation.endDocked;
    case "endFloat":
      return FloatingActionButtonLocation.endFloat;
    case "endTop":
      return FloatingActionButtonLocation.endTop;
    case "miniStartTop":
      return FloatingActionButtonLocation.miniStartTop;
    case "startTop":
      return FloatingActionButtonLocation.startTop;
  }
}

static bottomNavigationBarType(String? type){
  if(type==null){
    return BottomNavigationBarType.fixed;
  }
  switch(type){
    case 'shifting':
      return BottomNavigationBarType.shifting;
    default:
      return BottomNavigationBarType.fixed;
  }
}


static collapseMode(String? mode){
  if(mode==null){
    return CollapseMode.none;
  }
  switch(mode){
    case "parallax":
      return CollapseMode.parallax;
    case "pin":
      return CollapseMode.pin;
    default:
      return CollapseMode.none;
  }
}

  static brightness(String type){
      switch(type){
        case 'light':
          return Brightness.light;
        case 'dark':
          return Brightness.dark;
      }
  }

  static TextInputType  keyboardType(String? inputType){
    switch(inputType){
      case "datetime":
        return TextInputType.datetime;
      case "emailAddress":
        return TextInputType.emailAddress;
      case "multiline":
        return TextInputType.multiline;
      case "number":
        return TextInputType.number;
      case "phone":
        return TextInputType.phone;
      case "text":
        return TextInputType.text;
      case "url":
        return TextInputType.url;
      case "number_signed":
        return TextInputType.numberWithOptions(signed:true);
      case "number_decimal":
        return TextInputType.numberWithOptions(decimal:true);
      case "name":
        return TextInputType.name;
    }
    return TextInputType.text;
  }

  static TextInputAction inputAction(String action){
    switch(action){
      case "done":
        return TextInputAction.done;
      case "emergencyCall":
        return TextInputAction.emergencyCall;
      case "go":
        return TextInputAction.go;
      case "join":
        return TextInputAction.join;
      case "newline":
        return TextInputAction.newline;
      case "next":
        return TextInputAction.next;
      case "none":
        return TextInputAction.none;
      case "previous":
        return TextInputAction.previous;
      case "route":
        return TextInputAction.route;
      case "search":
        return TextInputAction.search;
      case "send":
        return TextInputAction.send;
      case "unspecified":
        return TextInputAction.unspecified;
    }
    return TextInputAction.done;
  }

  static textCapitalization(type){
    switch(type){
      case "words":
        return TextCapitalization.words;
      case "sentences":
        return TextCapitalization.sentences;
      case "characters":
        return TextCapitalization.characters;
      case "none":
      default:
        return TextCapitalization.none;
    }
  }

}
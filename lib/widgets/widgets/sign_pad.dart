import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:html/dom.dart' as dom;
import 'package:signature/signature.dart';
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/utils/style_parse.dart';

import '../widget.dart';

class TWidgetSignPad extends TStyleWidget{
  
  TWidgetSignPad():super(tagName: 'signPad');

  @override
  build(dom.Element node, JsRuntime jsRuntime, {TStyleSheet? styleSheet}) { 
    Map<String,dynamic> attrs = getAttributes(node);
    double strokeWidth = attrs["stroke"]==null?2.0:double.parse(attrs['stroke']);
    double? width = attrs["width"]==null?null:double.parse(attrs['width']);
    double? height = attrs["height"]==null?null:double.parse(attrs['height']);
    Color color = attrs['color']==null?Colors.black:StyleParse.hexColor(attrs['color']);
    Color bgColor = attrs['color']==null?Colors.transparent:StyleParse.hexColor(attrs['color']);
    String? name = attrs['name'];
    dynamic signKey;

    String? onSign = attrs['onSign'];

    if(name!=null){
      signKey = GlobalKey(debugLabel: name);
    }

    final SignatureController _controller = SignatureController(
      penStrokeWidth: strokeWidth,
      penColor: color,
      exportBackgroundColor: bgColor,
      onDrawStart: () => print('onDrawStart called!'),
      onDrawEnd: onSign!=null?()async{
          try{
            var image = signKey.currentState.getData();
            var data = await image.toByteData(format: ui.ImageByteFormat.png);
            final encoded = base64.encode(data.buffer.asUint8List());
            jsRuntime.evaluateFunc(onSign, encoded);
          }catch(e){
            print(e);
          }
        }:null,
    );
    
    Signature ret = Signature(
      key: signKey,
      backgroundColor: bgColor,
      controller: _controller,
      width: width,
      height: height,
    );

    if(name!=null){
      jsRuntime.addWidgetMessageHandle("SignPad",name, (params)async {
        if(params is Map && params.containsKey("method")){
          var method = params['method'];
          // var data = params['data'];
          switch(method){
            case "clear":
              signKey.currentState.clear();
              return true;
            case "getData":
              return await signKey.currentState.getData();
            case "hasPoints":
              return signKey.currentState.hasPoints();
            case "points":
              return signKey.currentState.points;
          }
        }
      });
    }
    return ret;
  }
}

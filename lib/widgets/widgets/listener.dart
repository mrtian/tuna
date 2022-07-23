import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import '../../tuna3.dart';
import '../widget.dart';

class TWidgetListener extends TWidget{
  
  TWidgetListener():super(tagName:['pointor','notifiView']);
  
  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}){
    var attrs = getAttributes(node);
    var pointDown = attrs['pointDown'];
    var pointUp = attrs["pointUp"];
    var pointCancel = attrs["pointUp"];
    var pointSignal = attrs["pointSignal"];
    var pointMove = attrs["pointMove"];
    
    var child = Tuna3.parseWidget(node.children[0], jsRuntime,styleSheet: styleSheet);
    
    _callPointer(fnName,event){
      var detail = {
        "id":event.pointer,
        "position":event.position==null?{}:{
          "x":event.position.dx,
          "y":event.position.dy
        },
        "localPosition": event.localPosition==null?{}:{
          "x":event.localPosition.dx,
          "y":event.localPosition.dy
        },
        "offset":event.position==null?null:[event.position.dx,event.position.dy],
        "localOffset":event.localPosition==null?null:[event.localPosition.dx,event.localPosition.dy]
      };
      jsRuntime.evaluateFunc(fnName, detail);
      
    }
    return Listener(
      onPointerDown:pointDown!=null?(event){
        _callPointer(pointDown,event);
      }:null,
      onPointerUp:pointUp!=null?(event){
        _callPointer(pointUp,event);
      }:null,
      onPointerCancel:pointCancel!=null?(event){
        _callPointer(pointCancel,event);
      }:null,
      onPointerSignal:pointSignal!=null?(event){
        _callPointer(pointSignal,event);
      }:null,
      onPointerMove:pointMove!=null?(event){
        _callPointer(pointMove,event);
      }:null,
      child: child,
    );
    
  }

}
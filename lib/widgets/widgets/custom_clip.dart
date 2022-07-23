import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import '../../tuna3.dart';
import '../widget.dart';

class TWidgetClipPath extends TWidget{
  
  TWidgetClipPath():super(tagName: ['clipPath','cclip']);

  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}){
    var attrs = getAttributes(node);
    var offsets = attrs.containsKey("path")?attrs['path']:null;
    var start = attrs.containsKey("start")?attrs['start']:"0,0";
    var startOffset = start.split(",");

    if(offsets!=null && startOffset.length==2){
      var paths = offsets.split(";");
      if(paths.length>0){
        return ClipPath(
          clipper:TunaCoustomClipper(Offset(double.parse(startOffset[0]),double.parse(startOffset[1])),paths),
          child: Tuna3.parseWidget( node.children[0],jsRuntime,styleSheet: styleSheet),
        );
      }
    }
  }
}

class TunaCoustomClipper extends CustomClipper<Path> {
  
  final List linesTo;
  final Offset start;

  TunaCoustomClipper(this.start, this.linesTo);

  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.moveTo(start.dx, start.dy);
    linesTo.forEach((offset) {
      if(offset is String){
        offset = offset.trim().split(",");
      }
      if(offset is List && offset.length>2){
        var act = offset[0].trim();
        if(act=="bezier" && offset.length==5){
          path.quadraticBezierTo(double.parse(offset[1].trim()),double.parse(offset[2].trim()),double.parse(offset[3].trim()),double.parse(offset[4].trim()));
        }else if(act=='cubic' && offset.length==7){
          path.cubicTo(double.parse(offset[1]),double.parse(offset[2].trim()),double.parse(offset[3].trim()),double.parse(offset[4].trim()),double.parse(offset[5].trim()),double.parse(offset[6].trim()));
        }else if(act=="move"){
          path.moveTo(double.parse(offset[1].trim()), double.parse(offset[2].trim()));
        }else {
          path.lineTo(double.parse(offset[1].trim()), double.parse(offset[2].trim()));
        }
      }
    });
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
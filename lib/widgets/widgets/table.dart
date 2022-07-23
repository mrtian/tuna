import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/utils/style_parse.dart';
import '../../js_runtime.dart';
import '../../style_sheet.dart';
import '../widget.dart';

class TWidgetTable extends TStyleWidget{

  TWidgetTable():super(tagName: 'table');

  @override
  build(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}) {

    Map<String,dynamic> attrs = getAttributes(node);
    List children = node.children;
    List<TableRow> _children = [];
    Map<int, TableColumnWidth> widthsnode = {};

    if(children.isNotEmpty && children.isNotEmpty){
      children.forEach((item){
        if(item.localName=="tr"){
          _children.add(TunaTableRowWidget.parse(item, getAttributes(item), jsRuntime,styleSheet: styleSheet));
        }
      });
    }

    if(attrs.containsKey("widths") && attrs['widths'].isNotEmpty){
      List widths = attrs['widths'].split(RegExp(r"[\s\t,]"));
      if(widths.isNotEmpty){
        var i = 0;
        widths.forEach((width) {
          if(width=="auto"){
            widthsnode[i] = const FlexColumnWidth();
          }else{
            widthsnode[i] = FixedColumnWidth(double.parse(width));
          }
          i++;
        });
      }
    }

    return Table(
      columnWidths: widthsnode,
      // defaultColumnWidth:FlexColumnWidth(1.0),
      border:attrs.containsKey("border")?parseTableBorder(attrs['border']):null,
      children: _children,
    );
    
  }

  parseTableBorder(String border){
    var _border = StyleParse.convertAttr(border);
    if(_border is String ){
      var bside = parseSingleBorder(_border);
      return TableBorder.all(color: bside["color"],width: bside["width"],style: bside["style"]);
    }else if(_border is Map){
      var top;
      var left;
      var right;
      var bottom;
      var vertical;
      var horizontal;

      _border.forEach((key, value) {
        var bside = parseSingleBorder(value);
        var borderSide = BorderSide(color: bside["color"],width: bside["width"],style: bside["style"]);
        
        if(key=="left"){
          left = borderSide;
        }
        if(key=="right"){
          right = borderSide;
        }
        if(key=="top"){
          top = borderSide;
        }
        if(key=="bottom"){
          bottom = borderSide;
        }
        if(key=="vertical"){
          vertical = borderSide;
        }
        if(key=="horizontal"){
          horizontal = borderSide;
        }
      });
      return TableBorder(
        top: top ?? BorderSide.none,
        left: left ?? BorderSide.none,
        right: right ?? BorderSide.none,
        bottom: bottom ?? BorderSide.none,
        horizontalInside:horizontal ?? BorderSide.none,
        verticalInside:vertical ?? BorderSide.none,
      );
    }
  }

  parseSingleBorder(String val){
    List _blist = val.split(RegExp(r"[\t\s,]"));
    dynamic borderSide;
    if(_blist.isNotEmpty){
      var width = double.parse(_blist[0]);
      var style = _blist.length>1?  parseBorderStyle(_blist[1]):BorderStyle.solid;
      var color = _blist.length>2? StyleParse.hexColor( _blist[2] ):null;
      borderSide = {
        "width":width,
        "color":color,
        "style":style
      };
    }
    return borderSide;
  }
  parseBorderStyle(String style){
    switch(style){
      case "none":
        return BorderStyle.none;
      case 'solid':
      default:
        return BorderStyle.solid;
    }
  }
  
}

class TunaTableRowWidget{
  static parse(dom.Element node,Map<String,dynamic> attrs,JsRuntime jsRuntime,{TStyleSheet? styleSheet}) {
    List children = node.children;
    List<Widget> _children = [];

    if(children.isNotEmpty && children.isNotEmpty){
      children.forEach((item){
        var ret = Tuna3.parseWidget(node, jsRuntime,styleSheet: styleSheet);
        if(ret is List){
          ret.forEach((itm){
            _children.add(itm);
          });
        }else{
          _children.add(ret);
        }
      });
    }
    return TableRow(
      decoration:attrs.containsKey("decoration")?StyleParse.boxDecoration(attrs['decoration']):null,
      children: _children
    );
  }
}
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/utils/style_parse.dart';
import '../../js_runtime.dart';
import '../../style_sheet.dart';
import '../constants.dart';
import '../widget.dart';

class TWidgetStack extends TWidget {

  TWidgetStack():super(tagName: 'stack');

  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}){
    Map<String,dynamic> attrs = getAttributes(node);
    
    List<Widget> _children = Tuna3.parseWidgets(node.children, jsRuntime,styleSheet: styleSheet);
    
    
    return Stack(
        alignment:  attrs.containsKey(AttrNames.alignment)
            ? StyleParse.alignment(attrs[AttrNames.alignment])
            : AlignmentDirectional.topStart,
        textDirection:  attrs.containsKey(AttrNames.textDirection)
            ? StyleParse.textDirection(attrs[AttrNames.textDirection])
            : null,
        // size:,
        fit: attrs.containsKey(AttrNames.fit) ? StyleParse.stackFit(attrs[AttrNames.fit]) : StackFit.loose,
        clipBehavior: attrs['overflow']=='visible'? Clip.none:Clip.hardEdge,
        children: _children,
    );
  }
}

class TWidgetPositioned extends TWidget{
  
  TWidgetPositioned():super(tagName: 'positioned');

  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}){ 
    Map<String,dynamic> attrs = getAttributes(node);
    dynamic child;
    if(node.children.isNotEmpty){
      child = Tuna3.parseWidget(node.children[0], jsRuntime,styleSheet: styleSheet);
    }
    return Positioned(
      child: child,
      top: attrs.containsKey(AttrNames.top) ? double.parse(attrs[AttrNames.top]) : null,
      right: attrs.containsKey(AttrNames.right) ? double.parse(attrs[AttrNames.right]) : null,
      bottom: attrs.containsKey(AttrNames.bottom) ? double.parse(attrs[AttrNames.bottom]) : null,
      left: attrs.containsKey(AttrNames.left) ? double.parse(attrs[AttrNames.left]) : null,
      width: attrs.containsKey(AttrNames.width) ? double.parse(attrs[AttrNames.width]) : null,
      height: attrs.containsKey(AttrNames.height) ? double.parse(attrs[AttrNames.height]) : null,
    );
  }
}


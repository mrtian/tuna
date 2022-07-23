
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/utils/style_parse.dart';
import '../../tuna3.dart';
import '../constants.dart';
import '../widget.dart';


class TWidgetColumn extends TStyleWidget{
  
  TWidgetColumn():super(tagName: 'column');

  @override
  build(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}){
    Map<String,dynamic> attrs = getAttributes(node);
    dynamic children = Tuna3.parseWidgets(node.children,jsRuntime,styleSheet: styleSheet);

    dynamic _ret =  Column(
      crossAxisAlignment: attrs.containsKey(AttrNames.crossAxisAlignment)
	          ? StyleParse.crossAxisAlignment(attrs[AttrNames.crossAxisAlignment])
	          : CrossAxisAlignment.center,
	      mainAxisAlignment: attrs.containsKey(AttrNames.mainAxisAlignment)
	          ? StyleParse.mainAxisAlignment(attrs[AttrNames.mainAxisAlignment])
	          : MainAxisAlignment.start,
	      mainAxisSize: attrs.containsKey(AttrNames.mainAxisSize)
	          ? StyleParse.mainAxisSize(attrs[AttrNames.mainAxisSize])
	          : MainAxisSize.max,
	      textBaseline: attrs.containsKey(AttrNames.textBaseline)
	          ? StyleParse.textBaseline(attrs[AttrNames.textBaseline])
	          : null,
	      textDirection: attrs.containsKey(AttrNames.textDirection)
	          ? StyleParse.textDirection(attrs[AttrNames.textDirection])
	          : null,
	      verticalDirection: attrs.containsKey(AttrNames.verticalDirection)
	          ? StyleParse.verticalDirection(attrs[AttrNames.verticalDirection])
	          : VerticalDirection.down,
      children: children,
    );
    // print(children);
    return _ret;
    
  }

}
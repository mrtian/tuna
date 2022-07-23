import 'package:flutter/cupertino.dart';
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/utils/style_parse.dart';
import 'package:html/dom.dart' as dom;

import '../constants.dart';
import '../widget.dart';

class TWidgetRow extends TStyleWidget{
  
  TWidgetRow():super(tagName: 'row');
  
  @override
  build(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}){
    
    dynamic attrs = getAttributes(node);
    // print(node.element.children);
    dynamic children = Tuna3.parseWidgets(node.children, jsRuntime,styleSheet: styleSheet);

    // print(children);
  
    return  Row(
      crossAxisAlignment: attrs!.containsKey(AttrNames.crossAxisAlignment)
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
  }
}
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/utils/style_parse.dart';

import '../../js_runtime.dart';
import '../../style_sheet.dart';
import '../constants.dart';
import '../widget.dart';


class TWidgetDivider  extends TWidget{

  TWidgetDivider():super(tagName: 'divider');

  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}) {
    var attrs = node.attributes;
    return Divider(
    	height: attrs.containsKey(AttrNames.height)?double.parse(attrs[AttrNames.height]!):0.5,
    	indent: attrs.containsKey(AttrNames.indent)?double.parse(attrs[AttrNames.indent]!):0.0, 
    	endIndent:  attrs.containsKey(AttrNames.endIndent)?double.parse(attrs[AttrNames.endIndent]!):0.0,
    	color:attrs.containsKey(AttrNames.color)?StyleParse.hexColor(attrs[AttrNames.color]):null
    );
  }
}
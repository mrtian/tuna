import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/utils/style_parse.dart';
import '../constants.dart';
import '../widget.dart';


class TWidgetContainer extends TStyleWidget{

  TWidgetContainer():super(tagName: ['container','div']);
  
  @override
  build(dom.Element node,JsRuntime jsRuntime ,{TStyleSheet? styleSheet}){
      dynamic attrs = node.attributes;

      Alignment? alignment = attrs!.containsKey(AttrNames.alignment)?StyleParse.alignment(attrs[AttrNames.alignment]):null;

	    Color? color = StyleParse.hexColor(attrs[AttrNames.color]);

	    BoxConstraints? constraints = StyleParse.boxConstraints(StyleParse.convertAttr(attrs[AttrNames.constraints]));

	    bool expanded = attrs.containsKey(AttrNames.expanded)?StyleParse.bool(attrs[AttrNames.expanded]):false;

	    EdgeInsetsGeometry? margin = StyleParse.edgeInsetsGeometry(attrs[AttrNames.margin]);
      
	    EdgeInsetsGeometry? padding = StyleParse.edgeInsetsGeometry(attrs[AttrNames.padding]);

	    Widget? child;
      if(node.children.isNotEmpty){
        child = Tuna3.parseWidget(node.children[0],jsRuntime,styleSheet: styleSheet);
      }
	    // 处理decoration
	    dynamic decoration;
	    if(attrs.containsKey(AttrNames.decoration) && attrs[AttrNames.decoration].isNotEmpty){
	      decoration = StyleParse.boxDecoration(StyleParse.convertAttr(attrs[AttrNames.decoration]));
	    }else{
	      decoration = null;
	    }
      double? width = attrs.containsKey(AttrNames.width)&& attrs[AttrNames.width].trim().isNotEmpty?double.parse(attrs[AttrNames.width]):null;
      double? height = attrs.containsKey(AttrNames.height)&& attrs[AttrNames.height].trim().isNotEmpty? double.parse(attrs[AttrNames.height]):null;

      double? maxWidth = attrs.containsKey("maxWidth")?double.parse(attrs["maxWidth"]):null;
      double? maxHeight = attrs.containsKey("maxHeight")? double.parse(attrs["maxHeight"]):null;
      
      

      if(constraints==null){
        if(width!=null || height!=null){
          constraints = BoxConstraints.expand(width: width,height: height);
        }
        if(maxWidth!=null && maxHeight!=null){
          constraints = BoxConstraints(
            maxHeight: maxHeight,
            maxWidth: maxWidth
          );
        }
      }

      if(alignment==null){
        return Container(
		      padding: padding,
		      color: color,
		      margin: margin,
		      width: width,
		      height: height,
		      constraints: expanded?const BoxConstraints.expand():constraints,
		      child: child,
		      decoration : decoration,
		    );
      }

	    return Container(
		      alignment: alignment,
		      padding: padding,
		      color: color,
		      margin: margin,
		      width: width,
		      height: height,
		      constraints: expanded?const BoxConstraints.expand():constraints,
		      child: child,
		      decoration : decoration,
		    );
  }
}
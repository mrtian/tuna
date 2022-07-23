import 'package:flutter/material.dart';
import 'package:tuna3/utils/style_parse.dart';
import 'package:tuna3/utils/styled_widget_parse.dart';
import 'package:html/dom.dart' as dom;
import '../../js_runtime.dart';
import '../../style_sheet.dart';
import '../widget.dart';

class TWidgetText extends TWidget {
  
  TWidgetText():super(tagName: 'text');

  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}){
    
    Map<String,dynamic> attrs = getAttributes(node);
    // print(attrs);
    dynamic maxLines = attrs.containsKey("maxLines")?int.parse(attrs["maxLines"]):null;
    Map<String,dynamic>? style = StyleParse.convertAttr(attrs['style']);
    dynamic strutStyle = StyleParse.convertAttr(attrs['strutStyle']);
  
    dynamic textAlign;
    dynamic textOverflow;
    dynamic textDirection;
    

    // 获取当前元素的样式表中的样式
    dynamic sheetStyle;
    dynamic sheetTree = getSheetTree(node);
    // print(map.doc!.styleSheet);
    if(styleSheet != null && sheetTree != null && sheetTree.isNotEmpty ){
      // print(map.sheetTree!);
      sheetStyle = styleSheet.getStyle(sheetTree);
      // print(sheetStyle);
    }
    // 与内联样式进行合并更新样式
    if(sheetStyle!=null && sheetStyle.isNotEmpty){
      Iterable<Map<String, dynamic>>? _slist;
      if(style!=null){
        _slist = [sheetStyle,style];
      }else{
        _slist = [sheetStyle];
      }
      style = TStyleSheet.mergeStyle(_slist);
    }

    if(style!=null){
      if(style.containsKey("text") && style["text"] is Map){
        textAlign = style["text"].containsKey("align")?StyleParse.textAlign(style["text"]["align"]):null;
        textOverflow = style["text"].containsKey("overflow")?StyleParse.textOverflow(style["text"]["overflow"]):null;
        textDirection = style["text"].containsKey("direction")?StyleParse.textDirection(style["text"]["direction"]):null;
        if(style["text"].containsKey("shadow")){
          // shadow string like this: 0,0,1,#FF000000;0,0,1,#FF000000;0,0,1,#FF000000;0,0,1,#FF000000
          style['shadows'] = style["text"]["shadow"];
        }
      }
    }

    if(strutStyle!=null && strutStyle is Map && strutStyle.isNotEmpty){
      if(strutStyle.containsKey("line") && strutStyle['line'] is Map){  
        strutStyle['line-height'] = strutStyle['line'].containsKey("height")? strutStyle['line']['height']:null;
      }
    }

    if(style!=null && style.containsKey("line") && style['line'] is Map){  
      style['line-height'] = style['line'].containsKey("height")? style['line']['height']:null;
    }
    
    bool isSelectAble = attrs["selectAble"]=="true"?true:false;
    var ret;
    if(isSelectAble){
      return SelectableText(
        node.innerHtml,
        style: StyleParse.textStyle(style),
        textScaleFactor: attrs['scale']!=null?double.parse(attrs['scale']):null,
        strutStyle: StyleParse.textStyle(strutStyle),
        maxLines:maxLines,
        textAlign: textAlign,
        textDirection: textDirection,
      );
    }else{
      ret = Text(
        node.innerHtml,
        textScaleFactor: attrs['scale']!=null?double.parse(attrs['scale']):null,
        style: StyleParse.textStyle(style),
        strutStyle: StyleParse.textStyle(strutStyle),
        maxLines:maxLines,
        textAlign: textAlign,
        overflow: textOverflow,
        textDirection: textDirection,
        softWrap:attrs['softWrap']!=null?StyleParse.bool(attrs['softWrap']):true
      );
    }

    // 写入最终样式
    return StyledWidgetParse.parse(ret,node.attributes,style);
    
  }
}
import 'package:flutter/material.dart';
import 'package:tuna/compontents/RichHtml.dart';
import 'package:tuna/utils/styleParse.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atelier-lakeside-dark.dart';
import 'package:tuna/template/template.dart';

class TWidgetRichText extends TStyleWidget{

  TWidgetRichText():super(tagName: 'richText');
  
  build(TunaNode node,{BuildContext? context}) {
    var attrs = node.attributes;
    String text = node.element.innerHtml;
    
    if(text.isEmpty){
      return Text("");
    }
    var style = attrs!['style']==null?null:StyleParse.convertAttr(attrs['style']);
    var maxLines = attrs.containsKey("maxLines")?int.parse(attrs["maxLines"]):null;
    var strutStyle = StyleParse.convertAttr(attrs['strutStyle']);

    var textAlign;
    var textOverflow;
    var textDirection;
    
    if(style!=null){
      if(style.containsKey("text") && style["text"] is Map){
        textAlign = style["text"].containsKey("align")?StyleParse.textAlign(style["text"]["align"]):null;
        textOverflow = style["text"].containsKey("overflow")?StyleParse.textOverflow(style["text"]["overflow"]):null;
        textDirection = style["text"].containsKey("direction")?StyleParse.textDirection(style["text"]["direction"]):null;
        if(style["text"].containsKey("shadow")){
          style['shadows'] = style["text"]["shadow"];
        }
      }
      if(style.containsKey("line") && style['line'] is Map){  
        style['line-height'] = style['line'].containsKey("height")? style['line']['height']:null;
      }
    }

    if(strutStyle!=null && strutStyle is Map && strutStyle.isNotEmpty){
      if(strutStyle.containsKey("line") && strutStyle['line'] is Map){  
        strutStyle['line-height'] = strutStyle['line'].containsKey("height")? strutStyle['line']['height']:null;
      }
    }

    return Text.rich(
      RichHtml.toTextSpan(
        context,
        text,
        doc:node.doc,
        scale: attrs['scale']!=null?double.parse(attrs['scale']):null,
        callBack: (type, args) {
          if (type == "link") {
            if(attrs["launchLink"]=="true"){
              try{
                launch(args);
              }catch(e){
                print(e);
              }
            }else if(attrs["linkHandle"] != null) {
              node.doc!.jsEngine!.evaluateFunc(attrs["linkHandle"], {"url":args});
            }
          }else if (type == "onclick") {
            var handle = StyleParse.convertAttr(args.trim());
            var callHandle;
            var params;
            if (handle is Map) {
              callHandle = handle["handle"];
              params = Map.from(handle);
              params.remove("handle");
            } else if (handle is String && handle.isNotEmpty) {
              callHandle = handle;
            }
            if (callHandle == null || callHandle.isEmpty) {
              return;
            }
            node.doc!.jsEngine!.evaluateFunc(callHandle, params);
          }
        },
        style:style!=null?StyleParse.textStyle(style):null,
      ),
      strutStyle: StyleParse.textStyle(strutStyle),
      maxLines:maxLines,
      textAlign: textAlign,
      textDirection: textDirection,
      overflow: textOverflow,
      
    );
  }
  
}

class TWidgetCodeText extends TStyleWidget{

  TWidgetCodeText():super(tagName: 'code');

  build(TunaNode node,{BuildContext? context}) {
    var attrs = node.attributes;
    var lan = attrs!['lan']!=null?attrs['lan']:"html";
    var padding = attrs['padding']!=null?StyleParse.edgeInsetsGeometry(attrs['padding']):EdgeInsets.all(10.0);
    var style = attrs['style']!=null?StyleParse.convertAttr(attrs['style']):null;
    String text = node.element.innerHtml;
  
    return Container(
      padding: padding,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context!).size.width,
      ),
      child: HighlightView(
        text,
        // Specify language
        // It is recommended to give it a value for performance
        language: lan,
        // Specify highlight theme
        // All available themes are listed in `themes` folder
        theme: atelierLakesideDarkTheme,
        // Specify padding
        padding: padding,
        // Specify text style
        textStyle: style,
      ),
    );
  }

  
}
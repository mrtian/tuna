import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/utils/style_parse.dart';

import '../constants.dart';
import '../widget.dart';


class TWidgetImage  extends TStyleWidget{

  TWidgetImage():super(tagName: ['image','img']);
  
  @override
  build(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}) {

    Map<String, dynamic> attrs = getAttributes(node);
    String src = attrs[AttrNames.src] ?? "";
    String? semanticLabel =
        attrs.containsKey(AttrNames.semanticLabel) ? attrs[AttrNames.semanticLabel] : null;
    bool excludeFromSemantics = attrs.containsKey(AttrNames.excludeFromSemantics)
        ? attrs[AttrNames.excludeFromSemantics]
        : false;
    double? scale = attrs.containsKey("scale") ? double.parse(attrs[AttrNames.scale]) : 1.0;
    double? width = attrs.containsKey(AttrNames.width)  && attrs[AttrNames.width]!=null ? double.parse(attrs[AttrNames.width]) : null;
    double? height = attrs.containsKey(AttrNames.height)&& attrs[AttrNames.height]!=null ? double.parse(attrs[AttrNames.height]) : null;
    Color? color = attrs.containsKey(AttrNames.color) ? StyleParse.hexColor(attrs[AttrNames.color]) : null;
    BlendMode? blendMode =
        attrs.containsKey(AttrNames.blendMode) ? StyleParse.blendMode(attrs[AttrNames.blendMode]) : null;
    BoxFit? boxFit =
        attrs.containsKey(AttrNames.fit) ? StyleParse.boxFit(attrs[AttrNames.fit]) : null;
    Alignment alignment = attrs.containsKey(AttrNames.alignment)
        ? StyleParse.alignment(attrs[AttrNames.alignment])
        : Alignment.center;
    ImageRepeat repeat = attrs.containsKey(AttrNames.repeat)
        ? StyleParse.imageRepeat(attrs[AttrNames.repeat])
        : ImageRepeat.noRepeat;
    Rect? centerSlice =
        attrs.containsKey(AttrNames.centerSlice) ? StyleParse.rect(attrs[AttrNames.centerSlice]) : null;
    bool matchTextDirection = attrs.containsKey(AttrNames.matchTextDirection)
        ? attrs[AttrNames.matchTextDirection]
        : false;
    bool gaplessPlayback =
        attrs.containsKey(AttrNames.gaplessPlayback) ? attrs[AttrNames.gaplessPlayback] : true;
    FilterQuality filterQuality = attrs.containsKey(AttrNames.filterQuality)
        ? StyleParse.filterQuality(attrs[AttrNames.filterQuality])
        : FilterQuality.low;

    Color errorIconColor = attrs.containsKey(AttrNames.errorIconColor)?StyleParse.hexColor(attrs[AttrNames.errorIconColor]):Color(0xFFCCCCCC);
    Color loadingColor = attrs.containsKey(AttrNames.loadingColor)?StyleParse.hexColor(attrs[AttrNames.loadingColor]):Color(0xFFC9C9C9);
    double loadingSize = attrs.containsKey(AttrNames.loadingSize)?double.parse(attrs[AttrNames.loadingSize]):24.0;
    double errorIconSize = attrs.containsKey(AttrNames.errorIconSize)?double.parse(attrs[AttrNames.errorIconSize]):32.0;

    bool cache = attrs.containsKey(AttrNames.cache)?StyleParse.bool(attrs[AttrNames.cache]):true;

    RegExp isNet = RegExp(r"^(http[s]?|ftp):\/\/");
    RegExp isFile = RegExp(r"^file:\/\/?");
    RegExp isBase64 = RegExp(r"^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$");
    RegExp isAssets = RegExp(r"^assets:\/\/");
    
    Widget? ret;

    if(isFile.hasMatch(src)){
      src = src.replaceAll(isFile,"");
      var file = File(src);
      if(file.existsSync()){
        ret = Image.file(
          file,
          key:PageStorageKey(src),
          semanticLabel: semanticLabel,
          excludeFromSemantics: excludeFromSemantics,
          scale: scale,
          width: width,
          height: height,
          color: color,
          colorBlendMode: blendMode,
          fit: boxFit,
          alignment: alignment,
          repeat: repeat,
          centerSlice: centerSlice,
          matchTextDirection: matchTextDirection,
          gaplessPlayback: gaplessPlayback,
          filterQuality: filterQuality,
        );
      }else{
        return Center(
          child: Icon(Icons.broken_image_outlined,size:errorIconSize,color:errorIconColor)
        );
      }
      
    }else if(isBase64.hasMatch(src)){
      Uint8List bytes = const Base64Decoder().convert(src);
      ret = Image.memory(
        bytes,
        key:PageStorageKey(src),
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        width: width,
        height: height,
        color: color,
        colorBlendMode: blendMode,
        fit: boxFit,
        alignment: alignment,
        repeat: repeat,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        filterQuality: filterQuality,
      );
    }else if(isAssets.hasMatch(src)){
      ret = Image.asset(
        src.replaceAll(isAssets, ""),
        key:PageStorageKey(src),
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        scale: scale,
        width: width,
        height: height,
        color: color,
        colorBlendMode: blendMode,
        fit: boxFit,
        alignment: alignment,
        repeat: repeat,
        centerSlice: centerSlice,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        filterQuality: filterQuality,
      );
    }else{
      return ExtendedImage.network(
        src,
        width: width,
        height: height,
        cache: cache,
        headers: attrs.containsKey("headers")?StyleParse.convertAttr(attrs['headers']):null,
        loadStateChanged: (ExtendedImageState state) {
          switch (state.extendedImageLoadState) {
            case LoadState.failed:
              String? onerrorUrl = attrs['onerror'];
              if(onerrorUrl!=null){
                var imgEl = parseFragment('<img src="'+onerrorUrl+'"></img>');
                return Tuna3.parseWidget(imgEl.children[0], jsRuntime,styleSheet: styleSheet);
              }else{
                return Center(
                  child: Icon(Icons.broken_image_outlined,size:errorIconSize,color:errorIconColor)
                );
              }
            case LoadState.loading:
              return Center(child: SizedBox(
                width: loadingSize,
                height: loadingSize,
                child: CircularProgressIndicator(strokeWidth: 1.5,valueColor: AlwaysStoppedAnimation(loadingColor)),
              ));
            case LoadState.completed:
              return ExtendedRawImage(
                  image: state.extendedImageInfo?.image,
                  width: width,
                  height: height,
                  scale: scale,
                  fit:boxFit,
                  colorBlendMode:blendMode,
                  color:color,
                  alignment: alignment,
                  repeat: repeat,
                  centerSlice:centerSlice,
                  matchTextDirection: matchTextDirection,
                  // gaplessPlayback: gaplessPlayback,
                  filterQuality: filterQuality,
              );
          }
        }
      );
    }
    return ret;
  }
}
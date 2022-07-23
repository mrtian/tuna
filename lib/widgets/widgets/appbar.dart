import 'package:flutter/material.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/utils/style_parse.dart';

import '../../js_runtime.dart';
import '../constants.dart';
import '../widget.dart';
import 'package:html/dom.dart' as dom;

class TWidgetAppBar  extends TWidget{

  TWidgetAppBar():super(tagName: ['appBar','appbar']);

  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}) {

    Map<String,dynamic> attrs = getAttributes(node);
    
    Widget? leading;
    double? leadingWidth  = attrs.containsKey("leadingwidth")?double.parse(attrs['leadingwidth']):null;
    bool disableLeading = attrs.containsKey("disableleading")? StyleParse.bool(attrs["disableleading"]):true;
    Widget? title;
    List<Widget>? actions;
    double elevation = 0.5;
    Color? backgroundColor;
    PreferredSizeWidget? bottom;
    FlexibleSpaceBar? header;
    IconThemeData? iconTheme;
    IconThemeData? actionsIconTheme;
    bool _isDark = false;
    TextStyle? textStyle;
    bool centerTitle = attrs.containsKey(AttrNames.centerTitle) ? StyleParse.bool(attrs[AttrNames.centerTitle]):true;
    Brightness? brightness = attrs.containsKey('brightness')?StyleParse.brightness(attrs['brightness']):null;
    

    if(attrs.containsKey('elevation')){
      elevation = double.parse(attrs['elevation']);
    }

    if(attrs.containsKey('color')){
      if(attrs['color']=='transparent'){
        backgroundColor = Colors.transparent;
      }else{
        backgroundColor = StyleParse.hexColor(attrs['color']);
      }
    }
    // iconthemedata
    if(attrs.containsKey('icontheme')){
      iconTheme = StyleParse.iconThemeData(StyleParse.convertAttr( attrs['icontheme'] ));
    }else{
      
    }

    if(attrs.containsKey('leading')){
      if(attrs['leading'] is String){
        
        leading = Text(attrs['leading'],style: textStyle);
      }
    }
    if(attrs['title'] is String){
      title = Text(attrs['title'],style: textStyle);
    }

    // dynamic set bottom
    if(attrs.containsKey('bottom')){
      bottom = attrs['bottom'];
    }

    List<dom.Element> children = node.children;

    dynamic appbar;

    if(children.isNotEmpty){
      if(children.length==1 &&  children[0].localName == "preferredSize"){
        // print("hihihi");
        return Tuna3.parseWidget(children[0],jsRuntime,styleSheet:styleSheet);
      }

      children.forEach((dom.Element item){
        
        if(item.children is List && item.children.isNotEmpty){
          if(item.localName =='leading' && leading==null){
            leading = Tuna3.parseWidget(item.children[0],jsRuntime,styleSheet:styleSheet);
          }
          
          if( item.localName=='atitle' && title==null){
            title = Tuna3.parseWidget(item.children[0],jsRuntime,styleSheet:styleSheet);
          }
          if(item.localName=='actions' &&  actions==null){
            actions = Tuna3.parseWidgets(item.children,jsRuntime,styleSheet:styleSheet);
            // print(actions);
          }
          if(item.localName=='bottom' && bottom==null){
            bottom = Tuna3.parseWidget(item.children[0],jsRuntime,styleSheet:styleSheet);
          }
          if(item.localName=='spacebar' && header==null){
            dynamic itemAttrs = item.attributes;
            dynamic collapse;
            if(itemAttrs.isNotEmpty && itemAttrs.containsKey('collapse')){
              collapse = StyleParse.collapseMode(itemAttrs['collapse']);
            }
            header =  FlexibleSpaceBar(
              title: title,
              centerTitle: centerTitle,
              titlePadding:itemAttrs.containsKey("titlePadding")?StyleParse.edgeInsetsGeometry(itemAttrs['titlePadding']):null,
              collapseMode: collapse,
              background:  Tuna3.parseWidget(item.children[0],jsRuntime,styleSheet:styleSheet)
            );
          }
        }
      });
    }

    if(attrs.containsKey('sliver')){
      if(leading!=null){
        appbar =  SliverAppBar(
            leadingWidth: leadingWidth,
            leading:leading,
            primary:attrs.containsKey(AttrNames.primary)?StyleParse.bool(attrs[AttrNames.primary]):true,
            title:title,
            actions:actions,
            iconTheme:iconTheme,
            backgroundColor:backgroundColor,
            pinned: attrs.containsKey(AttrNames.pinned)? StyleParse.bool(attrs[AttrNames.pinned]):true,
            floating: attrs.containsKey(AttrNames.floating)?StyleParse.bool(attrs[AttrNames.floating]):false,
            snap:attrs.containsKey(AttrNames.snap)? StyleParse.bool(attrs[AttrNames.snap]):false,
            elevation:elevation,
            expandedHeight: attrs.containsKey(AttrNames.expandedHeight)?double.parse(attrs[AttrNames.expandedHeight]):0.0,
            flexibleSpace: header,
            bottom: bottom,
            actionsIconTheme:actionsIconTheme,
            automaticallyImplyLeading:disableLeading,
            forceElevated: attrs.containsKey(AttrNames.forceElevated)?StyleParse.bool(attrs[AttrNames.forceElevated]):false,
            centerTitle:centerTitle
          );
       }else{
         appbar =  SliverAppBar(
            leadingWidth: leadingWidth,
            primary:attrs.containsKey(AttrNames.primary)?StyleParse.bool(attrs[AttrNames.primary]):true,
            title:title,
            actions:actions,
            iconTheme:iconTheme,
            actionsIconTheme:actionsIconTheme,
            backgroundColor:backgroundColor,
            pinned: attrs.containsKey(AttrNames.pinned)? StyleParse.bool(attrs[AttrNames.pinned]):true,
            floating: attrs.containsKey(AttrNames.floating)?StyleParse.bool(attrs[AttrNames.floating]):false,
            snap:attrs.containsKey(AttrNames.snap)? StyleParse.bool(attrs[AttrNames.snap]):false,
            elevation:elevation,
            expandedHeight: attrs.containsKey(AttrNames.expandedHeight)?double.parse(attrs[AttrNames.expandedHeight]):0.0,
            flexibleSpace: header,
            bottom: bottom,
            automaticallyImplyLeading:disableLeading,
            forceElevated: attrs.containsKey(AttrNames.forceElevated)?StyleParse.bool(attrs[AttrNames.forceElevated]):false,
            centerTitle:centerTitle
          );
       }
        return appbar;
    }

    if(leading!=null){
      appbar = AppBar(
        title:title,
        iconTheme:iconTheme,
        leadingWidth: leadingWidth,
        primary:attrs.containsKey(AttrNames.primary)?StyleParse.bool(attrs[AttrNames.primary]):true,
        leading:leading,
        actionsIconTheme:actionsIconTheme,
        actions:actions,
        backgroundColor:backgroundColor,
        bottom:bottom,
        automaticallyImplyLeading:disableLeading,
        flexibleSpace: header,
        elevation:elevation,
        centerTitle:centerTitle
      );
    }else{
        appbar = AppBar(
          title:title,
          iconTheme:iconTheme,
          leadingWidth: leadingWidth,
          actionsIconTheme:actionsIconTheme,
          primary:attrs.containsKey(AttrNames.primary)?StyleParse.bool(attrs[AttrNames.primary]):true,
          actions:actions,
          flexibleSpace: header,
          automaticallyImplyLeading:disableLeading,
          backgroundColor:backgroundColor,
          bottom:bottom,
          elevation:elevation,
          centerTitle:centerTitle
        );
    }

    return appbar;
    
  }

}
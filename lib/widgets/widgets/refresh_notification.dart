
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:tuna3/module.dart';
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/utils/style_parse.dart';

import '../../js_runtime.dart';
import '../../style_sheet.dart';
import '../widget.dart';

enum RefreshIndicatorMode {
  drag, // Pointer is down.
  armed, // Dragged far enough that an up event will run the onRefresh callback.
  snap, // Animating to the indicator's final "displacement".
  refresh, // Running the refresh callback.
  done, // Animating the indicator's fade-out after refreshing.
  canceled, // Animating the indicator's fade-out after not arming.
  error, //refresh failed
}



class TWidgetRefreshNotification  extends TWidget{
  
  TWidgetRefreshNotification():super(tagName: 'refreshNotification');

  @override
  parse(dom.Element node, JsRuntime jsRuntime, {TStyleSheet? styleSheet}){
    Map<String,dynamic> attrs = getAttributes(node);
    Color color = attrs.containsKey("color")?StyleParse.hexColor(attrs['color']):Colors.blue;
    String? name = attrs['color'];
    bool pullBackOnRefresh = attrs.containsKey("pullBackOnRefresh")?StyleParse.bool(attrs['pullBackOnRefresh']):true;
    
    return  PullToRefreshNotification(
      color: color,
      pullBackOnRefresh: pullBackOnRefresh,
      onRefresh: name!=null?(){
        jsRuntime.evaluateFunc("TunaRefreshEvent."+name,null);
        return Future.value(true);
      }:attrs.containsKey("onRefresh")?(){
        jsRuntime.evaluate(attrs['onRefresh']);
        return Future.value(true);
      }:(){
        return Future.value(true);
      },
      child: Tuna3.parseWidget(node.children[0], jsRuntime,styleSheet: styleSheet)
    );

  }

}



class TWidgetRefreshContainer  extends TWidget{
  
  TWidgetRefreshContainer():super(tagName: 'refreshContainer');

  @override
  parse(dom.Element node, JsRuntime jsRuntime, {TStyleSheet? styleSheet}){
    TBuildRefreshContainer _builder = TBuildRefreshContainer(node,jsRuntime,styleSheet: styleSheet);
    return  PullToRefreshContainer(_builder.build);
  }

}

class TBuildRefreshContainer{

  dom.Element node;
  JsRuntime jsRuntime;
  TStyleSheet? styleSheet;
  TBuildRefreshContainer(this.node,this.jsRuntime,{this.styleSheet});

  Widget build(PullToRefreshScrollNotificationInfo? info){
    if(node.attributes.containsKey("name")){
      jsRuntime.evaluateFunc("TunaRefreshEvent."+node.attributes['name']!,info.toString());
    }
    var offset = info?.dragOffset ?? 0.0;
    return  SliverAppBar(
            pinned: true,
            title: Text("PullToRefreshAppbar"),
            centerTitle: true,
            expandedHeight: 200.0+offset,
            // actions: <Widget>[action],
            flexibleSpace: FlexibleSpaceBar(
                //centerTitle: true,
                title: Text(
                  info?.mode?.toString() ?? "",
                  style: TextStyle(fontSize: 10.0),
                ),
                collapseMode: CollapseMode.pin,
                background: Image.asset(
                  "images/new0.jpeg",
                  //fit: offset > 0.0 ? BoxFit.cover : BoxFit.fill,
                  fit: BoxFit.cover,
                )));
    return Tuna3.parseWidget(node.children[0], jsRuntime,styleSheet: styleSheet);
  }
  
}






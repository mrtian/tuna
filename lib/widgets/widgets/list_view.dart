import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:html/parser.dart';
import 'package:tuna3/jscore/core/js_value.dart';
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/utils/animate_parse.dart';
import 'package:tuna3/utils/style_parse.dart';

import '../../js_runtime.dart';
import '../../style_sheet.dart';
import '../constants.dart';
import '../widget.dart';


class TWidgetListView extends TWidget{

  TWidgetListView():super(tagName: 'list');

  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}){
    
    ScrollController? scrollController;
    Map<String,dynamic> attrs = getAttributes(node);
    String? widgetName = attrs['name'];
    bool isGridView = attrs['type'] == "grid"?true:false;
    bool isWaterfall = (attrs['isFall'] == 'true' || attrs['type'] == "fall")?true:false;
    // bool isRefresh = attrs['isRefresh'] == 'true';

    var key = md5.convert(utf8.encode(node.outerHtml)).toString();
    var listKey = PageStorageKey(key);
    
    if(widgetName!=null && widgetName.isNotEmpty){
      scrollController = ScrollController(
        initialScrollOffset: attrs.containsKey("offset")?double.parse(attrs["offset"]):0.0,
      );

      jsRuntime.registDispose((){
        scrollController!.dispose();
      });

      if(attrs['builder']!='true'){
        jsRuntime.addWidgetMessageHandle("ListView",widgetName,(params){
          if(params is Map && 
            params["method"] != null
          ){
            var method = params["method"];
            var data = params["data"];

            switch(method){
              case "init":
                return true;
              case "jumpTo":
                if(scrollController!=null && data!=null){
                  scrollController.jumpTo(double.parse(data.toString()));
                }
                return true;
              case "animateTo":
                if(scrollController!=null && data!=null){
                  if(data is String || data is int || data is double){
                    scrollController.animateTo(double.parse(data.toString()), duration: const Duration(milliseconds: 250), curve: Curves.linear);
                  }else if(data is Map && data.containsKey("offset")){
                    var offset = double.parse(data["offset"].toString());
                    var duration = data.containsKey("duration")?Duration(milliseconds: data['duration']):Duration(milliseconds: 250);
                    var curve = data.containsKey("curve")?AnimateParse.curve(data["curve"]):Curves.linear;
                    scrollController.animateTo(offset, duration: duration, curve: curve);
                  }
                  return true;
                }
                return false;
              case "position":
                if(scrollController!=null){
                  ScrollPosition pos =  scrollController.position;
                  return {
                    "pixes":pos.pixels,
                    "max":pos.maxScrollExtent,
                    "min":pos.minScrollExtent
                  };
                }
                return null;
              case "listen":
                if(scrollController!=null){
                  scrollController.addListener(() { 
                    var code = 'T.getListView("'+widgetName+'").resolveScrollListen();';
                    jsRuntime.evaluate(code);
                  });
                }
                return true;
              case "offset":
                if(scrollController!=null){
                  return scrollController.offset;
                }
                return null;
            }
          }
        });
      }
    }

    bool primary =  attrs.containsKey("primary")?StyleParse.bool(attrs["primary"]):false;
    ScrollPhysics? physics = attrs.containsKey(AttrNames.physics) && attrs[AttrNames.physics]=='true' ? null: const BouncingScrollPhysics();
    Axis direction = attrs.containsKey(AttrNames.direction) ? StyleParse.axis(attrs[AttrNames.direction]) : Axis.vertical;
    bool isReverse =  attrs.containsKey(AttrNames.reverse) ? StyleParse.bool(attrs[AttrNames.reverse]) : false;
    double? itemExtent =attrs.containsKey(AttrNames.itemExtent)?double.parse(attrs[AttrNames.itemExtent]):null;
    bool shrinkWrap = attrs.containsKey(AttrNames.shrinkWrap)?StyleParse.bool(attrs[AttrNames.shrinkWrap]):false;
    EdgeInsetsGeometry? padding = StyleParse.edgeInsetsGeometry(attrs[AttrNames.padding]);
    
    // FOR GridView
    var crossAxisCount =  attrs.containsKey(AttrNames.crossAxisCount)?int.parse(attrs[AttrNames.crossAxisCount]):2;
    var mainAxisSpacing =  attrs.containsKey(AttrNames.mainAxisSpacing)?double.parse(attrs[AttrNames.mainAxisSpacing]) : 5.0;
    var crossAxisSpacing =  attrs.containsKey(AttrNames.crossAxisSpacing)?double.parse(attrs[AttrNames.crossAxisSpacing]):5.0;
    var childAspectRatio =  attrs.containsKey(AttrNames.ratio) ? double.parse(attrs[AttrNames.ratio]) :  1.0;

    bool isSliver = attrs['custom']=="true"?true:false;
    // if(isRefresh){
    //   isSliver = false;
    //   scrollController = null;
    //   shrinkWrap = true;
    //   primary = true;
    // }

    if(attrs["builder"]=="true"){
       return TunaBuilderListView(
          jsRuntime: jsRuntime,
          attrs: attrs,
          styleSheet:styleSheet,
          isGridView:isGridView,
          name:widgetName,
          child:node.children,
          padding:padding,
          primary: primary,
          physics: physics,
          shrinkWrap:shrinkWrap,
          itemExtent:itemExtent,
          reverse: isReverse,
          direction: direction,
          scroller: scrollController!,
          isSliver: isSliver,
          node:node,
          crossAxisCount:crossAxisCount,
          crossAxisSpacing:crossAxisSpacing,
          mainAxisSpacing:mainAxisSpacing,
          childAspectRatio:childAspectRatio,
          isWaterfall:isWaterfall
       );
    }else{
      var children = Tuna3.parseWidgets(node.children,jsRuntime,styleSheet: styleSheet);
      if(isGridView){
        if(isSliver){
          return SliverGrid.count(
            crossAxisCount: crossAxisCount,
            key:listKey,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
            children:children
          );
        }
        return GridView.count(
          key:listKey,
          physics: physics,
          primary:primary,
          padding: padding,
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
          shrinkWrap: shrinkWrap,
          children: children
        );
    }
    //   }else if(isWaterfall){
    //     List<StaggeredGridTile> staggeredTiles = [];
    //     if (children is List){
    //       for (var i = 0; i < children.length; i++) {
    //         staggeredTiles.add(const StaggeredTile.fit(1));
    //       }
    //     }
        
    //   if(isSliver){
    //     return SliverStaggeredGrid.count(
    //       crossAxisCount: crossAxisCount,
    //       key:listKey,
    //       mainAxisSpacing: mainAxisSpacing,
    //       crossAxisSpacing: crossAxisSpacing,
    //       children:children ?? [],
    //       staggeredTiles:staggeredTiles,
    //     );
    //   }

    //   return StaggeredGridView.count(
    //     key:listKey,
    //     primary: primary,
    //     physics: physics,
    //     padding: padding,
    //     shrinkWrap: shrinkWrap,
    //     crossAxisCount: crossAxisCount,
    //     mainAxisSpacing: mainAxisSpacing,
    //     crossAxisSpacing: crossAxisSpacing,
    //     children: children ?? [],
    //     staggeredTiles:staggeredTiles,
    //   );
    // }

      if(isSliver){
        return SliverList(
          key:listKey,
          delegate: SliverChildListDelegate(children)
        );
      }

      return ListView(
          key: listKey,
          controller: scrollController,
          padding:padding,
          primary: primary,
          physics: physics,
          itemExtent: itemExtent,
          shrinkWrap:shrinkWrap,
          scrollDirection:direction,
          reverse: isReverse,
          children: children,
      );
    }
  }

}

class TunaBuilderListView extends StatefulWidget{
  final listKey;
  final bool isGridView;
  final bool isWaterfall;
  final ScrollController? scroller;
  final bool isSliver;
  final Axis direction;
  final EdgeInsetsGeometry? padding;
  final bool? reverse;
  final bool? shrinkWrap;
  final bool? primary;
  final ScrollPhysics? physics;
  final double? itemExtent;
  final dynamic child;
  final String? name;
  final dom.Element node;
  final TStyleSheet? styleSheet; 

  // FOR GridView
  final crossAxisCount;
  final crossAxisSpacing;
  final mainAxisSpacing;
  final childAspectRatio;

  final JsRuntime jsRuntime;
  final Map<String,dynamic> attrs;

  TunaBuilderListView({
    required this.jsRuntime,
    required this.attrs,
    this.listKey,
    this.child,
    this.scroller,
    this.isSliver = false,
    this.direction = Axis.vertical,
    this.padding,
    this.primary  = true,
    this.shrinkWrap,
    this.reverse,
    this.physics,
    this.itemExtent,
    required this.node,
    this.name,
    this.isGridView = false,
    this.isWaterfall = false,
    this.crossAxisCount,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.childAspectRatio,
    this.styleSheet
  });

  _TunaBuilderListViewState createState() => _TunaBuilderListViewState();

}

class _TunaBuilderListViewState extends State<TunaBuilderListView> with AutomaticKeepAliveClientMixin{
  
  List<dynamic> data = [];

  bool hasBinding = false;
  bool firstBuilded = true;
  bool forceUpdate = false;
  var reverse;

  int renderAt = 0;
  int prevRenderAt = 0;

  var cacheView;

  @override
  bool get wantKeepAlive => true;

  @override 
  void initState() {
    super.initState();
    reverse = widget.reverse;
    
    if(!hasBinding){
      // 页面渲染完成后执行
      var widgetsBinding = WidgetsBinding.instance;
      widgetsBinding.addPostFrameCallback((callback)async{
          if(!hasBinding &&  !widget.jsRuntime.onDispose ){
            hasBinding =  true;
            widget.jsRuntime.resolveWidgetReady("ListView", widget.name!);
          }
      });
      widget.jsRuntime.addWidgetMessageHandle("ListView", widget.name!, callHandle);
    }

  }
  
  @override
  void dispose() {
    super.dispose();
    widget.jsRuntime.removeWidgetMessageHandle("ListView", widget.name!, callHandle);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if(cacheView==null || forceUpdate==true){
      
      firstBuilded = false;

      if(widget.isGridView){
        if(widget.isSliver){
          cacheView =  SliverGrid(
            key:widget.listKey,
            delegate: SliverChildBuilderDelegate(
                _buildItem,
                childCount: data.length
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.crossAxisCount,
                mainAxisSpacing: widget.mainAxisSpacing,
                crossAxisSpacing: widget.crossAxisSpacing,
                childAspectRatio:widget.childAspectRatio,
            )
          );
        }else{
          cacheView =  GridView.builder(
            controller: widget.scroller,
            physics: widget.physics,
            shrinkWrap:widget.shrinkWrap!,
            primary:widget.primary,
            padding:widget.padding,
            itemBuilder:_buildItem,
            key:widget.listKey,
            itemCount:data.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.crossAxisCount,
                mainAxisSpacing: widget.mainAxisSpacing,
                crossAxisSpacing: widget.crossAxisSpacing,
                childAspectRatio:widget.childAspectRatio,
            )
          );
        }
        
      }else if(widget.isWaterfall){
        // if(widget.isSliver){
        //   cacheView =  SliverStaggeredGrid.countBuilder(
        //     // primary: widget.primary,
        //     // physics: widget.physics,
        //     // padding: widget.padding,
        //     // shrinkWrap: widget.shrinkWrap,
        //     // controller: widget.scroller,
        //     crossAxisCount: widget.crossAxisCount,
        //     itemCount: data.length,
        //     itemBuilder:_buildItem,
        //     staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
        //     mainAxisSpacing: widget.mainAxisSpacing,
        //     crossAxisSpacing: widget.crossAxisSpacing,
        //   );
        // }else{
        //   cacheView =  StaggeredGridView.countBuilder(
        //     primary: widget.primary,
        //     physics: widget.physics,
        //     padding: widget.padding,
        //     shrinkWrap: widget.shrinkWrap!,
        //     controller: widget.scroller,
        //     crossAxisCount: widget.crossAxisCount,
        //     itemCount: data.length,
        //     itemBuilder:_buildItem,
        //     staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
        //     mainAxisSpacing: widget.mainAxisSpacing,
        //     crossAxisSpacing: widget.crossAxisSpacing,
        //   );
        // }
      }else{
        // custom 
        if(widget.isSliver){
          cacheView =   SliverList(
            key:widget.listKey,
            delegate: SliverChildBuilderDelegate(
                _buildItem,
                childCount: data.length
            )
          );
        }else{
          cacheView =  ListView.builder(
            key: widget.listKey,
            scrollDirection: widget.direction,
            controller:widget.scroller,
            padding:widget.padding,
            primary: widget.primary,
            physics: widget.physics,
            itemExtent: widget.itemExtent,
            shrinkWrap:widget.shrinkWrap!,
            reverse: reverse,
            itemBuilder: _buildItem,
            itemCount: data.length,
            addAutomaticKeepAlives:true,
          );
        }
      }
      forceUpdate = false;
    }
    return cacheView;
  }

  // 单个元素编辑
  Widget _buildItem(BuildContext context,int index){
    var _data;
    
    prevRenderAt = renderAt;
    renderAt = index;
    
    if(widget.node.attributes['eachKey']!=null){
      var _key = widget.attrs['eachKey'];

      Map<String,dynamic> itemData = {
        "index":index,
        "isLast":(index==data.length-1),
        "_total":data.length
      };
      itemData[_key] = data[index];
      _data = itemData;
      // print(_data);

    }else{
      _data = data[index];
      _data['item_index'] = index;
      _data['item_is_last'] = (index==data.length-1);
      _data['_data_length'] = data.length;
    }
    
    if(_data!=null){
      _data['_pageData'] = widget.jsRuntime.pageData;
      _data['_pageArguments'] = widget.jsRuntime.pageArguments;
      // _data['_pageParams'] = widget.jsRuntime.pageParams;
      dynamic _builder;
      String ? _tpl = widget.node.innerHtml;
      if(widget.child.isNotEmpty){
        _builder = widget.child[0];
        if(_builder is dom.Element && _builder.localName  == 'tpl'){
         _tpl = widget.jsRuntime.getTemplateById(_builder.attributes['include']!);
        }
      }
      return _getChild(_tpl,_data);
      
      // return Tuna3.parseWidget(widget.node, widget.jsRuntime,styleSheet: widget.styleSheet);
    }
    return Container();
  }

  _getChild(tplStr,data){
    JSValue tpl = Tuna3.parseTemplate(tplStr,data: data);
    if(tpl.string!.isNotEmpty  && tpl.string!="{Template Error}"){
      var  doc = parseFragment(tpl.string!.trim());
      if(doc.children.isNotEmpty){
        var _widgets = Tuna3.parseWidgets(doc.children, widget.jsRuntime,styleSheet: widget.styleSheet);
        // print(_widgets);
        if(_widgets.length>1){
          return _widgets;
        }
        return _widgets[0];
      }
    }
  }
  // 处理javascript 事件
  callHandle(params)async{
    var method = params["method"];
    var postData = params["data"];
    
    var scrollController = widget.scroller;

    if(method!=null && method.isNotEmpty){
      forceUpdate = true;
      switch(method){
        case "init":
          if(postData is List && postData.isNotEmpty){
            data = postData;
            if(mounted){
              setState(() {});
            }
          }
          return true;
        case "getRenderAt":
          forceUpdate = false;
          var ret =  {
            "at":renderAt,
            "prev":prevRenderAt
          };
          return ret;
        case "getData":
          forceUpdate = false;
          return data;
        case "sublist":
          forceUpdate = false;
          
          if(postData is Map && postData['start']!=null && postData['end']!=null){
            int end = postData['end'];
            int max = data.length-1;
            if(end>max){
              end = max;
            }
            return data.sublist(postData['start'],max);
          }
          break;
        case "getItems":
          return data;
        case "justSet":
          forceUpdate = false;
          data = postData;
          return true;
        case "pop":
          _pop();
          return true;
        case "add":
          _add(postData);
          return true;
        case "insert":
          _insert(postData["start"] ?? 0,postData["items"]);
          return true;
        case "unshift":
          _unshift(postData);
          return true;
        case "shift":
          _shift();
          return true;
        case "remove":
          // int index = params["index"]!=null?params["index"]:0;
          _remove(postData["start"],end:postData['end']);
          return true;
        case "replace":
          int start = postData["start"] ?? 0;
          int end = postData["end"] ?? postData["items"].length-1;
          _replaceRange(postData["items"],start:start,end:end);
          return true;
        case "replaceAll":
          if(postData is List){
            setState(() {
              data = postData;
            });
            return true;
          }
          return false;
        case "clear":
          _clear();
          return true;
        case "toggleReverse":
          setState(() {
            reverse = !reverse;
          });
          return reverse;
        case "setReverse":
          setState(() {
            reverse = postData;
          });
          return true;
        case "jumpTo":
          if(scrollController!=null && postData!=null && scrollController.hasClients){
            // print(postData);
            scrollController.jumpTo(double.parse(postData.toString()));
          }
          return true;
        case "animateTo":
          if(scrollController!=null && scrollController.hasClients){
            if(postData is String || postData is int || postData is double){
              scrollController.animateTo(double.parse(postData.toString()), duration: Duration(milliseconds: 250), curve: Curves.linear);
            }else if(postData is Map && postData.containsKey("offset")){
              var offset = double.parse(postData["offset"].toString());
              var duration = postData.containsKey("duration")?Duration(milliseconds: postData['duration']):Duration(milliseconds: 250);
              var curve = postData.containsKey("curve")?AnimateParse.curve(postData["curve"]):Curves.linear;
              scrollController.animateTo(offset, duration: duration, curve: curve);
            }
            return true;
          }
          return false;
        case "position":
          if(scrollController!=null && scrollController.hasClients){
            ScrollPosition pos =  scrollController.position;
            return {
              "pixes":pos.pixels,
              "max":pos.maxScrollExtent,
              "min":pos.minScrollExtent
            };
          }
          return null;
        case "listen":
          if(scrollController!=null && scrollController.hasClients){
            scrollController.addListener(() { 
              var code = 'tunaJs.getListView("'+widget.name!+'").resolveScrollListen();';
              widget.jsRuntime.evaluate(code);
            });
          }
          return true;
        case "offset":
          if(scrollController!=null && scrollController.hasClients){
            return scrollController.offset;
          }
          return null;
      }
    }
  }

  _add(items){
    if(items.isNotEmpty){
      if(items is List){
        data.addAll(items);
      }else{
        data.add(items);
      }
      if(mounted){
        setState(() {});
      }
    }
  }
  _insert(int start,items){
    if(items.isNotEmpty){
      if(items is List){
        data.insertAll(start,items);
      }else{
        data.insert(start,items);
      }
      if(mounted){
        setState(() {});
      }
    }
  }

  _unshift(items){
    if(items.isNotEmpty){
      if(items is List){
        data.insertAll(0,items);
      }else{
        data.insert(0,items);
      }
      if(mounted){
        setState(() {});
      }
    }
  }

  _pop(){
    data.removeLast();
    // print(data);
    if(mounted){
      setState(() {});
    }
  }
  _shift(){
    if(data.isNotEmpty){
      data.removeAt(0);
      if(mounted){
        setState(() {});
      }
    }
  }
  _remove(int index,{int? end}){
    if(end !=null && end is int){
      data.removeRange(index,end);
    }else{
      data.removeAt(index);
    }
    if(mounted){
      setState(() {});
    }
  }
  _replaceRange(items,{int? start,int? end}){
    data.replaceRange(start!,end!,items);
    if(mounted){
      setState(() {});
    }
  }
  _clear(){
    data.clear();
    if(mounted){
      setState(() {});
    }
  }

}

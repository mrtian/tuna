import 'dart:convert';
import 'package:html/dom.dart' as dom;
import 'package:flutter/material.dart';
import 'package:tuna3/utils/style_parse.dart';
import 'package:tuna3/widgets/constants.dart';

import '../../js_runtime.dart';
import '../../style_sheet.dart';
import '../../tuna3.dart';
import '../widget.dart';


class TWidgetTabBar extends TWidget{
  TWidgetTabBar():super(tagName: ['tabBar','tabbar']);

	@override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}) {
    Map<String,dynamic> attrs = getAttributes(node);
		return TunaTabBar(node,jsRuntime,attrs,styleSheet:styleSheet);
	}
}
class TWidgetTabView extends TWidget{
  TWidgetTabView():super(tagName: ['tabview','tabView']);
  
	@override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}) {
    Map<String,dynamic> attrs = getAttributes(node);
		return TunaTabView(node,jsRuntime,attrs,styleSheet:styleSheet);
	}
}

// 事件管理
class TabBindJsEngine{
  static insert(String tabId,JsRuntime jsRuntime,TabController controller){
    // 监听状态变化
    controller.addListener(() { 
      // print(controller.indexIsChanging);
      Map message = {
        "changing":controller.indexIsChanging,
        "offset":controller.offset,
        // "animation":controller.animation.status.toString().replaceAll("AnimationStatus.", ""),
        "previousIndex":controller.previousIndex,
        "index":controller.index,
        "length":controller.length
      };
      jsRuntime.evaluate('(function(){ var r = tunaJs.getTab("'+tabId+'");if(r){r.resolveListeners('+json.encode(message)+');} })();');
    });
    
    // 消息
    jsRuntime.addJavascriptMessageHandle("TunaTabControllerEvent."+tabId, (params){
      if(params is Map && params.containsKey("method")){
        var method = params["method"];
        var data = params["data"];
        switch(method){
          case "getStatus":
            return {
              "changing":controller.indexIsChanging,
              "offset":controller.offset,
              // "animation":controller.animation.status.toString().replaceAll("AnimationStatus.", ""),
              "previousIndex":controller.previousIndex,
              "index":controller.index,
              "length":controller.length
            };
          case "setIndex":
            controller.index = data;
            return true;
          case "animateTo":
            controller.animateTo(data["index"],duration: const Duration(seconds: 0),curve: Curves.easeIn);
            return true;
        }
      }
    });
  }
}

// ignore: must_be_immutable
class TunaTabBar extends StatefulWidget{
	final dom.Element node;
  final Map<String,dynamic> attrs;
  final JsRuntime jsRuntime;
  final TStyleSheet? styleSheet;

  dynamic map;

	TunaTabBar(this.node,this.jsRuntime,this.attrs,{Key? key,this.styleSheet}):super(key:key);

	@override
	_TunaTabBarState createState() => _TunaTabBarState();
}

class _TunaTabBarState extends State<TunaTabBar> with TickerProviderStateMixin,
AutomaticKeepAliveClientMixin{
	
  late TabController _tabController;
  late JsRuntime jsRuntime;
	int index=0;
	int tabLength =0;
  late Map<String,dynamic> attrs;

	dynamic indicatorColor;
	dynamic indicatorWeight;
	dynamic labelColor;
	dynamic labelStyle;
	dynamic unselectedLabelStyle;
	dynamic unselectedLabelColor;
	dynamic labelPadding;
	dynamic indicatorSize;
  dynamic indicatorPadding;
  dynamic tabs;
  String? tabname;
  
  @override
  bool get wantKeepAlive => true;

	@override
	void initState() {
    
    attrs  = widget.attrs;
    jsRuntime = widget.jsRuntime;

    Map tabControllers = jsRuntime.tabControllers;

		tabLength = widget.node.children.length;
    index = 0;
    try {
      index = attrs.containsKey(AttrNames.index)? int.parse(attrs[AttrNames.index]):0;
    }catch(e){
      // ignore: avoid_print
      print(e);
    }

    // print(attrs);
    
		if(attrs.containsKey("controller")) {
			tabname = attrs["controller"];
			if(tabControllers.containsKey(tabname) && tabControllers[tabname]!=null){
				_tabController = tabControllers[tabname];
        _tabController.index = index;
			}else{
				_tabController =  TabController(initialIndex: index, vsync:this,length:tabLength);
				tabControllers[tabname] = _tabController;
        // 监听事件
        TabBindJsEngine.insert(tabname!,jsRuntime, _tabController);
			}
		}else{
      _tabController =  TabController( initialIndex: index, vsync:this,length:tabLength);
    }
    

		// tab 样式
		indicatorColor = attrs.containsKey(AttrNames.indicatorColor)
				? StyleParse.hexColor(attrs[AttrNames.indicatorColor])
				: null;
		indicatorWeight = attrs.containsKey(AttrNames.indicatorWeight)
				? double.parse(attrs[AttrNames.indicatorWeight].toString())
				: 2.0;
		labelColor = attrs.containsKey(AttrNames.labelColor)
				? StyleParse.hexColor(attrs[AttrNames.labelColor])
				: null;
		labelStyle = attrs.containsKey(AttrNames.labelStyle)
				? StyleParse.textStyle( StyleParse.convertAttr(attrs[AttrNames.labelStyle]))
				: null;
		unselectedLabelStyle = attrs.containsKey(AttrNames.unselectedLabelStyle)
				? StyleParse.textStyle(StyleParse.convertAttr(attrs[AttrNames.unselectedLabelStyle]))
				: null;
		unselectedLabelColor = attrs.containsKey(AttrNames.unselectedLabelColor)
				? StyleParse.hexColor(attrs[AttrNames.unselectedLabelColor])
				: null;
		labelPadding = attrs.containsKey(AttrNames.labelPadding)
				? StyleParse.edgeInsetsGeometry(attrs[AttrNames.labelPadding])
				: null;
    indicatorPadding = attrs.containsKey("indicatorPadding")
				? StyleParse.edgeInsetsGeometry(attrs["indicatorPadding"])
				: const EdgeInsets.all(0.0);
		indicatorSize = attrs.containsKey(AttrNames.indicatorType)
				? StyleParse.indicatorSize(attrs[AttrNames.indicatorType])
				: TabBarIndicatorSize.label;

    super.initState();
  }

  @override
  void didChangeDependencies(){
    tabs ??= Tuna3.parseWidgets(widget.node.children,jsRuntime,styleSheet:widget.styleSheet);
    super.didChangeDependencies();
  }

  @override
	void dispose() {
    super.dispose();
  }

	@override
 // ignore: must_call_super
	Widget build(context){
    super.build(context);
		return TabBar(
				isScrollable:attrs.containsKey(AttrNames.isScrollable)?StyleParse.bool(attrs[AttrNames.isScrollable]):false,
				indicatorColor:indicatorColor,
        indicatorPadding:indicatorPadding,
				indicatorWeight:indicatorWeight,
				labelColor:labelColor,
				labelStyle:labelStyle,
				unselectedLabelStyle:unselectedLabelStyle,
				unselectedLabelColor:unselectedLabelColor,
				labelPadding:labelPadding,
				indicatorSize:indicatorSize,
				controller: _tabController,
				tabs: tabs
		);
	}
}

class TunaTabView extends StatefulWidget{
	final dom.Element node;
  final Map<String,dynamic> attrs;
  final JsRuntime jsRuntime;
  final TStyleSheet? styleSheet;

	// ignore: prefer_const_constructors_in_immutables
	TunaTabView(this.node,this.jsRuntime,this.attrs,{Key? key, this.styleSheet}):super(key:key);

	@override
	_TunaTabViewWidgetState createState() => _TunaTabViewWidgetState();
}

class _TunaTabViewWidgetState extends State<TunaTabView> with TickerProviderStateMixin,
AutomaticKeepAliveClientMixin{
	
  late TabController _tabController;
  late Map<String,dynamic> attrs;
	int tabLength = 0;
	String? wkey;
  int index = 0;
  dynamic tabviews;
  late JsRuntime jsRuntime;

  String? tabname;
  bool? closeSwiper;

  @override
  bool get wantKeepAlive => true;

	@override
	void initState() {
    attrs = widget.attrs;
    jsRuntime = widget.jsRuntime;
    tabLength = widget.node.children.length;
    closeSwiper = attrs['closeSwiper']=="true"?true:false;
    
    Map tabControllers = jsRuntime.tabControllers;
    index = 0;
    try {
      index = attrs.containsKey(AttrNames.index)? int.parse(attrs[AttrNames.index]):0;
    }catch(e){
      debugPrint(e.toString());
    }
		if(attrs.containsKey("controller")) {
			tabname = attrs["controller"];
			if(tabControllers.containsKey(tabname) && tabControllers[tabname]!=null){
				_tabController = tabControllers[tabname];
        _tabController.index = index;
			}else{
				_tabController =  TabController( initialIndex: index, vsync:this,length:tabLength);
				tabControllers[tabname] = _tabController;
        // 监听事件
        TabBindJsEngine.insert(tabname!,jsRuntime, _tabController);
			}
		}else{
      _tabController =  TabController( initialIndex: index, vsync:this,length:tabLength);
    }
		super.initState();
	}

  
  @override
  void didChangeDependencies(){
    tabviews ??= Tuna3.parseWidgets(widget.node.children,jsRuntime,styleSheet:widget.styleSheet);
    super.didChangeDependencies();
  }

	@override
	void dispose() {
		super.dispose();
	}

	@override
  // ignore: must_call_super
	Widget build(context){
    super.build(context);
    
		return  TabBarView(
				controller: _tabController,
				children: tabviews,
        physics:closeSwiper!?const NeverScrollableScrollPhysics():null
		);
	}
}


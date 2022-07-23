import 'dart:collection';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/utils/style_parse.dart';

import '../../js_runtime.dart';
import '../constants.dart';
import '../widget.dart';


class TWidgetIndexedStack extends TWidget{
  TWidgetIndexedStack():super(tagName: 'indexedStack');
  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}){
    return TunaIndexedStackWidget(node,jsRuntime:jsRuntime,styleSheet:styleSheet);
  }
}


class TunaIndexedStackWidget extends StatefulWidget{
	final dom.Element node;
  final TStyleSheet? styleSheet;
  final JsRuntime jsRuntime;
	const TunaIndexedStackWidget(this.node,{Key? key,required this.jsRuntime, this.styleSheet}):super(key:key);

	@override
  _TunaIndexedStackWidgetState createState()=>_TunaIndexedStackWidgetState();
}

class _TunaIndexedStackWidgetState extends State<TunaIndexedStackWidget> with AutomaticKeepAliveClientMixin{
	
	int index = 0;
  int prevIndex = 0;
	var alignment;
	var textDirection;

	List <Widget>? items;
	dom.Element? node;
  String? widgetName;

  TStyleSheet? styleSheet;
  late JsRuntime jsRuntime;

  bool hasBinding = false;
  
  @override
  bool get wantKeepAlive => true;

	@override
	initState(){
    super.initState();
		node = widget.node;
		List<dom.Element> children = node!.children;
    LinkedHashMap<Object, String> attrs = node!.attributes;
    styleSheet = widget.styleSheet;
    jsRuntime = widget.jsRuntime;

		index = attrs.containsKey(AttrNames.index) ? int.parse(attrs[AttrNames.index]!):0;
		alignment = attrs.containsKey(AttrNames.alignment) ? StyleParse.alignment(attrs[AttrNames.alignment]!): AlignmentDirectional.topStart;
		textDirection = attrs.containsKey(AttrNames.textDirection) ? StyleParse.textDirection(attrs[AttrNames.textDirection]!) : null;
    // print(children);
    items = Tuna3.parseWidgets(children,jsRuntime,styleSheet: styleSheet);
    // print(items);

    if(attrs.containsKey(AttrNames.name) && !hasBinding){
      widgetName = attrs[AttrNames.name];
      widget.jsRuntime.addWidgetMessageHandle("IndexedStack", widgetName!, handleEvent);
      // 页面渲染完成后执行
      var widgetsBinding = WidgetsBinding.instance;
      widgetsBinding.addPostFrameCallback((callback)async{
          if(!hasBinding &&  !jsRuntime.onDispose ){
            hasBinding =  true;
            jsRuntime.resolveWidgetReady("IndexedStack", widgetName!);
          }
      });
    }
	}

  handleEvent(params){
    // print(params);
    if(params is Map){
      var method = params["method"];
      var data = params["data"];
      switch(method){
        case "init":
          return {"prevIndex":prevIndex,"index":index};
        case "changeIndex":
          if(data!=null && data is int){
            prevIndex = index;
            index = data;
            setState((){});
            evaluateChange();
            return true;
          }
          return false;
      }
    }
  }

  evaluateChange(){
    if(widgetName==null){
      return;
    }
    var obj = {
      "index":index,
      "prevIndex":prevIndex
    };
    var dispatchCode = 'try{ T.getIndexedStack("'+widgetName!+'").resolveOnChange('+json.encode(obj)+')}catch(e){ console.log(e.toString());};';
    jsRuntime.evaluate(dispatchCode);
  }

	void handleBarItem(i){
    setState((){
      index = i;
    });
  }

	@override
	void didChangeDependencies(){
	  super.didChangeDependencies();
	}


	@override
	dispose(){
		super.dispose();
	}

	@override
  // ignore: must_call_super
  Widget build(context){
		return IndexedStack(
			alignment: alignment, 
			textDirection:textDirection, 
			sizing: StackFit.loose, 
			index: index, 
			children: items!
		);
	}

  
}

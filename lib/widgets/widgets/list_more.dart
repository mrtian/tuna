import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/jscore/core/js_value.dart';
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/utils/style_parse.dart';
import '../../js_runtime.dart';
import '../../style_sheet.dart';
import '../widget.dart';


class TWidgetListMore extends TWidget{

  TWidgetListMore():super(tagName: ['mlist']);

  @override
  parse(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}){
    Map<String,dynamic> attrs = getAttributes(node);
    String? name = attrs['name'];
    String? item = attrs['item'];
    String? indicator = attrs['indicator'];
    String? itemTpl = jsRuntime.getTemplateById(item!);

    if(name!=null &&  itemTpl!=null ){
      ListConfig listConfig = ListConfig(
        itemBuilder: (BuildContext context, dynamic itemData, int index){
          JSValue val = Tuna3.parseTemplate(itemTpl,data: itemData.data);
          if(val.string!.isNotEmpty){
            dom.DocumentFragment fragment =  parseFragment(val.string);
            return Tuna3.parseWidget(fragment.children[0], jsRuntime,styleSheet: styleSheet);
          }else{
            return const Text("can't builder item!");
          }
        }, 
        sourceList: ListRepository(name,jsRuntime),
        indicatorBuilder: indicator!=null? (context, IndicatorStatus status){
          String indicatorTpl = jsRuntime.getTemplateById(indicator);
          JSValue val = Tuna3.parseTemplate(indicatorTpl,data: {"status":parseIndicatorStatus(status)});
          if(val.string!.isNotEmpty){
            dom.DocumentFragment fragment =  parseFragment(val.string);
            return Tuna3.parseWidget(fragment.children[0], jsRuntime,styleSheet: styleSheet);
          }else{
            return const Text("can't builder indicator!");
          }
        }:null,
        extendedListDelegate: ExtendedListDelegate(
              closeToTrailing: attrs.containsKey("trailing")?StyleParse.bool(attrs['trailing']):false
            ),
      );

      return LoadingMoreList(
        listConfig,
        key:attrs.containsKey("key")? Key(attrs['key']):null,
        onScrollNotification:attrs.containsKey("onScroll") ? (ScrollNotification notifiction){
          print(notifiction);
          return true;
        }:null
      );
    }
  }

  parseIndicatorStatus(IndicatorStatus status){
    switch(status){
      case IndicatorStatus.empty:
        return "empty";
      case IndicatorStatus.none:
        return "none";
      case IndicatorStatus.loadingMoreBusying:
        return "loadingMoreBusying";
      case IndicatorStatus.fullScreenBusying:
        return "fullScreenBusying";
      case IndicatorStatus.error:
        return "error";
      case IndicatorStatus.fullScreenError:
        return "fullScreenError";
      case IndicatorStatus.noMoreLoad:
        return "noMoreLoad";
    }
  }
}

class DataItem{
  dynamic data;
  DataItem(data);
}

class ListRepository extends LoadingMoreBase<DataItem> {

  bool _hasMore = true;
  bool forceRefresh = false;
  final String name;
  final JsRuntime jsRuntime;

  ListRepository(this.name,this.jsRuntime);

  @override
  bool get hasMore => _hasMore  || forceRefresh;

  @override
  // ignore: avoid_renaming_method_parameters
  Future<bool> refresh([bool clearBeforeRequest = false]) async {
    _hasMore = true;
    forceRefresh = !clearBeforeRequest;
    var result = await super.refresh(clearBeforeRequest);
    forceRefresh = false;
    return result;
  }

  @override
  Future<bool> loadData([bool isloadMoreAction = false]) async {
    return true;
  }
}
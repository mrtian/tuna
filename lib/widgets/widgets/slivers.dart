
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/utils/style_parse.dart';
import '../../tuna3.dart';
import '../constants.dart';
import '../widget.dart';

// normal list
class TWidgetSliverPadding extends TWidget{
  
  TWidgetSliverPadding():super(tagName: ['sliverPadding','spadding']);

  @override
  parse(dom.Element node, JsRuntime jsRuntime, {TStyleSheet? styleSheet}) {
    var attrs = getAttributes(node);
  	return SliverPadding(
  		padding:attrs.containsKey(AttrNames.padding)?StyleParse.edgeInsetsGeometry(attrs[AttrNames.padding]):StyleParse.edgeInsetsGeometry("0"), 
  		sliver:Tuna3.parseWidget(node.children[0],jsRuntime,styleSheet:styleSheet)
  	);
  }
}

class TSliverPersistentHeader extends TWidget{
  TSliverPersistentHeader():super(tagName: ['sliverPersistentHeader','sheader']);

	@override
  parse(dom.Element node, JsRuntime jsRuntime, {TStyleSheet? styleSheet}) {
      var attrs = getAttributes(node);
	  	return SliverPersistentHeader(
	  		delegate:_SliverHeaderDelegate(
	  			minHeight:attrs.containsKey(AttrNames.minHeight)?double.parse(attrs[AttrNames.minHeight]):30.0,
	  			maxHeight:attrs.containsKey(AttrNames.maxHeight)?double.parse(attrs[AttrNames.maxHeight]):60.0,
	  			child:Tuna3.parseWidget(node.children[0],jsRuntime,styleSheet:styleSheet)
	  		),
	  		pinned: attrs.containsKey(AttrNames.pinned)?StyleParse.bool(attrs[AttrNames.pinned]):false,
	  		floating: attrs.containsKey(AttrNames.floating)?StyleParse.bool(attrs[AttrNames.floating]):false,
	  	);
	  }
}

class TunaSliverToBoxAdapter extends TWidget{
  TunaSliverToBoxAdapter():super(tagName: ['sliverToBoxAdapter','sbox']);

	@override
  parse(dom.Element node, JsRuntime jsRuntime, {TStyleSheet? styleSheet}) {
		return SliverToBoxAdapter(
			child:Tuna3.parseWidget(node.children[0],jsRuntime,styleSheet:styleSheet)
		);
	}
}



class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SliverHeaderDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double? minHeight;
  final double? maxHeight;
  final Widget? child;

  @override
  double get minExtent => minHeight!;

  @override
  double get maxExtent => maxHeight!;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
	    return child!;
  }

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}

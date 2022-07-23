import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/utils/style_parse.dart';

import '../../js_runtime.dart';
import '../../style_sheet.dart';
import '../constants.dart';
import '../widget.dart';

class TWidgetSpinKit extends TWidget {
  TWidgetSpinKit():super(tagName: ['spinkit','spinKit']);

  @override
  parse(dom.Element node, JsRuntime jsRuntime, {TStyleSheet? styleSheet}) {
    Map<String,dynamic> attrs = getAttributes(node);
    dynamic color = attrs.containsKey(AttrNames.color) ? StyleParse.hexColor(attrs[AttrNames.color]):Colors.white;
    dynamic size = attrs.containsKey(AttrNames.size) ? double.parse(attrs[AttrNames.size]):32.0;
    dynamic spin = attrs.containsKey(AttrNames.name) ? attrs[AttrNames.name]:'circle';
    dynamic duration = attrs.containsKey("duration") ? Duration(milliseconds: int.parse(attrs["duration"])): Duration(milliseconds: 2000);


  	switch(spin){
  		case 'fadingCicle':
  			return SpinKitFadingCircle(color:color,size:size, duration:duration);
  		// case 'rotatingPlane':
  		// 	return SpinKitRotatingPlane;
  		case 'doubleBounce':
  			return SpinKitDoubleBounce(color:color,size:size, duration:duration);
  		case 'wave':
  			return SpinKitWave(color:color,size:size, duration:duration);
  		case 'wanderingCubes':
  			return SpinKitWanderingCubes(color:color,size:size, duration:duration);
  		case 'fadingFour':
  			return SpinKitFadingFour(color:color,size:size, duration:duration);
  		case 'fadingCube':
  			return SpinKitFadingCube(color:color,size:size, duration:duration);
  		case 'pulse':
  			return SpinKitPulse(color:color,size:size, duration:duration);
  		case 'chasingDots':
  			return SpinKitChasingDots(color:color,size:size, duration:duration);
  		case 'threeBounce':
  			return SpinKitThreeBounce(color:color,size:size, duration:duration);
  		case 'circle':
  			return SpinKitCircle(color:color,size:size, duration:duration);
  		case 'cubeGrid':
  			return SpinKitCubeGrid(color:color,size:size, duration:duration);
  		case 'rotatingCircle':
  			return SpinKitRotatingCircle(color:color,size:size, duration:duration);
  		case 'foldingCube':
  			return SpinKitFoldingCube(color:color,size:size, duration:duration);
  		case 'pumpingHeart':
  			return SpinKitPumpingHeart(color:color,size:size, duration:duration);
  		case 'dualRing':
  			return SpinKitDualRing(color:color,size:size, duration:duration);
  		case 'hourGlass':
  			return SpinKitHourGlass(color:color,size:size, duration:duration);
  		// case 'pouringHourGlass':
  		// 	return SpinKitPouringHourGlass(color:color,size:size, duration:duration);
  		case 'fadingGrid':
  			return SpinKitFadingGrid(color:color,size:size, duration:duration);
  		case 'ring':
  			return SpinKitRing(color:color,size:size, duration:duration);
  		case 'ripple':
  			return SpinKitRipple(color:color,size:size, duration:duration);	
  		case 'spinningCircle':
      default:
  			return SpinKitSpinningCircle(color:color,size:size, duration:duration);	
  	}

  }
}

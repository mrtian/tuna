import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'dart:ui' as ui;
import 'package:html/dom.dart' as dom;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';

import '../../tuna3.dart';
import '../widget.dart';


class TWidgetRepaint  extends TWidget{
  TWidgetRepaint():super(tagName: 'repaint');

  @override
  parse(dom.Element node, JsRuntime jsRuntime, {TStyleSheet? styleSheet}) {
    return TunaRepaint(node,jsRuntime,getAttributes(node),styleSheet:styleSheet);
  }
}

class TunaRepaint extends StatefulWidget {
  final dom.Element node;
  final JsRuntime jsRuntime;
  final Map<String,dynamic> attrs;
  final TStyleSheet? styleSheet;
  TunaRepaint(this.node,this.jsRuntime,this.attrs,{Key? key,this.styleSheet});

  @override
  _TunaRepaintState createState() => _TunaRepaintState();
}

class _TunaRepaintState extends State<TunaRepaint> {

  Map<String, dynamic>? attrs;
  GlobalKey? _repaintKey;
  String? name;

  bool hasBinding = false;

  @override
  void initState() {
    attrs = widget.attrs;
    _repaintKey = GlobalKey();
    name = attrs!['name'];
    if(name!=null && !hasBinding){
      widget.jsRuntime.addWidgetMessageHandle("Repaint", name!, (params)async{
        if(params is Map && params.containsKey("method")){
          String method = params['method'];
          switch(method){
            case "getImgData":
              return await getImgData();
            case "capture":
              return await handleCapture();
          }
        }
      });
      // 页面渲染完成后执行
      var widgetsBinding = WidgetsBinding.instance;
      widgetsBinding.addPostFrameCallback((callback)async{
          if(!hasBinding &&  !widget.jsRuntime.onDispose ){
            hasBinding =  true;
            widget.jsRuntime.resolveWidgetReady("Repaint", name!);
          }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 获取图片数据
  getImgData() async {
    Uint8List imgBytes = await _getRepaitImgData();
    String imgB64 =  base64Encode(imgBytes);
    return imgB64;
  }

  // 获取图片数据
  _getRepaitImgData() async {
    RenderRepaintBoundary? boundary =
        _repaintKey!.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image hbImage =
        await boundary.toImage(pixelRatio: ui.window.devicePixelRatio);
    ByteData? byteData =
        await hbImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    return pngBytes;
  }

  // 截取图片保存
  handleCapture() async {
    Uint8List pngBytes = await _getRepaitImgData();
    var isGranted = false;
    var photosStatus = await Permission.storage.status;
    isGranted = photosStatus.isGranted;

    if (isGranted) {
      try{
        var ret = await ImageGallerySaver.saveImage(pngBytes);
        return ret;
      }catch(e){
        print(e);
      }
      return false;
    } else {
      // widget.map.jsEngine.toast("您未开启相册存储权限，请到设置中心开启。");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var child =
        widget.node.children.isNotEmpty
            ? Tuna3.parseWidget(widget.node.children[0], widget.jsRuntime,styleSheet: widget.styleSheet)
            : null;
    return RepaintBoundary(key: _repaintKey, child: child);
  }
}

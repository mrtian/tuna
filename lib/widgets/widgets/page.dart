import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/js_runtime.dart';
import 'package:http/http.dart' as http;
import 'package:tuna3/utils/style_parse.dart';

import '../../page.dart';
import '../../style_sheet.dart';
import '../widget.dart';


class TWidgetPage extends TWidget{
  
  TWidgetPage():super(tagName:'page');

  @override
  parse (dom.Element node,JsRuntime jsRuntime, {TStyleSheet? styleSheet}){
    Map<String, dynamic> attrs = getAttributes(node);
    String? pageName = attrs["name"];
    // print(map.jsEngine.isInline);
    if(attrs.containsKey("include") && attrs["include"] is String && attrs["include"].isNotEmpty){
      // include page
      String? template = jsRuntime.getTemplateById(attrs["include"]);
      if(template!=null && template.isNotEmpty){
        
        return TunaPage(
          route:pageName,
          string:template,
          // data:data,
        );
      }else{
        return Text("页面加载错误，模板不存在.");
      }
    }else if(attrs.containsKey("file") && attrs["file"].isNotEmpty){
      // file page
      return FutureBuilder(
        builder:(context,snap){
          if(snap.connectionState == ConnectionState.done){
            if(snap.hasError){
              print(snap.error);
              return Text(snap.error.toString());
            }
            if(snap.data=="error"){
              return Text("文件[${attrs['file']}] 不存在.");
            }
            
            return TunaPage(
              string:snap.data.toString(),
              route:pageName,
            );
          }else if(snap.hasError){
            print(snap.error);
            return Text(snap.error.toString());
          }
          return Container();
        },
        future: ()async{
          var filePath = attrs["file"];
          var file = File(filePath);
          if(await file.exists()){
            return await file.readAsString();
          }else{
            return "error";
          }
        }(),
      );
    }else if(attrs.containsKey("assets") && attrs["assets"].isNotEmpty){
      // assets page
      return FutureBuilder(
        builder:(context,snap){
          if(snap.connectionState == ConnectionState.done){
            if(snap.hasError){
              print(snap.error);
              return Text(snap.error.toString());
            }
            if(snap.data=="error"){
              return Text("Assets文件[${attrs['assets']}] 不存在.");
            }
            try{
              return TunaPage(
                string:snap.data.toString(),
                route:pageName,
              );
            }catch(e){
              return Text(e.toString());
            }
          }else if(snap.hasError){
            print(snap.error);
            return Text(snap.error.toString());
          }else{
            return Container();
          }
        },
        future: ()async{
          try{
            return await rootBundle.loadString(attrs["assets"]);
          }catch(e){
            print(e);
            return "error";
          }
        }(),
      );
    }else if(attrs.containsKey("url") && attrs['url'].isNotEmpty){
      return FutureBuilder(
        builder:(context,snap){
          if(snap.connectionState == ConnectionState.done){
            if(snap.hasError){
              print(snap.error);
              return Text(snap.error.toString());
            }
            if(snap.data=="error"){
              return Text("无法打开页面.");
            }
            try{
            return TunaPage(
              string:snap.data.toString(),
              route:pageName,
              );
            }catch(e){
              return Text(e.toString());
            }
          }else if(snap.hasError){
            print(snap.error);
            return Text(snap.error.toString());
          }else{
            return Container();
          }
        },
        future: ()async{
          try{
            return await http.get(attrs["url"],headers: StyleParse.convertAttr(attrs['header']));
          }catch(e){
            print(e);
            return "error";
          }
        }(),
      );
    }else if(attrs.containsKey("route") && TunaTemplate.routes.containsKey(attrs['route'])){
      try{
        return TunaPage(route: attrs['route'],);
      }catch(e){
        print(e);
      }
    }
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/tuna3.dart';
import 'package:tuna3/utils/style_parse.dart';

class XDialog{

  static inserToJsRuntime(JsRuntime jsRuntime){
    jsRuntime.addJavascriptMessageHandle("XDialog.alert", (message) async {
      var ret;
      if(message is String){
        ret =  await Get.dialog(getDefaultDialogWidget(message,jsRuntime));
      }else if(message is Map){
        String msg = message['message'];
        Map<String,dynamic>? params = message['params'];
        if(params!=null && params.isNotEmpty){
          ret = await  Get.dialog(getDefaultDialogWidget(msg,jsRuntime,title:params['title'],actions:params['actions']),
            barrierColor: params['barrierColor'],
            barrierDismissible: params['barrierDismissible']??false,
            useSafeArea:params['useSafeArea']??false,
            arguments:params['arguments'],
            transitionDuration:params['transitionDuration'],
            transitionCurve:params['transitionCurve']
          );
        }else{
          ret = await Get.dialog(getDefaultDialogWidget(msg,jsRuntime));
        }
      }
      return ret;
    });
    // MODAL
    jsRuntime.addJavascriptMessageHandle("XDialog.modal", (message)async{
      var frag = parseFragment(message);
      return await Get.dialog(Tuna3.parseWidget(frag.children[0], jsRuntime));
    });
    // snackbar
    jsRuntime.addJavascriptMessageHandle("XDialog.snackbar", (message)async{
      var options = message['options'];
      options ??= {};

      Get.showSnackbar(GetSnackBar(
        title:message['title'],
        borderRadius:options['radius']??8.0,
        onTap: options['milliseconds']==null? (_o){
          Get.back();
        }:null,
        backgroundColor: options['backgroundColor']!=null?StyleParse.hexColor(options['backgroundColor']):const Color(0xF9303030),
        message: message['message'],
        // messageText: message['messageText'],
        // icon:message['icon'],
        snackStyle:options.containsKey('snackStyle')?_parseSnackStyle(options['snackStyle']):SnackStyle.FLOATING,
        padding: options.containsKey('padding')?StyleParse.edgeInsetsGeometry(options['padding']): const EdgeInsets.all(16.0),
        margin: options.containsKey('margin')?StyleParse.edgeInsetsGeometry(options['margin']): const EdgeInsets.all(25.0),
        showProgressIndicator:options.containsKey("showProgressIndicator")?options['showProgressIndicator']:false,
        isDismissible:options.containsKey("isDismissible")?options['isDismissible']:true,
        borderWidth:options['borderWidth'] ?? 0.5,
        snackPosition:options['position']!=null? _parseSnackPosition(options['position']):SnackPosition.BOTTOM,
        duration: options['milliseconds']!=null ?  (options['milliseconds']is int?Duration(milliseconds: options['milliseconds']):null):const Duration(milliseconds: 1800),
      ));
    });
  }

  static _parseSnackStyle(String snackStyle){
    switch(snackStyle){
      case "grounded":
        return SnackStyle.GROUNDED;
      default:
        return SnackStyle.FLOATING;
    }
  }

  static _parseSnackPosition(String position){
    switch(position){
      case "bottom":
        return SnackPosition.BOTTOM;
      case "top":
        return SnackPosition.TOP;
      default:
        return SnackPosition.BOTTOM;
    }
  }

  // 获取默认弹窗
  static getDefaultDialogWidget(String message,JsRuntime jsRuntime, {String? title,List? actions}){
    List<Widget> children = [];
    if(title!=null){
      children.add(
        Padding(
          padding:const EdgeInsets.fromLTRB(15.0,15.0,15.0,0.0),
          child: Text(title,style: const TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold, color: Colors.black87, decoration: TextDecoration.none),),
        ),
      );
    }
    children.add(
      Padding(
          padding:const EdgeInsets.all(15.0),
          child:Text(message,style: const TextStyle(fontSize: 17.0,color: Colors.black87,fontWeight: FontWeight.normal,decoration: TextDecoration.none),)
        )
    );
    children.add(const Divider(height: 0.5,));
    
    if(actions!=null){
      if(actions is String){
        var frag = parseFragment(actions);
        children.add(Tuna3.parseWidget(frag.children[0], jsRuntime));
      }else if(actions is List){
        Color defaultColor = Colors.white;
        double textSize = 17.0;
        Color defaultTextColor = Colors.black87;
        List<Widget> _actionChildren = [];
        int maxL = actions.length - 1;
        int _i = 0;
        
        actions.forEach((element) { 
          Radius bs = _i==0 ? const Radius.circular(8.0) : const Radius.circular(0.0);
          Radius be = _i==maxL ? const Radius.circular(8.0) : const Radius.circular(0.0);
          if(element is Map){
            _actionChildren.add(
              Expanded(child: GestureDetector(
                onTap: (){  Get.back(result: element['value']); } ,
                child: Container(
                  child:Container(
                    padding: const EdgeInsets.fromLTRB(0.0,15.0,0.0,15.0),
                    decoration: BoxDecoration(
                      color:element.containsKey("color")?StyleParse.hexColor(element['color']):defaultColor,
                      borderRadius:  BorderRadius.only(
                        bottomLeft: bs,
                        bottomRight: be
                      )
                    ),
                    alignment: Alignment.center,
                    child: Text(element['text'],style: TextStyle(
                      fontWeight: FontWeight.normal,decoration: TextDecoration.none,
                      color: element.containsKey("textColor")?StyleParse.hexColor(element['textColor']):defaultTextColor,
                      fontSize: element.containsKey("textSize")?StyleParse.hexColor(element['textSize']):textSize,
                    ),),
                  ),
                  decoration: BoxDecoration(
                    border: _i!=maxL ?  Border(right: BorderSide(width: 0.5,color:Colors.grey[300]!)):null
                  ),
                )
              )
            ));
            _i++;
            
          }else if(element is String){
            _actionChildren.add(
              Expanded(child: GestureDetector(
                onTap: (){ Get.back(); } ,
                child: Container(
                  child:Container(
                    padding: const EdgeInsets.fromLTRB(0.0,15.0,0.0,15.0),
                    decoration: BoxDecoration(
                      color:defaultColor,
                      borderRadius:  BorderRadius.only(
                        bottomLeft: bs,
                        bottomRight: be
                      )
                    ),
                    alignment: Alignment.center,
                    child: Text(element,style: TextStyle(
                      fontWeight: FontWeight.normal,decoration: TextDecoration.none,
                      color: defaultTextColor,
                      fontSize: textSize,
                    ),),
                  ),
                  decoration: BoxDecoration(
                    border: _i!=maxL ?  Border(right: BorderSide(width: 0.5,color:Colors.grey[300]!)):null
                  ),
                )
              )
            ));
          }
        });
        children.add(Row(children: _actionChildren,));
      }
    }else{
      Widget closeAction = GestureDetector(
        onTap: () => Get.back(),
        child: Container( 
          decoration: const BoxDecoration(
            color:Colors.white,
            borderRadius: BorderRadiusDirectional.only(bottomStart:Radius.circular(8.0),bottomEnd: Radius.circular(8.0))
          ),
          padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15.0),
          width: Size.infinite.width, 
          alignment: Alignment.center, 
          child: const Text("知道了",
            style:TextStyle(
              fontSize: 17.0,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none
            ),
          )
        ),
      );
      children.add(closeAction);
    }
    // children.add(const SizedBox(height: 10.0,));

    Widget widget = Center(
      child: Column(
            children: [
              Container(
                width: Get.width-60,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusDirectional.circular(8.0)),
                ),
                // padding: const EdgeInsets.all(15.0),
                margin: const EdgeInsets.all(30.0),
                child: Column(children: children,),
              )
            ],
            mainAxisSize: MainAxisSize.min,
          ),
    );
      
    return widget;
  }
}
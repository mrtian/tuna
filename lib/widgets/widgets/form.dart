import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:html/dom.dart' as dom;
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/utils/input_parse.dart';
import 'package:tuna3/utils/style_parse.dart';

import '../widget.dart';

class TWidgetInput extends TStyleWidget{

  TWidgetInput():super(tagName: 'input');

  @override
  Widget build(dom.Element node,JsRuntime jsRuntime,{TStyleSheet? styleSheet}) {
    var attrs = getAttributes(node);
    var type = attrs["type"];

    PageStorageKey inputKey = PageStorageKey(jsRuntime.id+":"+md5.convert(utf8.encode(node.outerHtml)).toString());
    if(type=="radio"){
      return TunaRadioInput(node,ikey:inputKey,jsRuntime:jsRuntime,attrs:attrs);
    }else if(type=="checkbox"){
      return TunaCheckbox(node,ikey:inputKey,jsRuntime:jsRuntime,attrs:attrs);
    }else{
      return TunaTextField(node,ikey:inputKey,jsRuntime:jsRuntime,attrs:attrs);
    }
  }

  static FocusNode? currentNode;
  static getCurrentFocusNode(){
    return currentNode;
  }

}

// textfield
class TunaTextField extends StatefulWidget{

  final dom.Element node;
  final PageStorageKey? ikey;
  final JsRuntime jsRuntime;
  final Map<String,dynamic> attrs;
  
  TunaTextField(this.node,{this.ikey, required this.jsRuntime,required this.attrs});

  @override 
  _TunaTextFieldState createState() => _TunaTextFieldState();
}

class _TunaTextFieldState extends State<TunaTextField> {
  
  late Map<String,dynamic> attrs;
  String? value;
  String? inputName;

  TextField? input;
  
  TextEditingController? controller;

  int? maxLines;
  int? minLines;
  int? maxLength;
  bool? maxLengthEnforced;

  double? cursorWidth;
  double? cursorHeight;
  Radius? cursorRadius;
  Color? cursorColor;

  var scrollPadding;
  bool? enableInteractiveSelection;
  bool? enabled;

  bool? showCursor;
  bool? readOnly;
  bool? autofocus;
  bool? expands;
  bool? isOnCounting;

  var decoration;

  var keyboardType;
  var textInputAction;
  var textCapitalization;
  Brightness? keyboardAppearance;

  var textAlign;
  var textDirection;

  var onChanged;
  var onSubmitted;
  var onEditingComplete;

  var  style;
  var  strutStyle;
  List<TextInputFormatter>? inputFormatters;
  FocusNode? focusNode;

  bool hasBinding = false;
  bool obscureText = false;

  var inputWidgetMessageHandle;

  @override 
  void initState() {
    super.initState();

    if(hasBinding){
      return;
    }

    focusNode = FocusNode();

    focusNode!.addListener(() { 
      if(focusNode!.hasFocus){
        // 解决键盘切换问题，必须使用delayed,否则无效
        if( TWidgetInput.currentNode!=focusNode && Platform.isAndroid ){
          focusNode!.unfocus();
          Future.delayed(Duration(milliseconds: 5),(){
            focusNode!.requestFocus();
          });
        }
        TWidgetInput.currentNode = focusNode;
      }
    });
    

    attrs = widget.attrs;
    value = attrs['value'];
    inputName = attrs['name'];

    controller = TextEditingController(
      text:value ?? ""
    );

    maxLines = attrs['maxLines']== null?null:int.parse(attrs['maxLines']);
    minLines = attrs['minLines']== null?1:int.parse(attrs['minLines']);
    maxLength = attrs["maxLength"]==null?null:int.parse(attrs["maxLength"]);
    maxLengthEnforced = attrs["maxLengthEnforced"]=="true"?true:false;

    cursorWidth = attrs['cursorWidth']==null?1.5:double.parse(attrs["cursorWidth"]);
    cursorHeight = attrs['cursorHeight']==null?null:double.parse(attrs["cursorHeight"]);
    cursorColor = attrs['cursorColor']==null?Colors.blue:StyleParse.hexColor(attrs['cursorColor']);
    cursorRadius =  attrs["cursorRadius"]!=null?Radius.circular(double.parse(attrs["cursorRadius"])):null;
    keyboardAppearance = attrs["keyboardAppearance"]==null?null : attrs['keyboardAppearance']=='dark'?Brightness.dark:null; 
    scrollPadding = attrs['scrollPadding']==null?EdgeInsets.all(0.0):StyleParse.edgeInsetsGeometry(attrs['scrollPadding']);
    
    enableInteractiveSelection = attrs['enableInteractiveSelection']=="false"?false:true;
    showCursor = attrs["showCursor"]=="false"?false:true;
    readOnly = attrs["readOnly"]=="true"?true:false;
    autofocus = attrs['autofocus']=='true'?true:false;
    expands = attrs['expands'] =='true'?true:false;

    // 可输入控制
    if(attrs['formatters']!=null){
      var formatters = StyleParse.convertAttr(attrs['formatters']);
      if(formatters is Map && formatters.isNotEmpty){
        inputFormatters = [];
        if(formatters.containsKey("allow")){
          inputFormatters!.add(FilteringTextInputFormatter.allow(RegExp(formatters['allow'])));
        }

        if(formatters.containsKey("deny")){
          inputFormatters!.add(FilteringTextInputFormatter.deny(RegExp(formatters['allow'])));
        }
      }
    }

    decoration = InputDecoration(
      isCollapsed: attrs['collapsed']=='true'?true:false,
      hintText: attrs['placeholder'],
      errorBorder: const OutlineInputBorder(borderSide: BorderSide.none,gapPadding: 0.0),
      filled: attrs['filled']!=null?true:false,
      fillColor: attrs['filled']!=null?StyleParse.hexColor(attrs['filled']):null,
      hintStyle: attrs['hintStyle']!=null?StyleParse.textStyle(StyleParse.convertAttr(attrs['hintStyle'])) : TextStyle(color: Colors.grey,fontSize: 14.0),
      focusColor: attrs['focusColor']!=null?StyleParse.hexColor(attrs['focusColor']):Colors.blue,
      focusedBorder: attrs['focusBorder']!=null?InputParse.border( attrs['focusBorder'],radius:attrs['radius'] ):attrs['collapsed']=='true'?null:const UnderlineInputBorder(
          borderSide:BorderSide(
            color:Colors.blue,
            width:0.5,
          ),
          borderRadius: BorderRadius.all( Radius.circular(0.0))
      ),
      contentPadding: attrs['contentpadding']==null?const EdgeInsets.all(0.0):StyleParse.edgeInsetsGeometry(attrs['contentpadding']),
      border: attrs['border']==null ? attrs['collapsed']=='true'?null:const UnderlineInputBorder(
          borderSide:BorderSide(
            color:Colors.grey,
            width:0.5,
          ),
          borderRadius: BorderRadius.all( Radius.circular(0.0))
      ):InputParse.border( attrs['border'],radius:attrs['radius'] )
    );

    keyboardType = StyleParse.keyboardType(attrs['keyboardtype']);
    
    textInputAction = attrs['actionType']!=null? StyleParse.inputAction(attrs['actionType']) :null;
    // print(textInputAction);
    textCapitalization = attrs['textcapitalization']!=null? StyleParse.textCapitalization(attrs['textcapitalization']):TextCapitalization.none;
    
    style = StyleParse.convertAttr(attrs['style']);
    strutStyle = StyleParse.convertAttr(attrs['strutStyle']);
  
    textAlign = TextAlign.left;
    
    if(style!=null){
      if(style.containsKey("text") && style["text"] is Map){
        textAlign = style["text"].containsKey("align")?StyleParse.textAlign(style["text"]["align"]):TextAlign.left;
        textDirection = style["text"].containsKey("direction")?StyleParse.textDirection(style["text"]["direction"]):null;
        if(style["text"].containsKey("shadow")){
          style['shadows'] = style["text"]["shadow"];
        }
      }
      if(style.containsKey("line") && style['line'] is Map){  
        style['line-height'] = style['line'].containsKey("height")? style['line']['height']:null;
      }
    }

    if(strutStyle!=null && strutStyle is Map && strutStyle.isNotEmpty){
      if(strutStyle.containsKey("line") && strutStyle['line'] is Map){  
        strutStyle['line-height'] = strutStyle['line'].containsKey("height")? strutStyle['line']['height']:null;
      }
    }
    
    var ext = attrs["ext"];
    if (ext!=null) {
      ext = StyleParse.convertAttr(ext);
    }

    var onChangedVal = attrs["onChanged"]??attrs['onchanged'];
    // print(attrs);
    if(onChangedVal!=null){
      onChanged = (value) {
        var p;
        if (ext != null) {
          p = {"ext":ext, "_value":value};
        }else{
          p = value;
        }
        
        widget.jsRuntime.evaluateFunc(onChangedVal, p);
      };
    }

    var onSubmitVal = attrs["onSubmit"]??attrs["onsubmit"];
    if(onSubmitVal!=null){
      onSubmitted = (value){
        var p;
        if (ext != null) {
          p = {"ext":ext, "_value":value};
        }else{
          p = value;
        }
        widget.jsRuntime.evaluateFunc(onSubmitVal,p);
      };
    }

    var onEditingCompleteVal = attrs["onEditingComplete"]??attrs["oneditingcomplete"];
    if(onEditingCompleteVal!=null){
      onEditingComplete = (){
        var p;
        var value = controller!.text;
        if (ext != null) {
          p = {"ext":ext, "_value":value};
        }else {
          p = value;
        }
        widget.jsRuntime.evaluateFunc(onEditingCompleteVal, p);
      };
    }

    if(inputName!=null){
      // 避免重复注入
      if(!hasBinding){
        inputWidgetMessageHandle = (params){
          if(params is Map && params.containsKey("method")){
            var method = params['method'];
            var data = params['data'];

            switch(method){
              case "clear":
                controller!.clear();
                return true;
              case "value":
                controller!.text = data;
                return true;
              case "getValue":
                return controller!.text;
              case "focus":
                // var cfocusNode = FocusScope.of(context);
                // // 需要判断focusScope是否发生了变化
                // // 未知原因，focusNode会因为setState等导致发生变化
                // if(cfocusNode!=focusNode){
                //   focusNode = cfocusNode;
                // }
                if(!focusNode!.hasFocus){
                  focusNode!.requestFocus();
                  TWidgetInput.currentNode = focusNode;
                }
                return true;
              case "unfocus":
                // var cfocusNode = FocusScope.of(context);
                // if(cfocusNode!=focusNode){
                //   focusNode = cfocusNode;
                // }
                if(focusNode!.hasFocus){
                  focusNode!.unfocus();
                }
                return true;
            }
          }
        };
        widget.jsRuntime.addWidgetMessageHandle("Input",inputName!, inputWidgetMessageHandle);
        // 页面渲染完成后执行
        var widgetsBinding = WidgetsBinding.instance;
        widgetsBinding.addPostFrameCallback((callback)async{
            if(!hasBinding &&  !widget.jsRuntime.onDispose ){
              hasBinding =  true;
              widget.jsRuntime.resolveWidgetReady("Input", inputName!);
            }
        });
      }
      
    }
  }
  @override 
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    input ??= TextField(
        key:widget.ikey,
        focusNode:focusNode,
        controller:controller,
        maxLength:maxLength,
        maxLines:attrs['obscureText']=='true'?1:maxLines,
        // ignore: deprecated_member_use
        // maxLengthEnforcement:maxLength!=null?true:maxLengthEnforced,
        onChanged:onChanged,
        onSubmitted:onSubmitted,
        onEditingComplete:onEditingComplete,
        cursorColor: cursorColor,
        cursorWidth:cursorWidth!,
        cursorHeight:cursorHeight,
        cursorRadius:cursorRadius,
        keyboardAppearance:keyboardAppearance,
        scrollPadding:scrollPadding,
        enableInteractiveSelection:enableInteractiveSelection!,
        enabled:attrs["enabled"]=="false"?false:true,
        decoration: decoration,
        showCursor:showCursor,
        keyboardType:keyboardType,
        textInputAction:textInputAction,
        textCapitalization:textCapitalization,
        style:StyleParse.textStyle(style),
        obscureText:attrs['obscureText']=='true',
        textAlign:textAlign,
        strutStyle:strutStyle,
        textDirection:textDirection,
        readOnly:readOnly!,
        autofocus:autofocus!,
        minLines:minLines,
        expands: expands!,
        inputFormatters:inputFormatters,
        buildCounter: attrs['showCounter']=='true'?null:(context,{int? currentLength,bool? isFocused,maxLength}){  
          var params = {
            "length":currentLength,
            "isFocused":isFocused,
            "maxLength":maxLength
          };
          if(inputName!=null){
            widget.jsRuntime.evaluate('(function(){ var i = tunaJs.getInput("'+inputName!+'"); if(i && i.onCounter){ i.onCounter('+json.encode(params)+') }  })();');
          }
          return null;
        },
      );
    return input!;
  }
  @override 
  void dispose() {
    controller!.dispose();
    
    if(TWidgetInput.currentNode==focusNode){
      TWidgetInput.currentNode = null;
    }
    focusNode!.dispose();
    if(inputName!=null){
      widget.jsRuntime.removeWidgetMessageHandle("Input",inputName!, inputWidgetMessageHandle);
    }
    super.dispose();
  }
}

// radio 单选
Map<String,dynamic> __radios_values__ = {};
class TunaRadioInput extends StatefulWidget{
  final dom.Element node;
  final PageStorageKey? ikey;
  final JsRuntime jsRuntime;
  final Map<String,dynamic> attrs;
  TunaRadioInput(this.node,{this.ikey,required this.jsRuntime,required this.attrs});

  @override 
  _TunaRadioInputState createState() => _TunaRadioInputState();
}

class _TunaRadioInputState extends State<TunaRadioInput> with AutomaticKeepAliveClientMixin{

  var value;
  var name;
  late Map<String,dynamic> attrs;
  late JsRuntime jsRuntime;
  bool checked = false;

  double iconSize = 16.0;
  double boxWidth = 32.0;
  double boxHeight = 32.0;
  Color? iconColor;
  double? fontSize;
  Color? fontColor;
  String placeHolder = '';

  var iconPadding;
  var child;

  @override
  bool get wantKeepAlive => true;

  @override 
  void initState() {
    super.initState();
    attrs = widget.attrs;
    jsRuntime = widget.jsRuntime;
    checked = attrs["checked"]=="true"?true:false;
    

    value = attrs['value'];
    name = attrs["name"];
    iconSize = attrs.containsKey("iconSize")?double.parse(attrs['iconSize']):16.0;
    iconColor = attrs.containsKey("iconColor")?StyleParse.hexColor(attrs['iconColor']):null;
    fontSize = attrs['fontSize']==null?14.0:double.parse(attrs['fontSize']);
    fontColor = attrs.containsKey("fontColor")?StyleParse.hexColor(attrs['fontColor']):null;
    iconPadding = attrs.containsKey("iconPadding")?StyleParse.edgeInsetsGeometry(attrs['iconPadding']):EdgeInsets.all(0.0);
    
    placeHolder = attrs.containsKey("placeHolder")?attrs['placeHolder']:attrs.containsKey("placeholder")?attrs['placeholder']:'';

    boxWidth = attrs.containsKey("boxWidth")?double.parse(attrs['boxWidth']):32.0;
    boxHeight = attrs.containsKey("boxHeight")?double.parse(attrs['boxHeight']):32.0;

    if(placeHolder.isNotEmpty){
      child = Text(placeHolder,style: TextStyle(fontSize: fontSize,color: fontColor),);
    }

    if(name!=null){
      if(__radios_values__.containsKey(name)){
        __radios_values__[name] = {
          "value":value,
          "radios":[this]
        };
      }else{
        __radios_values__[name]["radios"].add(this);
      }
      if(checked){
        __radios_values__[name]["value"] = value;
      }
    }

  }

  @override 
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override 
  Widget build(BuildContext context) {
    super.build(context);
    Icon icon = checked?Icon(Icons.radio_button_checked,size: iconSize,color: iconColor,):Icon(Icons.radio_button_off,size:iconSize,color: iconColor,);
    
    if(child==null){
      return 
        SizedBox(width:boxWidth,height: boxHeight,child: IconButton(
          key: widget.ikey,
          icon:icon , 
          iconSize: iconSize,
          color:iconColor,
          onPressed:select ,
          padding: iconPadding,
        ),);
    }else{
      return Row(children: [
        SizedBox(width:boxWidth,height: boxHeight,child:IconButton(
          key: widget.ikey,
          icon:icon , 
          iconSize: iconSize,
          color:iconColor,
          onPressed:select ,
          padding: iconPadding,
        )),
        GestureDetector(
          onTap: select,
          child: child,
        )
      ],key:widget.ikey);
    }
      
  }

  select(){
    FocusScope.of(context).requestFocus(FocusNode());
    checked = true;
    __radios_values__[name]["radios"].forEach((radio){
      if(radio!=this){
        radio.unselect();
      }
    });
    __radios_values__[name]["value"] = value;

    if(attrs['onChanged']!=null){
      var onChanged = attrs['onChanged'];
      widget.jsRuntime.evaluateFunc(onChanged,value);
    }
    
    setState(() {});
  }

  unselect(){
    checked = false;
    setState(() {});
  }

  @override 
  void dispose() {
    if(name!=null){
      __radios_values__[name]['radios'].remove(this);
      __radios_values__[name].remove('value');
    }
    super.dispose();
  }

}


// checkbox
// ignore: non_constant_identifier_names
Map<String,dynamic> __check_box_values__ = {};
class TunaCheckbox extends StatefulWidget{
  
  final dom.Element node;
  final PageStorageKey? ikey;
  final JsRuntime jsRuntime;
  final Map<String,dynamic> attrs;

  TunaCheckbox(this.node,{this.ikey,required this.jsRuntime,required this.attrs});

  @override 
  _TunaCheckboxState createState() => _TunaCheckboxState();
}


class _TunaCheckboxState extends State<TunaCheckbox> with AutomaticKeepAliveClientMixin{
  
  late Map<String,dynamic> attrs;
  late JsRuntime jsRuntime;
  // 选择的值
  dynamic value;
  // 选择框name
  String? name;
  // 是否多选
  bool isMultiple = false;
  // 是否选中
  bool isChecked = false;
  // 选择框图标颜色
  Color? iconColor;
  // 文字颜色
  Color? textColor;
  // 图标尺寸
  double iconSize = 16.0;
  double boxWidth = 32.0;
  double boxHeight = 32.0;
  // 文字大小
  double? fontSize;
  // 默认元素
  SizedBox? btn;
  Widget? child;
  String? iconPosition;
  String placeHolder = '';
  // 事件
  var onChanged;
  bool hasBinding = false;

  @override
  bool get wantKeepAlive => true;

  @override 
  void initState() {
    super.initState();
    attrs = widget.attrs;
    jsRuntime  = widget.jsRuntime;
    // 颜色配置
    iconColor = attrs['iconColor']==null?Colors.blue:StyleParse.hexColor(attrs['iconColor']);
    textColor = attrs['textColor']==null?null:StyleParse.hexColor(attrs['textColor']);
    // 大小配置
    iconSize = attrs['iconSize']==null?16.0:double.parse(attrs['iconSize']);
    fontSize = attrs['textSize']==null?14.0:double.parse(attrs['textSize']);
    boxWidth = attrs.containsKey("boxWidth")?double.parse(attrs['boxWidth']):32.0;
    boxHeight = attrs.containsKey("boxHeight")?double.parse(attrs['boxHeight']):32.0;

    placeHolder = attrs.containsKey("placeHolder")?attrs['placeHolder']:attrs.containsKey("placeholder")?attrs['placeholder']:'';

    // 是否多选
    isMultiple = attrs['multiple']=="false"?false:true;
    isChecked = attrs['isChecked']=="true"?true:false;
    
    // onChanged
    onChanged = attrs['onChanged'];

    iconPosition = attrs['iconPosition'];
    // name
    name = attrs['name'];
    value = attrs['value'];

    if(name!=null){
      // 第一个input时，监听回调
      if(__check_box_values__[name]==null){
        jsRuntime.addWidgetMessageHandle("Input",name!, (params){
          if(params is Map && params.containsKey("method")){
            var method = params['method'];
            var data = params['data'];
            switch(method){
              case "clear":
                __check_box_values__[name]['items'].forEach((item){
                  item.unChecked();
                });
                __check_box_values__[name]['value'] = [];
                return true;
              case "getValue":
                return __check_box_values__[name]['value'];
              case "value":
                if(data!=null){
                  __check_box_values__[name]['items'].forEach((item){
                    if(item.value.toString()==data.toString()){
                      item.checked();
                    }
                  });
                  return data;
                }
                return null;
            }
          }
        });
      }
      
      if(__check_box_values__.containsKey(name)){
        __check_box_values__[name]['items'].add(this);
      }else{
        __check_box_values__[name!] = {
          "value":[],
          "items":[this]
        };
        jsRuntime.resolveWidgetReady("Input", name!);
      }
      var arr = __check_box_values__[name];
      if(isChecked){
        if(isMultiple && !arr['value'].contains(value)){
          __check_box_values__[name]['value'].add(value);
        }else{
          __check_box_values__[name]['value'] = [value];
        }
      }

    if(placeHolder.isNotEmpty){
      child = Text(placeHolder,style: TextStyle(fontSize: fontSize,color: textColor),);
    }
      
      if(!hasBinding){
        // 页面渲染完成后执行
        var widgetsBinding = WidgetsBinding.instance;
        widgetsBinding.addPostFrameCallback((callback){
            hasBinding =  true;
            if(isChecked && !isMultiple && 
              __check_box_values__[name]!=null 
            ){
              __check_box_values__[name]['value'] = [value];
              __check_box_values__[name]['items'].forEach((item){
                if(item!=this && item.isChecked){
                  item.unChecked();
                }
              });
              // print(jsEngine.checkBoxValues[name]['value']);
            }
        });
      }
    }
  
  }

  @override 
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override 
  Widget build(BuildContext context) {
    super.build(context);
    
    btn = SizedBox(child: IconButton(
      icon: Icon( isChecked?Icons.check_box:Icons.check_box_outline_blank,size: iconSize,color:iconColor ,),
      iconSize: iconSize,
      color: iconColor, 
      onPressed: toggleChecked,
      padding: const EdgeInsets.all(0.0),
      alignment: iconPosition!=null?parseAlignByPos(iconPosition):Alignment.center,
    ),width: boxWidth,height:boxHeight);

    dynamic tapWidget;
    if(child!=null){
      tapWidget = GestureDetector(
        onTap:toggleChecked,
        child: child,
      );
    }

    List<Widget> children = [];
    if(tapWidget!=null){
      children.add(tapWidget);
    }
    
    switch(iconPosition){
      case "topLeft":
        children.insert(0,Positioned(child: btn!,left: 0,top: 0,));
        return Stack(
          clipBehavior: Clip.none, 
          key:widget.ikey,
          children: children,
        );
      case "topRight":
        children.insert(0,Positioned(child: btn!,right: 0,top: 0,));
        return Stack(
          clipBehavior: Clip.none, 
          key:widget.ikey,
          children: children,
        );
      case "bottomLeft":
        children.insert(0,Positioned(child: btn!,left: 0,bottom: 0,));
        return Stack(
          clipBehavior: Clip.none, 
          key:widget.ikey,
          children: children,
        );
      case "bottomRight":
        children.insert(0,Positioned(child: btn!,left: 0,bottom: 0,));
        return Stack(
          clipBehavior: Clip.none, 
          key:widget.ikey,
          children: children,
        );
      case "leftCenter":
      default:
        children.insert(0, btn!);
        return Row(
          key:widget.ikey,
          children:children
        );
    }
    
  }

  parseAlignByPos(pos){
    switch(pos){
      case "topLeft":
        return Alignment.topLeft;
      case "topRight":
        return Alignment.topRight;
      case "bottomLeft":
        return Alignment.bottomLeft;
      case "bottomRight":
        return Alignment.bottomRight;
    }
  }

  unChecked(){
    if(!isMultiple && __check_box_values__[name]['value'][0]==value){
      __check_box_values__[name]['value'] = [];
    }else{
      __check_box_values__[name]['value'].remove(value);
    }
    isChecked = false;
    setState(() {});
  }

  checked(){
    if(isMultiple){
      __check_box_values__[name]['value'].add(value);
    }else{
      __check_box_values__[name]['value'] = [value];
      __check_box_values__[name]['items'].forEach((item){
        if(item !=this && item.isChecked){
          // print(item.value);
          item.unChecked();
        }
      });
    }
    isChecked = true;
    setState(() {});
  }

  toggleChecked(){
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      isChecked = !isChecked;
      if(isChecked){
        checked();
      }else{
        unChecked();
      }
    
      if(onChanged!=null){
        try{
          widget.jsRuntime.evaluateFunc(onChanged,{
            "checked":isChecked,
            "checkedValue":__check_box_values__[name]['value'],
            "value":value
          });
        }catch(e){
          print(e);
        }
      }
    });
  }
  
  @override 
  void dispose() {
    if(name!=null){
      __check_box_values__[name]['items'].remove(this);
      __check_box_values__[name]['value'].remove(value);
    }
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuna3/js_runtime.dart';

class Tapp{

  String name;
  Map<String,dynamic> config;
  void Function()?  onInit;
  void Function()? onReady;
  void Function()? onDispose;
  void Function(Routing?)? routingCallback;

  bool? enableLog;

  late JsRuntime jsRuntime;
  late GetMaterialApp app;

  // Map<String,GetMaterialApp> miniApps = {};

  Tapp(this.name,this.config,{
    this.onInit,
    this.onReady,
    this.onDispose,
    this.routingCallback,
    this.enableLog
  }){
    
    jsRuntime = JsRuntime('appRoot', 'ROOT');

    app = GetMaterialApp(
      title: config.containsKey("title") ? config['title']:'',
      // home: ,
      theme: config.containsKey("theme") && config['theme'] is ThemeData ? config['theme']:null,
      darkTheme: config.containsKey("darkTheme") && config['darkTheme'] is ThemeData ? config['darkTheme']:null,
      color:config.containsKey("color")?config['color']:Colors.white,
      locale:config.containsKey("locale")?config['locale']:null,
      onInit:onInit,
      onReady:onReady,
      onDispose:onDispose,
      routingCallback:routingCallback,
      enableLog:enableLog
    );

  }

  
}
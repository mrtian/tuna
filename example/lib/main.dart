import 'package:flutter/material.dart';
import 'package:tuna3/tuna3.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  var page = await Tuna3.assetsPage('pages/app.html',{
    "title":"hello"
  });

  runApp(await Tuna3.createApp("hello", TunaAppConfig(
      home:page,
      title:"Tuna3 App"
    )
  ));
  
}



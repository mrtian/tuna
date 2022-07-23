import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import '../js_runtime.dart';

import '../tuna3.dart';

class TunaPathPlugin{

  static insertToJsRuntime(JsRuntime jsRuntime) {
    String docPath = Tuna3.appDocPath;
    String tempPath = Tuna3.appTempPath;
    
    // 注入常量
    var code = 'var AppTempPath='+json.encode(tempPath)+',AppDocPath='+json.encode(docPath)+';';
    jsRuntime.evaluate(code);

    // 事件处理
    jsRuntime.addJavascriptMessageHandle("TunaFilePluginEvent", (params)async{

      if(params is Map && params.containsKey("method")){
        var method  = params['method'];
        var data = params['data'];
        String fileName = params['fileName'];
        
        if(!fileName.startsWith("/")){
          fileName = "/"+fileName;
        }
       
        var isTemp = params['options']!=null?params['options']['isTemp']:false;
        var isFullPath = params['options']!=null?params['options']['isFullPath']:false;
        var basePath;
        // print(params['options']);
        

        if(isFullPath!=null && isFullPath==true){
          basePath = "";
        }else if(isTemp!=null && isTemp==true){
          basePath = tempPath;
        }else{
          basePath = docPath; 
        }

        var fullPath = basePath+fileName;
  
        File? file = jsRuntime.filePlugins[fileName];
        if(file==null){
          file = File(fullPath);
          jsRuntime.filePlugins[fullPath] = file;
        }
        switch(method){
          case "exists":
            return  file.existsSync();
          case "readAsString":
            return  file.readAsStringSync();
          case "stat":
            FileStat stat =  file.statSync();  
            return {
              "size":stat!=null?stat.size:null,
              "modified":stat!=null?stat.modified.millisecondsSinceEpoch:null,
              "changed":stat!=null?stat.changed.millisecondsSinceEpoch:null,
              "type":stat!=null?stat.type.toString():null
            };
            
          case "writeAsString":
            File? ret =  await file.writeAsString(data);
            if(ret!=null){
              return ret.path;
            }
            return false;
          case "writeBase64Data":
            try{
              Uint8List bytes = base64.decode(data);
              file.writeAsBytesSync(bytes);
              return true;
            }catch(e){
              return false;
            }
          case "rename":
            if(!data.startsWith("/")){
              data = "/"+data;
            }
            File? ret =  await file.rename(basePath+data);
            if(ret!=null){
              return ret.path;
            }
            return false;
          case "moveTo":
            File? ret = await file.rename(data);
            if(ret!=null){
              return true;
            }
            return false;
          case "remove":
            try{
              FileSystemEntity? ret = await file.delete();
              return ret.path;
            }catch(e){
              return false;
            }
            
        }
      }
    });
    
    // 事件处理
    jsRuntime.addJavascriptMessageHandle("TunaDirectoryPluginEvent", (params)async{
      if(params is Map && params.containsKey("method")){

        var method  = params['method'];
        var data = params['data'];
        
        var basePath;
        String pathName = params['path'];

        if(!pathName.startsWith("/")){
          pathName = "/"+pathName;
        }

        var isTemp = params['isTemp']!=null?params['isTemp']:false;
        var isFullPath = params['isFullPath']!=null?params['isFullPath']:false;
        var fullPath;

        if(isTemp!=null && isTemp==true){
          basePath = tempPath;
        }else if(!isFullPath){
          basePath = docPath; 
        }else{
          basePath="";
        }
        fullPath = basePath+pathName;
        Directory? dir = jsRuntime.directoryPlugins[fullPath];

        if(dir==null){
          dir = Directory(fullPath);
          jsRuntime.filePlugins[fullPath] = dir;
        }

        switch(method){
          case "exists":
           return await dir.exists();
          case "create":
            var ret =  await dir.create();
            if(ret!=null){
              return ret.path;
            }else{
              return false;
            }
          case "rename":
            if(!data.startsWith("/")){
              data = "/"+data;
            }
            var ret =  await dir.rename(basePath+data);
            if(ret!=null){
              return ret.path;
            }else{
              return false;
            }
          case "moveTo":
            var ret =  await dir.rename(data);
            if(ret!=null){
              return ret.path;
            }else{
              return false;
            }
          case "remove":
            try{
              var ret =  await dir.delete();
              return ret.path;
            }catch(e){
              return false;
            }
          case "clear":
             List<FileSystemEntity>  list =  dir.listSync();
            //  print(list);
             if(list.length>0){
                list.forEach((FileSystemEntity file) {
                  file.deleteSync();
                });
             }
            return true;
          case "list":
            List<FileSystemEntity>  list =  dir.listSync();
            var ret = [];
            if(list.length>0){
              list.forEach((FileSystemEntity fileEntity) {
                FileStat stat = fileEntity.statSync();
                ret.add({
                  "type":FileSystemEntity.isFileSync(fileEntity.path)?'file':(FileSystemEntity.isDirectorySync(fileEntity.path)?'directory':null),
                  "path":fileEntity.path,
                  "isAbsolute":fileEntity.isAbsolute,
                  "stat":{
                    "size":stat!=null?stat.size:null,
                    "modified":stat!=null?stat.modified.millisecondsSinceEpoch:null,
                    "changed":stat!=null?stat.changed.millisecondsSinceEpoch:null,
                    "type":stat!=null?stat.type.toString():null
                  }
                });
              });
            }
            return ret;
        }
      }
    });
  }
}
import 'dart:convert';
import 'dart:io';

import '../js_runtime.dart';
import '../module.dart';
import 'package:dio/dio.dart';


class HttpModule extends ScriptModule{
  // final String jsAssets;
  HttpModule() : super("HttpModule");

  static Map<String,Dio> https = { };

  @override
  methodCall(String id, String method, data, JsRuntime jsRuntime) async{
    var _dio = HttpModule.https[id];

    if(_dio==null && method!="_onCreated"){
      return false;
    }

    dynamic options;
    if(data is Map && data.containsKey("options") && data['options'] is Map){
      var _opts = data['options'];
      options = Options(
        method:_opts['method'],
        sendTimeout:_opts['sendTimeout'],
        receiveTimeout:_opts['receiveTimeout'],
        extra:_opts['extra']!=null ? Map<String,dynamic>.from(_opts['extra']):null,
        headers:_opts['headers']!=null? Map<String,dynamic>.from(_opts['headers']):null,
        contentType:_opts['contentType'],

      );
    }
    
    switch(method){
      case "_onCreated":
        if(_dio==null){
          _dio = Dio(
            BaseOptions(
              connectTimeout : data['connectTimeout'],
              receiveTimeout : data['receiveTimeout'],
              sendTimeout : data['sendTimeout'],
              baseUrl : data.containsKey('baseUrl')?data['baseUrl']:'',
              queryParameters : data['queryParameters'],
              extra : data['extra'],
              headers : data.containsKey('headers')?data['headers']:null,
              responseType : parseResponseType(data['type']),
              contentType : data['contentType'],
              validateStatus : data['validateStatus'],
              receiveDataWhenStatusError : data['receiveDataWhenStatusError']==false?false:true,
              followRedirects : data['followRedirects']==false?false:true,
              maxRedirects : data['maxRedirects']
            )
          );
          HttpModule.https[id] = _dio;
          resolveReady(id, jsRuntime);
        }
        return true;
      case "get":
        try{
          Response res =  await _dio!.get(data['url'],queryParameters: data['querys'],options:options,onReceiveProgress:(progress,total){
            resolveCall(id, "onGetReceiveProgress",jsRuntime,data: {"url":data['url'],"total":total,"progress":progress});
          });
          // return res;
          return HttpModuleResponse(res).toJson();
        } on DioError catch(e){
          throw HttpModuleError(e).toJson();
        }

      case "post":
        try{
          // print(data['data']);
          var _postData = await parseDataType(data['data'],dataType:data['type']);
          var res =  await _dio!.post(data['url'],data:_postData,queryParameters: data['querys'],options:options,onReceiveProgress:(total,progress){
            resolveCall(id, "onPostReceiveProgress",jsRuntime,data: {"url":data['url'],"total":total,"progress":progress});
          });
          // print(res);
          return HttpModuleResponse(res).toJson();
        } on DioError catch(e){
          return HttpModuleError(e).toJson();
        }
      
      case "head":
        try{
          var _postData = parseDataType(data['data'],dataType:data['type']);
          var res =  await _dio!.head(data['url'],data:_postData,queryParameters: data['querys'],options:options);
          return HttpModuleResponse(res).toJson();
        } on DioError catch(e){
          return HttpModuleError(e).toJson();
        }

      case "put":
        try{
          var _postData = parseDataType(data['data'],dataType:data['type']);
          var res =  await _dio!.put(data['url'],data:_postData,queryParameters: data['querys'],options:options,onSendProgress:(total,progress){
            resolveCall(id, "onPutSendProgress",jsRuntime,data: {"url":data['url'],"total":total,"progress":progress});
          },onReceiveProgress: (total,progress){
            resolveCall(id, "onPutReceiveProgress",jsRuntime,data: {"url":data['url'],"total":total,"progress":progress});
          });
          return HttpModuleResponse(res).toJson();
        } on DioError catch(e){
          return HttpModuleError(e).toJson();
        }

      case "delete":
        try{
          var _postData = parseDataType(data['data'],dataType:data['type']);
          var res =  await _dio!.delete(data['url'],data:_postData,queryParameters: data['querys'],options:options);
          return HttpModuleResponse(res).toJson();
        } on DioError catch(e){
          throw HttpModuleError(e).toJson();
        }

      case "patch":
        try{
          var _postData = parseDataType(data['data'],dataType:data['type']);
          var res =  await _dio!.patch(data['url'],data:_postData,queryParameters: data['querys'],options:options,onSendProgress:(total,progress){
            resolveCall(id, "onPatchSendProgress",jsRuntime,data: {"url":data['url'],"total":total,"progress":progress});
          },onReceiveProgress: (total,progress){
            resolveCall(id, "onPatchReceiveProgress",jsRuntime,data: {"url":data['url'],"total":total,"progress":progress});
          });
          return HttpModuleResponse(res).toJson();
        } on DioError catch(e){
          throw HttpModuleError(e).toJson();
        }
      
      case "download":
        try{
          var _postData = parseDataType(data['data'],dataType:data['type']);
          var res =  await _dio!.download(data['url'],data['savePath'],data:_postData,queryParameters: data['querys'],options:options,onReceiveProgress:(total,progress){
            resolveCall(id, "onDownloadReceiveProgress",jsRuntime,data: {"url":data['url'],"total":total,"progress":progress});
          });
          var resp = HttpModuleResponse(res).toJson();
          resp["savePath"] = data['savePath'];
          return resp;
        } on DioError catch(e){
          throw HttpModuleError(e).toJson();
        }
    }
  }

  parseDataType(postData,{dataType})async{
    if(!(postData is Map)){
      return postData;
    }

    if(dataType!=null){
      var ret = parseDataType(postData);
      return parseDataTypeSingle(ret, dataType);
    }else{
      Map _retData = {};
      postData.forEach((key,val){
        if(val is Map && val.containsKey("dataType")){
          var _dtype = val['dataType'];
          val.remove("dataType");
          _retData[key] = parseDataTypeSingle(val,_dtype);
        }else{
          _retData[key] = val;
        }
      });
    }
  }

  parseDataTypeSingle(val,type)async {
    switch(type){
      case "file":
        return await MultipartFile.fromFile(val["path"],filename:val["fileName"]);
      case "formData":
        return FormData.fromMap(val); 
    }
  }

  parseResponseType(String? type){
    switch(type){
      case "json":
        return ResponseType.json;
      case "bytes":
        return ResponseType.bytes;
      case "stream":
        return ResponseType.stream;
      case "text":
      case "plain":
      default:
        return ResponseType.plain;
    }
  }
  
}

// 处理httpmodule to Json
class HttpModuleResponse{
  final Response res;
  HttpModuleResponse(this.res);

  toJson(){
    List redirects =[]; 
    if(res!=null && res.redirects!=null && res.redirects is List && res.redirects.length>0){
      res.redirects.forEach((redirect) { 
        redirects.add({
          "statusCode":redirect.statusCode,
          "method":redirect.method,
          "location":redirect.location
        });
       });
    }
   
    var ret =  {
      "code":res.statusCode,
      "data":parseResData(res.data),
      "isRedirect":res.isRedirect,
      "headers":res.headers.map,
      "statusMessage":res.statusMessage,
      // "realUri":res.realUri!=null?parseResUri(res.realUri):null,
      "redirects":redirects,
      "extra":res.extra
    };
    
    return ret;
  }

  // parseResUri(Uri uri){
  //   print(uri);
  //   var ret =  {
  //     "scheme":uri.scheme,
  //     "authority":uri.authority,
  //     "userInfo":uri.userInfo,
  //     "host":uri.host,
  //     "port":uri.port,
  //     "path":uri.path,
  //     "query":uri.query,
  //     "fragment":uri.fragment,
  //     "pathSegments":uri.pathSegments,
  //     "queryParameters":uri.queryParameters,
  //     "isAbsolute":uri.isAbsolute,
  //     "origin":uri.origin
  //   };
  //   print(ret);
  //   return ret;
  // }
  parseResData(dynamic data){
    var ret;
    if(data is String || data is bool || data is List || data is int || data is double || data is Map){
      ret =  data;
    }else if(data is Stream){
      ret = data.toList();
    }else if(data is List<int>){
      ret = base64Encode(data);
    // }else if(data is ResponseBody){
    //   ret = base64Encode(data.stream.);
    }else {
      ret = data.toString();
    }
    return ret;
  }
}

class HttpModuleError{
  final DioError error;
  HttpModuleError(this.error);

  toJson(){
    return {
      "response":error.response!=null?HttpModuleResponse(error.response!).toJson():null,
      "type":error.type.toString(),
      "error":parseError(error.error)
    };
  }

  parseError(e){
    if(e.runtimeType == SocketException){
      return {
        "type":"SocketException",
        "address":e.address!=null?{"address:":e.address.address,"host":e.address.host}:null,
        "message":e.message,
        "osError":e.osError==null?null:{
          "errorCode":e.osError.errorCode,
          "message":e.osError.message
        },
        "port":e.port
      };
    }else{
      return e.toString();
    }
  }
}
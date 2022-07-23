

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:tuna3/jscore/core/js_value.dart';
import '../tuna3.dart';
import '../js_runtime.dart';
import '../module.dart';
import '../utils/style_parse.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../compontents/cameraPicker/camera_picker.dart';

class Picker extends ScriptModule{

  static Map instances = {};
  // final String jsAssets;

  Picker() : super("AssetsPicker");

  @override
  methodCall(String id, String method, data, JsRuntime jsRuntime) async{
    var plugin = Picker.instances[id];

    if(plugin==null){
      plugin = AssetsPickerPlugin(id);
      Picker.instances[id] = plugin;
      jsRuntime.registDispose((){
        Picker.instances.remove(id);
      });
    }

    if(method=="init"){
      return true;
    }

    switch(method){
      case "fromAssets":
          var selectedAssets;
          if(data["preventDuplicate"]  == true){
            selectedAssets = plugin.assets;
          }
          try{
            plugin.assets = await AssetPicker.pickAssets(
              Get.context!,
              pickerConfig:AssetPickerConfig(
                selectedAssets:selectedAssets,
                maxAssets:data['maxItems']!=null?data["maxItems"]:1,
                pathThumbnailSize:data["pathThumbSize"] ?? 80,
              // previewThumbSize:
              gridCount:data["gridCount"] ?? 4,
              
              pageSize: data["pageSize"] ?? 500,
              requestType:data["requestType"]!=null?AssetsPickerPlugin.parseRequestType(data["requestType"]):RequestType.image,
              themeColor:data["textColor"]!=null?StyleParse.hexColor(data["textColor"]):null

              ),
              
            );
          }catch(e){
            print(e);
          }

          if(plugin.assets is List && plugin.assets.length>0){
            var _rets = [];
            for(var i=0;i<plugin.assets.length;i++){
              var _ret = await AssetsPickerPlugin.parseAsset(plugin.assets[i]);
              if(_ret!=null){
                _rets.add(_ret);
              }
            }
            return _rets;
          }
          return null;
      case "fromCamera":
        AssetEntity? pickedAsset;
        try{
          int seconds = 5;
          if(data["maxRecordingSeconds"]!=null){
            if(data['maxRecordingSeconds'] is int){
              seconds = data['maxRecordingSeconds'];
            }else {
              seconds = double.parse(data['maxRecordingSeconds'].toString()).toInt();
            }
          }
          
          pickedAsset = await CameraPicker.pickFromCamera(
            Get.context!,
            enableAudio:data['enableAudio']==true?true:false,
            cameraQuarterTurns:data.containsKey("quarterTurns")?data['quarterTurns']:0,
            resolutionPreset:data['quality']!=null? AssetsPickerPlugin.parseResolutionPreset(data['quality']):ResolutionPreset.max,
            // theme:themeColor!=null?CameraPicker.themeData(StyleParse.hexColor(themeColor)):null,
            enableRecording:data["enableRecording"]==true?true:false,
            onlyEnableRecording:data["onlyEnableRecording"]==true?true:false,
            cameraDirection:data.containsKey("cameraDirection")?data["cameraDirection"]:"back",
            maximumRecordingDuration:Duration(seconds:seconds),
            shouldDeletePreviewFile:data['shouldDeletePreviewFile']==true?true:false,
            foregroundBuilder:data.containsKey('foregroundBuilder')?(cameraValue){
              // print(cameraValue);
              JSValue? tpl = Tuna3.parseTemplate(data['foregroundBuilder'].trim());
              if(tpl!=null && tpl.string!=null){
                var frag = parseFragment(tpl.string);
                return Tuna3.parseWidget(frag.children[0],jsRuntime);
              }else{
                return Container();
              }
            }:null,
          );
        }catch(e){
          print(e);
        }
        if(pickedAsset!=null){
          plugin.assets = [pickedAsset];
          return await AssetsPickerPlugin.parseAsset(pickedAsset);
        }
        return null;

      case "getAssetInfoById":
        if(data is String && data.isNotEmpty){
          var fileId = data;
          AssetEntity? asset = await AssetEntity.fromId(fileId);
          if(asset!=null){
            return await AssetsPickerPlugin.parseAsset(asset);
          }
        }
        return null;
      
      case "getAssetByteDataById":
        if(data is String && data.isNotEmpty){
          var fileId = data;
          AssetEntity? asset = await AssetEntity.fromId(fileId);
          if(asset!=null){
            return await asset.originBytes;
          }
        }
        return null;
      
      case "getImageDataById":
        if(data is String && data.isNotEmpty){
          var fileId = data;
          AssetEntity? asset = await AssetEntity.fromId(fileId);
          if(asset!=null){
            var data =  await asset.originBytes;
            return base64Encode(data!);
          }
        }
        return null;
      
      case "getThumbDataById":
        if(data is String && data.isNotEmpty){
          var fileId = data;
          AssetEntity? asset = await AssetEntity.fromId(fileId);
          if(asset!=null && asset.type == AssetType.image){
            var data =  await asset.thumbnailData;
            return base64Encode(data!);
          }
        }
        return null;
      case "getSizedThumbDataById":
        if(data is Map && data.containsKey("id") && data.containsKey("width") && data.containsKey("height")){
          var fileId = data["id"];
          AssetEntity? asset = await AssetEntity.fromId(fileId);
          if(asset!=null && asset.type == AssetType.image){
            // print(params);
            var _data =  await asset.thumbnailDataWithSize(
              ThumbnailSize(data["width"],data["height"]),
              format: AssetsPickerPlugin.parseFormat(data["format"]),
              quality: data["quality"]
            );
            // print(data);
            return base64Encode(_data!);
          }
        }
        return null;

      case "getMediaUrlById":
        if(data is String && data.isNotEmpty){
          var fileId = data;
          AssetEntity? asset = await AssetEntity.fromId(fileId);
          if(asset!=null && (asset.type == AssetType.video || asset.type == AssetType.audio)){
            return await asset.getMediaUrl();
          }
        }
        return null;
      
      case "getFileById":
        if(data is String && data.isNotEmpty){
          var fileId = data;
          AssetEntity? asset = await AssetEntity.fromId(fileId);
          if(asset!=null ){
            var file =  await asset.file;
            return {
              "path":file!.path,
              "bytes":await file.readAsBytes()
            };
          }
        }
        return null;
    }
  }
  
}


class AssetsPickerPlugin{

  String? id;
  BuildContext? context;
  List<AssetEntity>? assets = [];

  AssetsPickerPlugin(this.id);

  // 选择类型parser
  static parseRequestType(String type){
    var ret;
    switch(type){
      case"image":
        ret = RequestType.image;
        break;
      case"video":
        ret = RequestType.video;
        break;
      case "audio":
        ret = RequestType.audio;
        break;
      case "all":
        ret = RequestType.all;
        break;
      case "common":
      default:
        ret = RequestType.common;
        break;
    }
    return ret;
  }
  static parseCameraDirection(String? type){
    var ret;
    switch(type){
      case "front":
      case "back":
        ret = type;
        break;
      default:
        ret="front";
        break;
    }
    return ret;
  }
  static parseDataType(AssetType type){
    switch(type){
      case AssetType.audio:
        return "audio";
      case AssetType.video:
        return "video";
      case AssetType.image:
        return "image";
      case AssetType.other:
      default:
        return "other";
    }
  }

  static parseAsset(AssetEntity? asset) async{

    if(asset!=null){
      var file  = await asset.file;
      try{
        var ret = {
          "id":asset.id,
          "path":file!.path,
          "title":Platform.isAndroid?asset.title:await asset.titleAsync,
          "type": AssetsPickerPlugin.parseDataType(asset.type),
          "duration":asset.duration,
          "width":asset.width,
          "height":asset.height,
        };
        // print(ret);
        return ret;
      }catch(e){
        print(e);
      }
    }
    return null;
  }

  static parseResolutionPreset(String? r){
    switch(r){
      case 'low':
        return ResolutionPreset.low;
      case 'medium':
        return ResolutionPreset.medium;
      case 'veryHigh':
        return ResolutionPreset.veryHigh;
      case 'ultra':
        return ResolutionPreset.ultraHigh;
      case 'max':
        return ResolutionPreset.max;
      case 'high':
      default:
        return ResolutionPreset.high;
    }
  }

  static parseFormat(String? format){
    switch(format){
      case "png":
        return ThumbnailFormat.png;
      case "jpeg":
      default:
        return ThumbnailFormat.jpeg;
    }
  }


}
import 'package:permission_handler/permission_handler.dart';
import '../js_runtime.dart';

class TPermission{
  static inserToJsRuntime(JsRuntime jsRuntime){
    jsRuntime.addJavascriptMessageHandle("permission.getStatus", (data)async{
      if(data is String && data.isNotEmpty){
        Permission truePermission = _deParsePermissionName(data);
        if(truePermission!=Permission.unknown){
          var status = await truePermission.status;
          var ret =  _parsePermissionStatus(status);
          return ret;
        }else{
          return "unknown";
        }
      }
      return "unknown";
    });

    // 获取权限
    // Call request() on a Permission to request it. If it has already been granted before, nothing happens.
    jsRuntime.addJavascriptMessageHandle("permission.request", (data)async{
      
      List<String>? _data;
      if(data is String){
        _data = data.split(",");
      }else if(data is List){
        _data = List.from(data);
      }
      if(_data!.isNotEmpty && _data.length>1){
        List<Permission> _list = [];
        _data.forEach((permissionName){
          _list.add(_deParsePermissionName(permissionName));
        });
        try{
          Map<Permission, PermissionStatus> statuses = await _list.request();
          var ret = {};
          statuses.forEach((key, value) {
            ret[key.toString()] = _parsePermissionStatus(value);
          });
          return ret;
        }catch(e){
          print(e);
          return false;
        }
      }else if(_data.length==1){
        Permission permission = _deParsePermissionName(_data[0]);
        // print(permission);
        try{
          PermissionStatus status = await permission.request();
          return _parsePermissionStatus(status);
        }catch(e){
          print(e);
          return false;
        }
       
      }
      return null;
    });

    // 获取服务权限
    jsRuntime.addJavascriptMessageHandle("permission.seiviceStatus", (data)async{
      if(data is String){
        if(data=="locationWhenInUse"){
          if(await Permission.locationWhenInUse.serviceStatus.isEnabled){
            return "enabled";
          }else{
            return "disabled";
          }
        }
      }
      return null;
    });

    // 打开应用设置
    jsRuntime.addJavascriptMessageHandle("permission.openSettings", (data)async {
      var a = await openAppSettings();
      return(a);
    });

  }
  // 权限状态
  static _parsePermissionStatus(status){
    dynamic _status;
    switch(status){
      case PermissionStatus.denied:
        _status = "denied";
        break;
      case PermissionStatus.granted:
        _status = "granted";
        break;
      case PermissionStatus.permanentlyDenied:
        _status = "permanentlyDenied";
        break;
      case PermissionStatus.restricted:
        _status = "restricted";
        break;
      case PermissionStatus.limited:
        _status = "limited";
        break;
      default:
        _status = "unknown";
        break;
    }
    return _status;
  }

  static _deParsePermissionName(name){
    dynamic permission;
    switch(name){
      case 'calendar':
        permission = Permission.calendar;
        break;
      case 'camera':
        permission = Permission.camera;
        break;
      case 'contacts':
        permission = Permission.contacts;
        break;
      case 'location':
        permission = Permission.location;
        break;
      case 'locationAlways':
        permission = Permission.locationAlways;
        break;
      case 'locationWhenInUse':
        permission = Permission.locationWhenInUse;
        break;
      case 'mediaLibrary':
        permission = Permission.mediaLibrary;
        break;
      case 'microphone':
        permission = Permission.microphone;
        break;
      case 'phone':
        permission = Permission.phone;
        break;
      case 'photos':
        permission = Permission.photos;
        break;
      case 'reminders':
        permission = Permission.reminders;
        break;
      case 'sensors':
        permission = Permission.sensors;
        break;
      case 'sms':
        permission = Permission.sms;
        break;
      case 'speech':
        permission = Permission.speech;
        break;
      case 'storage':
        permission = Permission.storage;
        break;
      case 'ignoreBatteryOptimizations':
        permission = Permission.ignoreBatteryOptimizations;
        break;
      case 'notification':
        permission = Permission.notification;
        break;
      case 'access_media_location':
        permission = Permission.accessMediaLocation;
        break;
      case 'activity_recognition':
        permission = Permission.activityRecognition;
        break;
      case 'unknown':
        permission = Permission.unknown;
        break;
    }
    return permission;
  }
}
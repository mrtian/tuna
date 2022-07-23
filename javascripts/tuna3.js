// md5 factory
!function(n){"use strict";function d(n,t){var r=(65535&n)+(65535&t);return(n>>16)+(t>>16)+(r>>16)<<16|65535&r}function f(n,t,r,e,o,u){return d((c=d(d(t,n),d(e,u)))<<(f=o)|c>>>32-f,r);var c,f}function l(n,t,r,e,o,u,c){return f(t&r|~t&e,n,t,o,u,c)}function v(n,t,r,e,o,u,c){return f(t&e|r&~e,n,t,o,u,c)}function g(n,t,r,e,o,u,c){return f(t^r^e,n,t,o,u,c)}function m(n,t,r,e,o,u,c){return f(r^(t|~e),n,t,o,u,c)}function i(n,t){var r,e,o,u;n[t>>5]|=128<<t%32,n[14+(t+64>>>9<<4)]=t;for(var c=1732584193,f=-271733879,i=-1732584194,a=271733878,h=0;h<n.length;h+=16)c=l(r=c,e=f,o=i,u=a,n[h],7,-680876936),a=l(a,c,f,i,n[h+1],12,-389564586),i=l(i,a,c,f,n[h+2],17,606105819),f=l(f,i,a,c,n[h+3],22,-1044525330),c=l(c,f,i,a,n[h+4],7,-176418897),a=l(a,c,f,i,n[h+5],12,1200080426),i=l(i,a,c,f,n[h+6],17,-1473231341),f=l(f,i,a,c,n[h+7],22,-45705983),c=l(c,f,i,a,n[h+8],7,1770035416),a=l(a,c,f,i,n[h+9],12,-1958414417),i=l(i,a,c,f,n[h+10],17,-42063),f=l(f,i,a,c,n[h+11],22,-1990404162),c=l(c,f,i,a,n[h+12],7,1804603682),a=l(a,c,f,i,n[h+13],12,-40341101),i=l(i,a,c,f,n[h+14],17,-1502002290),c=v(c,f=l(f,i,a,c,n[h+15],22,1236535329),i,a,n[h+1],5,-165796510),a=v(a,c,f,i,n[h+6],9,-1069501632),i=v(i,a,c,f,n[h+11],14,643717713),f=v(f,i,a,c,n[h],20,-373897302),c=v(c,f,i,a,n[h+5],5,-701558691),a=v(a,c,f,i,n[h+10],9,38016083),i=v(i,a,c,f,n[h+15],14,-660478335),f=v(f,i,a,c,n[h+4],20,-405537848),c=v(c,f,i,a,n[h+9],5,568446438),a=v(a,c,f,i,n[h+14],9,-1019803690),i=v(i,a,c,f,n[h+3],14,-187363961),f=v(f,i,a,c,n[h+8],20,1163531501),c=v(c,f,i,a,n[h+13],5,-1444681467),a=v(a,c,f,i,n[h+2],9,-51403784),i=v(i,a,c,f,n[h+7],14,1735328473),c=g(c,f=v(f,i,a,c,n[h+12],20,-1926607734),i,a,n[h+5],4,-378558),a=g(a,c,f,i,n[h+8],11,-2022574463),i=g(i,a,c,f,n[h+11],16,1839030562),f=g(f,i,a,c,n[h+14],23,-35309556),c=g(c,f,i,a,n[h+1],4,-1530992060),a=g(a,c,f,i,n[h+4],11,1272893353),i=g(i,a,c,f,n[h+7],16,-155497632),f=g(f,i,a,c,n[h+10],23,-1094730640),c=g(c,f,i,a,n[h+13],4,681279174),a=g(a,c,f,i,n[h],11,-358537222),i=g(i,a,c,f,n[h+3],16,-722521979),f=g(f,i,a,c,n[h+6],23,76029189),c=g(c,f,i,a,n[h+9],4,-640364487),a=g(a,c,f,i,n[h+12],11,-421815835),i=g(i,a,c,f,n[h+15],16,530742520),c=m(c,f=g(f,i,a,c,n[h+2],23,-995338651),i,a,n[h],6,-198630844),a=m(a,c,f,i,n[h+7],10,1126891415),i=m(i,a,c,f,n[h+14],15,-1416354905),f=m(f,i,a,c,n[h+5],21,-57434055),c=m(c,f,i,a,n[h+12],6,1700485571),a=m(a,c,f,i,n[h+3],10,-1894986606),i=m(i,a,c,f,n[h+10],15,-1051523),f=m(f,i,a,c,n[h+1],21,-2054922799),c=m(c,f,i,a,n[h+8],6,1873313359),a=m(a,c,f,i,n[h+15],10,-30611744),i=m(i,a,c,f,n[h+6],15,-1560198380),f=m(f,i,a,c,n[h+13],21,1309151649),c=m(c,f,i,a,n[h+4],6,-145523070),a=m(a,c,f,i,n[h+11],10,-1120210379),i=m(i,a,c,f,n[h+2],15,718787259),f=m(f,i,a,c,n[h+9],21,-343485551),c=d(c,r),f=d(f,e),i=d(i,o),a=d(a,u);return[c,f,i,a]}function a(n){for(var t="",r=32*n.length,e=0;e<r;e+=8)t+=String.fromCharCode(n[e>>5]>>>e%32&255);return t}function h(n){var t=[];for(t[(n.length>>2)-1]=void 0,e=0;e<t.length;e+=1)t[e]=0;for(var r=8*n.length,e=0;e<r;e+=8)t[e>>5]|=(255&n.charCodeAt(e/8))<<e%32;return t}function e(n){for(var t,r="0123456789abcdef",e="",o=0;o<n.length;o+=1)t=n.charCodeAt(o),e+=r.charAt(t>>>4&15)+r.charAt(15&t);return e}function r(n){return unescape(encodeURIComponent(n))}function o(n){return a(i(h(t=r(n)),8*t.length));var t}function u(n,t){return function(n,t){var r,e,o=h(n),u=[],c=[];for(u[15]=c[15]=void 0,16<o.length&&(o=i(o,8*n.length)),r=0;r<16;r+=1)u[r]=909522486^o[r],c[r]=1549556828^o[r];return e=i(u.concat(h(t)),512+8*t.length),a(i(c.concat(e),640))}(r(n),r(t))}function t(n,t,r){return t?r?u(t,n):e(u(t,n)):r?o(n):e(o(n))}"function"==typeof define&&define.amd?define(function(){return t}):"object"==typeof module&&module.exports?module.exports=t:n.md5=t}(this);
var __pageTempates__ = {};
function __sendMessage(msg){
    if(__PostNativeMessage){
        var id = msg.messageId || msg.id;
        if(!id){
            id = new Date().getTime()+"."+Math.random();
        }
        __PostNativeMessage(id,msg.name,msg.data || msg );
    }
}

function __NativeResolveMessage(msgId,data){
    console.log(msgId);
    console.log(data);
}

function __CreateMessageId(){
    return md5(new Date().getTime()+(parseInt(Math.random()*100000)));
}


// Dart消息机构
var __resolverRoutingCallbacks__ = [];
var __TMessagePromiseCaches__ = {};
// 处理dart返回的消息
function __ResolveTPostMessage(message,data){
    var promise = __TMessagePromiseCaches__[message.id];
    if(promise){
        promise.resolve(data);
    }else{
      console.log("Can't resolve promise message[id:"+message.id+",data:"+data.toString()+",name:"+message.name+"], not exist!");
    }
    delete __TMessagePromiseCaches__[message.id];
}
  
// dart消息处理错误返回
function __RejectTPostMessage(message,error){
    var promise = __TMessagePromiseCaches__[message.id];
      if(promise[message.id]){
        promise.reject(error);
      }
      __TMessagePromiseCaches__[message.id] = null;
}


// 对话框
// @params:
  // @title: 标题
  // @barrierDismissible: 点击背景是否可关闭，默认为false
  // @barrierColor: 背景色，默认为黑色半透明
  // @useSafeArea: 是否使用区域展示内容
  // @arguments: 输入的参数对象
  // @transitionDuration： 弹窗展示的时间长度
  // @transitionCurve： 动画效果
function alert(msg,params){
  return T.postMessage("XDialog.alert",{
    "message":msg,
    "params":params
  });
}
// 确认框
async function confirm(msg){
  return await alert(msg,{
    "actions":[
      {
        "text":"取消",
        "textColor":"#666666"
      },
      {
        "text":"确认",
        "textColor":"blue",
        "value":true
      }
    ]
  });
}

var toast = async function snackbar(title,options){
  if(typeof(title)=='string'){
    return await T.postMessage("XDialog.snackbar",{
      message:title,
      options:options
    });
  }else if(typeof(title)=='object'){
    return await T.postMessage("XDialog.snackbar",{
      message:title['message'],
      title:title['title'],
      options:title['options']
    });
  }
}

// 权限
var Permission = {
  // 权限列表
  permissions:{
    'calendar':'calendar',
    'camera':'camera',
    'contacts':'contacts',
    'location':'location',
    'locationAlways':'locationAlways',
    'locationWhenInUse':'locationWhenInUse',
    'mediaLibrary':'mediaLibrary',
    'microphone':'microphone',
    'phone':'phone',
    'photos':'photos',
    'reminders':'reminders',
    'sensors':'sensors',
    'sms':'sms',
    'speech':'speech',
    'storage':'storage',
    'ignoreBatteryOptimizations':'ignoreBatteryOptimizations',
    'notification':'notification',
    'access_media_location':'access_media_location',
    'activity_recognition':'activity_recognition'
  },
  
  // 打开APP的权限设置
  openSettings:function(){
    return T.postMessage("permission.openSettings","");
  },
  // 获取seivice permission Status, such as locationWhenInUse
  seiviceStatus:function(permission){
    return T.postMessage("permission.seiviceStatus",permission);
  },
  // 获取权限状态
  // @params permission : String Permission.permissions value
  getStatus:function(permission){
    return T.postMessage("permission.getStatus",permission);
  },
  // 申请权限
  // @params permission: String/List such as ['photos','camera'],'photos,camera', 'photos'
  // @notice: 注意：
  // 一个页面获取权限在很多手机中同一时间只能获取一次，
  // 所以当获取权限时，尽量给到需要的权限列表，尽量不要多次单一获取
  request:function(permission){
    return T.postMessage("permission.request",permission);
  }
};

// T
var __TbroadcastSubscribes = {};
var __TPageDidPopsMessages = {};
var T = {
    nativePostMessage:__PostNativeMessage,
    nativeResolveMessage:__NativeResolveMessage,
    postMessage:async function(msgName,msgData){
        var msgId = __CreateMessageId();
        
        var ret =  new Promise(function(resolve,reject){
            __TMessagePromiseCaches__[msgId] = {
              "resolve":resolve,
              "reject":reject
            };
        });

        __sendMessage({
            id:msgId,
            name:msgName,
            data:msgData
        });
        return ret;
    },

    // 失焦
    unfocus:function(){
      T.postMessage("T.unfocus");
      return T;
    },

    // http请求
    request:async function(url,options){
      return await T.postMessage("T.request",{
        "url":url,
        "options":options ? options: {
          "method":"GET"
        }
      });
    },

    getAppData:async function(k){
      return await T.postMessage("T.getAppData",{
        key:k
      });
    },

    getDeviceInfo:async function(){
      return await T.postMessage("T.getDeviceInfo",'');
    },

    getAppInfo: async function(){
      return await T.postMessage("T.getAppInfo",'');
    },

    onPagePop:function(fn){
      __TPageDidPopsMessages.push(fn);
      return true;
    },

    // 页面args和页面data
    _resolvePageArgsData: function(args,data){
      T.pageData = data;
      T.pageArguments = args;
    },

    // 页面弹出路由
    _resolvePageDidPop(args){
      if( __TPageDidPopsMessages.length){
        __TPageDidPopsMessages.forEach(function(fn){
          // console.log(i);
          fn(args);
        });
      }
    },

    // 跨页面消息传输，使用broadcast
    // 处理广播
    _resolveBroadcast:function(message){
      var name = message['name'];
      var data = message['data'];
      // console.log(message);
      // console.log(__TbroadcastSubscribes[name]);
      if(__TbroadcastSubscribes[name] && __TbroadcastSubscribes[name].length){
        // console.log(message);
        __TbroadcastSubscribes[name].forEach(function(fn){
          // console.log(i);
          fn(data);
        });
      }
    },

    // 订阅广播
    subscribe:function(name,fn){
      if(__TbroadcastSubscribes[name] && __TbroadcastSubscribes[name].length){
        __TbroadcastSubscribes[name].push(fn);
      }else{
        __TbroadcastSubscribes[name] = [fn];
      }
    },
    // 取消订阅
    unsubscribe:function(name,fn){
      if(__TbroadcastSubscribes[name]){
        __TbroadcastSubscribes[name].forEach(function(i,_fn){
          if(_fn==fn){
            __TbroadcastSubscribes[name].splice(i,1);
          }
        });
      }
    },
    // 广播消息，主要用于跨页面消息传播
    broadcast:function(name,data){
      return T.postMessage("T.broadcast",{
        "name":name,
        "data":data
      });
    },

    // 直接运行：使用浏览器打开链接，打开其它APP，打开系统功能(sms,tel...etc)等
    launch:async function(url){
      return await T.postMessage("T.launch",url);
    },

    toPage:async function(name,args,data,setting){
        return await T.postMessage("T.toPage",{
            name:name,
            args:args,
            data:data,
            setting:setting
        });
    },
    openPageByName:async function(name,args,data,setting){
      return await T.postMessage("T.openPage",{
          route:name,
          args:args,
          data:data,
          setting:setting
      });
    },
    back:async function(data){
      return await T.postMessage("T.back",data);
    },
    openPage:async function(url,args,data,route,setting){
        return await T.postMessage("T.openPage",{
            url:url,
            args:args,
            data:data,
            route:route,
            setting:setting
        });
    },
    // 获取widget
    getWidgetByName(name,widgetName,addTuna){
        var instance = '__'+widgetName+'Instances';
        if(!T[instance]){
            T[instance] = {};
        }
        var ret = T[instance][name];
        if(!ret){
            if(addTuna===false){
                ret = new Function('return new '+widgetName+'("'+name+'");')();
            }else{
                ret = new Function('return new Tuna'+widgetName+'("'+name+'");')();
            }
            
            T[instance][name] = ret;
        }
        return ret;
    },
    // 绑定 getWidget 快接方式
    bindWidget(widgetName,addTuna){
        var instance = '__'+widgetName+'Instances';
        if(!this[instance]){
          this[instance] = {};
        }
        var method = 'get'+widgetName;
        if(!T[method]){
          T[method] = function(name){
            return T.getWidgetByName(name,widgetName,addTuna);
          }
        }
    }
}

// widget 基类
class TunaWidget{
    constructor(name,widgetName){
        this.name = name;
        this.isReady = false;
        this.readyFns = [];
        this.widgetName = widgetName;
        this.eventName = "Tuna"+widgetName+"Event."+name;
    }

    ready(fn){
        if(this.isReady){
        fn.apply(this);
        }else{
        this.readyFns.push(fn);
        }
        return this;
    }

    resolveReadyStatus(){
        var _this = this;
        _this.readyFns.forEach(function(fn){
        try{
            if(fn && typeof(fn)=="function"){
            fn.call(_this);
            }
        }catch(e){
            console.error(e.toString());
        }
        });
        _this.readyFns = [];
        _this.isReady = true;
    }

    changeIndex(index){
        if(!this.index){
        this.index = 0;
        }
        this.prevIndex = this.index;
        this.index = index;
        this.callHandle("changeIndex",index);
        return this;
    }

    resolveOnChange(data){
        this.index = data.index;
        this.prevIndex = data.lastIndex;
        if(this.onChange){
        this.onChange.apply(this,[data]);
        }
    }

    callHandle(method,data){
        return T.postMessage(this.eventName,
        {
            "method":method,
            "data":data
        }
        );
    }
}

// http 请求
class HttpClient{
  // @setting:
    // @userAgent: userAgent default by "Tuna3HttpClient"
    // @headers: http req headers
    // @baseUrl: baseUrl req UrlPre
    // @timeout: microseconds default by 8000
    // @auth: { name: name,password:password}
    // @cert: 带证书请求，证书内容
  constructor(setting){
    this.userAgent = setting.userAgent || "Tuna3HttpClient";
    if(setting.headers){
      this.headers = setting.headers;
    }
    this.baseUrl = setting.baseUrl || "";
    this.timeout = setting.timeout;
    this.id = "HTTP."+new Date().getTime();
    T.postMessage("GetHttpClient",{
      "id":this.id,
      "setting":setting
    });
  }

  // @url: 请求地址
  // @setting:
    // @headers: 重写请求头
  request(url,setting){

  }
}


// tab bar widget constructor
class TunaTabBar extends TunaWidget{
    constructor(name){
      super(name,"TabBar");
    }
  }
  T.bindWidget('TabBar');
  
  // bottomNavBar
  class TunaBottomNavBar extends TunaWidget{
    constructor(name){
      super(name,"BottomNavBar");
    }
  }
  T.bindWidget('BottomNavBar');
  
  // indexedStack
  class TunaIndexedStack extends TunaWidget{
    constructor(name){
      super(name,"IndexedStack");
    }
  }
  T.bindWidget('IndexedStack');
  
  // scrollView
  class TunaScrollView extends TunaWidget{
    constructor(name){
      super(name,"ScrollView");
      this.__scrollerListener = [];
    }
  
    listen(fn){
      this.__scrollerListener.push(fn);
      return this.callHandle("listen","");
    }
  
    position(){
      return this.callHandle("position","");
    }
    offset(){
      return this.callHandle("offset","");
    }
  
    jumpTo(to){
      this.callHandle("jumpTo",to);
    }
  
    animateTo(to,duration,curve){
      var data = {"offset":to};
      if(duration>0){
        data["duration"] = duration;
      }
      if(curve){
        data["curve"] = curve
      }
      this.callHandle("animateTo",data);
    }
  
    resolveScrollListen(){
      if(this.__scrollerListener.length){
        var _this = this;
        _this.__scrollerListener.forEach(function(fn){
          fn.apply(_this,[]);
        });
      }
      return this;
    }
    
  }
  T.bindWidget('ScrollView');
  
  // refresh widget
  class TunaRefresh extends TunaWidget{
    constructor(name){
      super(name,"Refresh");
      this.__scrollerListener = [];
    }
  
    finishRefresh(success,noMore){
      this.callHandle("finishRefresh",{
        success:success,
        noMore:noMore
      });
    }

    resetFooter(){
      this.callHandle("resetFooter",true);
    }
    resetHeader(){
      this.callHandle("resetHeader",true);
    }
  
    finishLoad(success,noMore){
      this.callHandle("finishLoad",{
        success:success,
        noMore:noMore
      });
    }

    disableRefresh(){
        this.callHandle("disableRefresh","");
    }

    disableLoad(){
        this.callHandle("disableLoad","");
    }
    openRefresh(){
        this.callHandle("openRefresh","");
    }
    openLoad(){
        this.callHandle("openLoad","");
    }

    refresh(){
        this.callHandle("refresh","");
    }
    load(){
        this.callHandle("load","");
    }
  
    resetLoadState(){
      this.callHandle("resetLoadState","");
    }
  
    resetRefreshState(){
      this.callHandle("resetRefreshState","");
    }
  
    listen(fn){
      this.__scrollerListener.push(fn);
      return this.callHandle("listen","");
    }
  
    position(){
      return this.callHandle("position","");
    }
    offset(){
      return this.callHandle("offset","");
    }
  
    jumpTo(to){
      this.callHandle("jumpTo",to);
    }
  
    animateTo(to,duration,curve){
      var data = {"offset":to};
      if(duration>0){
        data["duration"] = duration;
      }
      if(curve){
        data["curve"] = curve
      }
      this.callHandle("animateTo",data);
    }
  
    resolveScrollListen(){
      if(this.__scrollerListener.length){
        var _this = this;
        _this.__scrollerListener.forEach(function(fn){
          fn.apply(_this,[]);
        });
      }
      return this;
    }
  
  }
  T.bindWidget('Refresh');

  // listView
  class TunaListView extends TunaWidget{
    constructor(name,initData){
      super(name,"ListView");
      this.__scrollerListener = [];
      if(initData){
        this.ready(()=>{
          this.callHandle("init",initData);
        });
      }
    }
  
    listen(fn){
      this.__scrollerListener.push(fn);
      return this.callHandle("listen","");
    }
  
    position(){
      return this.callHandle("position","");
    }
    offset(){
      return this.callHandle("offset","");
    }
  
    jumpTo(to){
      this.callHandle("jumpTo",to);
    }

    getRenderAt(){
      return this.callHandle('getRenderAt',"");
    }

    getItems(){
      return this.callHandle('getItems',"");
    }

    sublist(start,end){
      return this.callHandle('sublist',{
        start:start,
        end:end
      });
    }
  
    animateTo(to,duration,curve){
      var data = {"offset":to};
      if(duration>0){
        data["duration"] = duration;
      }
      if(curve){
        data["curve"] = curve
      }
      this.callHandle("animateTo",data);
    }

    add(items){
      return this.callHandle("add",items);
    }

    pop(){
      return this.callHandle("pop","");
    }

    shift(){
      return this.callHandle("shift",{});
    }
    unshift(data){
      return this.callHandle("unshift",data);
    }

    remove(start,end){
      return this.callHandle("remove",{
        "start":start?start:0,
        "end":end?end:start+1
      });
    }

    justSet(items){
      return this.callHandle("justSet",items);
    }

    replaceAll(items){
      return this.callHandle("replaceAll",items);
    }

    replace(items,start,end){
      return this.callHandle("replace",{
        "items":items,
        "start":start,
        "end":end
      });
    }
    clear(){
      return this.callHandle("clear","");
    }

    insert(items,start){
      return this.callHandle("insert",{
        "items":items,
        "start":start?start*1:0
      });
    }
  
    resolveScrollListen(){
      if(this.__scrollerListener.length){
        var _this = this;
        _this.__scrollerListener.forEach(function(fn){
          fn.apply(_this,[]);
        });
      }
      return this;
    }
    // just for builder list
    toggleReverse(){
      return this.callHandle("toggleReverse","");
    }

    setReverse(reverse){
      return this.callHandle("setReverse",reverse);
    }
    
  }
  
  T.getListView = function(name,initData){
      
    if(!T.__listViewInstances){
      T.__listViewInstances = {};
    }
    if(!T.__listViewInstances[name]){
      T.__listViewInstances[name] = new TunaListView(name,initData);
    }
    
    return T.__listViewInstances[name];
  }

  class TunaXWidget extends TunaWidget{
    constructor(name){
      super(name,"XWidget");
      this.data = { };
    }

    set(k,v){
        if(!v){
          this.callHandle("_setData",k);
        }else{
            var data = {};
            data[k] = v;
            this.callHandle("_setData",data);
        }
    }
  }
  T.getXWidget = function(name,initData){
    if(!T.__XWidgetInstances){
        T.__XWidgetInstances = {};
      }
      if(!T.__XWidgetInstances[name]){
        T.__XWidgetInstances[name] = new TunaXWidget(name,initData);
      }
      
      return T.__XWidgetInstances[name];
  }

  class TunaXBuilder extends TunaWidget{
    constructor(name,initData){
      super(name,"XBuilder");
      if(initData){
        this.data = initData;
        this.ready(()=>{
          this.callHandle("init",initData);
        });
      }else{
        this.data = {};
      }
    }

    set(k,v){
        if(!v){
          this.data = k;
          this.callHandle("set",k);
        }else{
            var data = {};
            data[k] = v;
            this.data[k] = v;
            this.callHandle("set",data);
        }
    }
    update(){
        this.callHandle("update","");
    }
    justSet(k,v){
        if(!v){
            this.callHandle("justSet",k);
        }else{
            var data = {};
            data[k] = v;
            this.callHandle("justSet",data);
        }
    }
    clear(){
        this.callHandle("clearData","");
    }
    justClear(){
        this.callHandle("jusetClear","");
    }
  }
  T.getXBuilder = function(name,initData){
    if(!T.__XBuilderInstances){
        T.__XBuilderInstances = {};
      }
      if(!T.__XBuilderInstances[name]){
        T.__XBuilderInstances[name] = new TunaXBuilder(name,initData);
      }
      
      return T.__XBuilderInstances[name];
  }



  // tab controller 
  class TunaTabController{
    constructor(id){
      this.id = id;
      this._listeners = [];
      this.isReady = false;
      this.readyFn = [];
    }

    setIndex(index){
      return this.callHandle("setIndex",index);
    }
    
    animateTo(index,options){
      return this.callHandle("animateTo",{
        "index":index,
        // options:  动画参数
        //    curve: 动画类型  
        //    duration: 动画时间（毫秒）
        "options":options
      });
    }
    ready(fn){
      if(this.isReady){
        fn.call(this);
      }else{
        this.readyFn.push(fn);
      }
    }

    resolveReadyStatus(){
      var _this = this;
      this.readyFn.forEach(function(fn){
        fn.call(_this);
      });
      this.readyFn = [];
      this.isReady = true;
    }

    getStatus(){
      return this.callHandle("getStatus","");
    }

    listen(fn){
      this._listeners.push(fn);
    }

    resolveListeners(message){
      var _this = this;
      this._listeners.forEach(function(fn){
        fn.apply(_this,[message]);
      });
    }

    callHandle(method,data){
      return T.postMessage("TunaTabControllerEvent."+this.id,{
        "method":method,
        "data":data
      });
    }
  }

  T.getTab = function(id){
    var tag ;
    if(this.__tabControllerInstance){
      tab = this.__tabControllerInstance[id];
      if(!tab){
        tab = this.__tabControllerInstance[id] = new TunaTabController(id);
      }
    }else{
      this.__tabControllerInstance = {};
      tab =this.__tabControllerInstance[id] = new TunaTabController(id);
    }
    return tab;
  }

  // webview 插件
  class TunaWebView extends TunaWidget{
    constructor(name){
      super(name,"WebView");
      this.__Listeners = [];
      this.__messageHandles = {};
    }
    // navigationDelegate： 
    //    @params request Object
    //      @key url : 当前页面的url
    //      @key isHome : 是否是主页
    //    @return  bool 返回false时页面不加载此url,默认返回true
    // r.navigationDelegate = function (request){
    //   return true;
    // }

    // 监听webview加载状态
    listen(fn){
      this.__Listeners.push(fn);
      return this;
    }

    // 添加与Webview 中的js交互方法
    addJavascriptChannel(name,fn){
      if(this.__messageHandles[name]){
        this.__messageHandles[name].push(fn);
      }else{
        this.__messageHandles[name] = [fn];
      }
      return this;
    }
    listenMessage(name,fn){
      return this.addJavascriptChannel(name,fn);
    }

    // 移除channel
    removeJavascriptChannel(name,fn){
      if(this.__messageHandles[name]){
        var i = 0;
        this.__messageHandles[name].forEach(function(fn){
          if(fn==fn){
            return this.__messageHandles[name].splice(i,1);
          }
          i++;
        });
      }
      return this;
    }

    resolveJsMessage(data){
      // console.log(data);
      if(data.name && this.__messageHandles[data.name]){
        var _this;
        this.__messageHandles[data.name].forEach(function(fn){
          fn.apply(_this,[data]);
        });
      }
    }

    evalJs(code){
      return this.callHandle('eval',code);
    }

    resolveListeners(message){
      var _this = this;
      this.__Listeners.forEach(function(fn){
        fn.apply(_this,[message]);
      });
    }

    goForward(){
      return this.callHandle("goForward","");
    }

    goBack(){
      return this.callHandle("goBack","");
    }

    reload(){
      return this.callHandle("reload","");
    }

    canGoBack(){
      return this.callHandle("canGoBack","");
    }
    canGoForward(){
      return this.callHandle("canGoForward","");
    }

    getTitle(){
      return this.callHandle("getTitle","");
    }

    canGoBack(){
      return this.callHandle("canGoBack","");
    }
    canGoForward(){
      return this.callHandle("canGoForward","");
    }

    getScrollX(){
      return this.callHandle("getScrollX","");
    }
    getScrollY(){
      return this.callHandle("getScrollY","");
    }
    currentUrl(){
      return this.callHandle("currentUrl","");
    }
    scrollTo(x,y){
      return this.callHandle("scrollTo",{
        x:x,
        y:y
      });
    }

    loadUrl(url){
      return this.callHandle("loadUrl",url);
    }

    clearCache(){
      return this.callHandle("clearCache","");
    }

  }
  T.bindWidget("WebView");
  

  // Offstage
  class TunaOffstage extends TunaWidget{
    constructor(name){
      super(name,"Offstage");
    }
    on(){
      return this.callHandle("on","");
    }
    off(){
      return this.callHandle("off","");
    }
  }
  T.bindWidget("Offstage");

  // input 组件
  class TunaInput extends TunaWidget{
    constructor(name){
      super(name,"Input");
    }
    
    onChanged(value){ }
    onSubmit(){ }
    onEditingComplete(){ }

    value(value){
      if(value){
        return this.callHandle("value",value);
      }
      return this.callHandle("getValue","");
    }

    clear(){
      return this.callHandle("clear","");
    }

    focus(){
      return this.callHandle("focus","");
    }

    unfocus(){
      return this.callHandle("unfocus","");
    }
    blur(){
      return this.callHandle("unfocus","");
    }

  }
  T.bindWidget("Input");

  // 绘图板
  class TunaSignPad extends TunaWidget{
    constructor(name){
      super(name,"SignPad");
    }
    
    onSign(value){ }
  
    getData(){
      return this.callHandle("getData","");
    }

    hasPoints(){
      return this.callHandle("hasPoints","");
    }

    clear(){
      return this.callHandle("clear","");
    }

  }
  T.bindWidget("SignPad");


  // 画报组件
  class TunaRepaint extends TunaWidget{
    constructor(name){
      super(name,"Repaint");
    }

    getImageData(){
      return this.callHandle("getImgData","");
    }

    capture(){
      return this.callHandle("capture","");
    }
  }
  T.bindWidget("Repaint");


// 基类，扩展的js module需要继承该类
var TunaJSWidgetsWindowCalls = {};
class TunaJsWidget{
  
    constructor(name,id,data){
      this.name = name;
      this.isReady = false;
      this._readyCalls  = [];

      if(!id){
        id = name+'.'+new Date().getTime()+""+(Math.random()*10);
      }
      this.id = id;
      TunaJSWidgetsWindowCalls[id] = this;
      this._methodCall("_onCreated",{id:'TunaJSWidgetsWindowCalls["'+id+'"]',data:data});
    }

    _methodCall(method,data){
      return T.postMessage("TunaJsWidget."+this.name,{
        "method":method,
        "data":data?data:"",
        "id":this.id
      });
    }

    ready(fn){
      if(this.isReady){
        fn.call(this);
      }else{
        this._readyCalls.push(fn);
      }
    }
    
    _resolveReady(){
      // console.log("is ready!");
      this.isReady = true;
      var _this = this;
      this._readyCalls.forEach(function(fn){
        fn.call(_this);
      });
      this._readyCalls = [];
    }
  }

// 调起相机及文件选择器
class AssetsPicker  extends TunaJsWidget{
  constructor(){
    super("AssetsPicker");
  }
  // options:
    // maxItems: 最大选择数据
    // pathThumbSize: 选择器显示相册缩略图大小
    // gridCount: 一列显示的照片数
    // pageSize: 一页显示的照片数
    // requestType: 选择器支持的文件类型[image,audio,video,common,all]
    // textColor: 选择器文字颜色
    // @return: Array [object,...]
        // "id":asset.id,
        // "path":file.path,
        // "title":asset title,
        // "type": asset.type,
        // "duration":asset.duration,
        // "width":asset.width,
        // "height":asset.height
  fromAssets(options){
    return this._methodCall("fromAssets",options);
  }
  // options:
    // enableRecording:是否允许录像
    // onlyEnableRecording: 是否只开启录相功能
    // cameraDirection: 摄像头方向
    // maxRecordingSeconds: 录制的最长时间，单位为秒
    // enableAudio: 是否允许录音
    // quality: 录像质量[high,medium,low,veryHigh,ultraHigh]
    // foregroundBuilder: 自定义模板
  fromCamera(options){
    return this._methodCall("fromCamera",options);
  }

  getAssetInfoById(id){
    return this._methodCall("getAssetInfoById",id);
  }
  getAssetByteDataById(id){
    return this._methodCall("getAssetByteDataById",id);
  }
  getThumbDataById(id){
    return this._methodCall("getThumbDataById",id);
  }
  getImageDataById(id){
    return this._methodCall("getImageDataById",id);
  }

  async getSizedThumbDataById(id,width,height,options){
    if(id && width>0 && height>0){
      return this._methodCall("getSizedThumbDataById",{
        id:id,
        width:width,
        height:height,
        format:options?options.format:"png",
        quality:options?options.quality:100
      });
    }
    return null;
  }

  getMediaUrlById(id){
    return this._methodCall("getMediaUrlById",id);
  }

  getFileById(id){
    return this._methodCall("getFileById",id);
  }

}

// Dio请求
class DioHttp extends TunaJsWidget{
  constructor(name,data){
      var id;
      
      var nameType = typeof(name);
      if(data==null){
          if(nameType=='string'){
              id = name;
          }else{
              data = name;
          }
      }else{
          id = name;
      }
      super("HttpModule",id,data?data:{});
      this.options = data;
  }

  // 加载回调监听，若要监听进度，需要自已在实例里扩展，total或progress 为 -1时，说明服务器不支持contentLength的获取。
  onGetReceiveProgress(res){
      // console.log(res.url+" onReceiveProgress: totalLength:"+res.total+"\t currentLength:"+res.progress);
  }
  onPostReceiveProgress(res){
      // console.log(res.url+" onPostReceiveProgress: totalLength:"+res.total+"\t currentLength:"+res.progress);
  }
  onPutSendProgress(res){
      // console.log(res.url+" onPutSendProgress: totalLength:"+res.total+"\t currentLength:"+res.progress);
  }
  onPatchReceiveProgress(res){
      // console.log(res.url+" onPutReceiveProgress: totalLength:"+res.total+"\t currentLength:"+res.progress);
  }
  onPatchSendProgress(res){
      // console.log(res.url+" onPatchSendProgress: totalLength:"+res.total+"\t currentLength:"+res.progress);
  }
  onPutReceiveProgress(res){
      // console.log(res.url+" onPatchReceiveProgress: totalLength:"+res.total+"\t currentLength:"+res.progress);
  }
  onDownloadReceiveProgress(res){
      // console.log(res.url+" onDownloadReceiveProgress: totalLength:"+res.total+"\t currentLength:"+res.progress);
  }

  // 发送请求
  request(url,type,setting){
      if(!setting){
          setting = {};
      }
      if('get,download,post,head,put,delete,patch'.indexOf(type.toLowerCase())!=-1){
          return this._methodCall(type,{
              url:url,
              data:setting['data'],// not for get
              savePath:setting['savePath'],// just for download
              dataType:setting['dataType'],
              options:setting['options'],
              querys:setting['querys']
          });
      }else{
          return false;
      }
  }

  post(url,setting){
      return this.request(url,'post',setting);
  }

  head(url,setting){
      return this.request(url,'head',setting);
  }
  put(url,setting){
      return this.request(url,'put',setting);
  }
  patch(url,setting){
      return this.request(url,'patch',setting);
  }
  delete(url,setting){
      return this.request(url,'delete',setting);
  }
  get(url,setting){
      return this.request(url,'get',setting);
  }
  download(url,setting){
      return this.request(url,'download',setting);
  }
}

// websocket
class TWebSocket extends TunaJsWidget{

  constructor(url,protocols,headers,pingInterval){
    super("TWebSocket",null,{
      "url":url,
      "protocols":protocols,
      "headers":headers,
      "pingInterval":pingInterval
    });
    this._isReady = false;
    this._readyFns = [];
  }

  onInited(){
    this._isReady = true;
    var _this = this;
    
    if(typeof(_this.onOpen)=='function'){
      _this.onOpen();
    }
    _this._readyFns.forEach(function(fn){
      if(typeof(fn)=='function'){
        fn.apply(_this);
      }
    });
    _this._readyFns = [];
  }


  send(message){
    var _this = this;
    var _fn = function(){
      _this._methodCall("sendMessage",message);
    };
    if(_this._isReady){
      _fn.apply(_this);
    }else{
      _this._readyFns.push(_fn);
    }
  }

  close(code,reason){
    var data = {
      code:code,
      reason:reason
    };
    if(this._isReady){
      this._methodCall("close",data);
    }else{
      this._readyFns.push(function(){
        this._methodCall("close",data);
      });
    }
  }

  reconnect(){
    this._methodCall("reconnect");
  }
}


// 文件操作
class File{
  constructor(fileName,options){
    var defaultOpts = {
      // 是否为临时文件夹
      isTemp:false,
      // 是否完整路径，若使用完整路径时，该项需要为true,否则程序会自动添加APP的根目标做为默认目录
      // 可通过 T.appDocumentsPath 及 T.appTempPath 获取APP文件路径
      isFullPath:false
    };
    if(options){
      for(var p in options){
        defaultOpts[p] = options[p];
      }
    }

    this.options = defaultOpts;
    this.fileName = fileName;
  }

  fullPath(){
    if(this.options.isTemp){
      return T.tempPath + this.fileName;
    }else{
      return T.docPath + this.fileName;
    }
  }

  exists(){
    return this.callHandle('exists');
  }

  writeAsString(fileData){
    return this.callHandle("writeAsString",fileData);
  }

  writeBase64Data(base64str){
    return this.callHandle("writeBase64Data",base64str);
  }

  // 按字符读取
  readAsString(){
    return this.callHandle("readAsString");
  }

  rename(newPath){
    return this.callHandle("rename",newPath);
  }
  moveTo(path){
    return this.callHandle("moveTo",path);
  }
  stat(){
    return this.callHandle("stat");
  }

  remove(){
    return this.callHandle("remove");
  }
  // 按二进制读取
  readAsBytes(){
    // 暂不支持
    return null;
  }

  callHandle(name,data){
    return T.postMessage("TunaFilePluginEvent",{
      "method":name,
      "fileName":this.fileName,
      "options":this.options,
      "data":!data?"":data
    });
  }

}

// 文件夹在操作类
class Dir {

  constructor(path,isTemp,isFullPath){
    this.isReady = false;
    this.path = path;
    this.isTemp = isTemp?true:false;
    this.isFullPath = isFullPath?true:false
  }

  exists(){
    return this.callHandle('exists');
  }

  create(){
    return this.callHandle('create');
  }
  rename(newPath){
    return this.callHandle("rename",newPath);
  }
  remove(){
    return this.callHandle('remove');
  }
  // 清空文件夹
  clear(){
    return this.callHandle('clear');
  }

  moveTo(path){
    return this.callHandle("moveTo",path);
  }

  list(){
    return this.callHandle('list');
  }

  callHandle(name,data){
    return T.postMessage("TunaDirectoryPluginEvent",{
      "method":name,
      "path":this.path,
      "isTemp":this.isTemp,
      "data":!data?"":data,
      "isFullPath":this.isFullPath
    });
  }
}
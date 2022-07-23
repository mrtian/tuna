// md5.js
!function(n){"use strict";function d(n,t){var r=(65535&n)+(65535&t);return(n>>16)+(t>>16)+(r>>16)<<16|65535&r}function f(n,t,r,e,o,u){return d((c=d(d(t,n),d(e,u)))<<(f=o)|c>>>32-f,r);var c,f}function l(n,t,r,e,o,u,c){return f(t&r|~t&e,n,t,o,u,c)}function v(n,t,r,e,o,u,c){return f(t&e|r&~e,n,t,o,u,c)}function g(n,t,r,e,o,u,c){return f(t^r^e,n,t,o,u,c)}function m(n,t,r,e,o,u,c){return f(r^(t|~e),n,t,o,u,c)}function i(n,t){var r,e,o,u;n[t>>5]|=128<<t%32,n[14+(t+64>>>9<<4)]=t;for(var c=1732584193,f=-271733879,i=-1732584194,a=271733878,h=0;h<n.length;h+=16)c=l(r=c,e=f,o=i,u=a,n[h],7,-680876936),a=l(a,c,f,i,n[h+1],12,-389564586),i=l(i,a,c,f,n[h+2],17,606105819),f=l(f,i,a,c,n[h+3],22,-1044525330),c=l(c,f,i,a,n[h+4],7,-176418897),a=l(a,c,f,i,n[h+5],12,1200080426),i=l(i,a,c,f,n[h+6],17,-1473231341),f=l(f,i,a,c,n[h+7],22,-45705983),c=l(c,f,i,a,n[h+8],7,1770035416),a=l(a,c,f,i,n[h+9],12,-1958414417),i=l(i,a,c,f,n[h+10],17,-42063),f=l(f,i,a,c,n[h+11],22,-1990404162),c=l(c,f,i,a,n[h+12],7,1804603682),a=l(a,c,f,i,n[h+13],12,-40341101),i=l(i,a,c,f,n[h+14],17,-1502002290),c=v(c,f=l(f,i,a,c,n[h+15],22,1236535329),i,a,n[h+1],5,-165796510),a=v(a,c,f,i,n[h+6],9,-1069501632),i=v(i,a,c,f,n[h+11],14,643717713),f=v(f,i,a,c,n[h],20,-373897302),c=v(c,f,i,a,n[h+5],5,-701558691),a=v(a,c,f,i,n[h+10],9,38016083),i=v(i,a,c,f,n[h+15],14,-660478335),f=v(f,i,a,c,n[h+4],20,-405537848),c=v(c,f,i,a,n[h+9],5,568446438),a=v(a,c,f,i,n[h+14],9,-1019803690),i=v(i,a,c,f,n[h+3],14,-187363961),f=v(f,i,a,c,n[h+8],20,1163531501),c=v(c,f,i,a,n[h+13],5,-1444681467),a=v(a,c,f,i,n[h+2],9,-51403784),i=v(i,a,c,f,n[h+7],14,1735328473),c=g(c,f=v(f,i,a,c,n[h+12],20,-1926607734),i,a,n[h+5],4,-378558),a=g(a,c,f,i,n[h+8],11,-2022574463),i=g(i,a,c,f,n[h+11],16,1839030562),f=g(f,i,a,c,n[h+14],23,-35309556),c=g(c,f,i,a,n[h+1],4,-1530992060),a=g(a,c,f,i,n[h+4],11,1272893353),i=g(i,a,c,f,n[h+7],16,-155497632),f=g(f,i,a,c,n[h+10],23,-1094730640),c=g(c,f,i,a,n[h+13],4,681279174),a=g(a,c,f,i,n[h],11,-358537222),i=g(i,a,c,f,n[h+3],16,-722521979),f=g(f,i,a,c,n[h+6],23,76029189),c=g(c,f,i,a,n[h+9],4,-640364487),a=g(a,c,f,i,n[h+12],11,-421815835),i=g(i,a,c,f,n[h+15],16,530742520),c=m(c,f=g(f,i,a,c,n[h+2],23,-995338651),i,a,n[h],6,-198630844),a=m(a,c,f,i,n[h+7],10,1126891415),i=m(i,a,c,f,n[h+14],15,-1416354905),f=m(f,i,a,c,n[h+5],21,-57434055),c=m(c,f,i,a,n[h+12],6,1700485571),a=m(a,c,f,i,n[h+3],10,-1894986606),i=m(i,a,c,f,n[h+10],15,-1051523),f=m(f,i,a,c,n[h+1],21,-2054922799),c=m(c,f,i,a,n[h+8],6,1873313359),a=m(a,c,f,i,n[h+15],10,-30611744),i=m(i,a,c,f,n[h+6],15,-1560198380),f=m(f,i,a,c,n[h+13],21,1309151649),c=m(c,f,i,a,n[h+4],6,-145523070),a=m(a,c,f,i,n[h+11],10,-1120210379),i=m(i,a,c,f,n[h+2],15,718787259),f=m(f,i,a,c,n[h+9],21,-343485551),c=d(c,r),f=d(f,e),i=d(i,o),a=d(a,u);return[c,f,i,a]}function a(n){for(var t="",r=32*n.length,e=0;e<r;e+=8)t+=String.fromCharCode(n[e>>5]>>>e%32&255);return t}function h(n){var t=[];for(t[(n.length>>2)-1]=void 0,e=0;e<t.length;e+=1)t[e]=0;for(var r=8*n.length,e=0;e<r;e+=8)t[e>>5]|=(255&n.charCodeAt(e/8))<<e%32;return t}function e(n){for(var t,r="0123456789abcdef",e="",o=0;o<n.length;o+=1)t=n.charCodeAt(o),e+=r.charAt(t>>>4&15)+r.charAt(15&t);return e}function r(n){return unescape(encodeURIComponent(n))}function o(n){return a(i(h(t=r(n)),8*t.length));var t}function u(n,t){return function(n,t){var r,e,o=h(n),u=[],c=[];for(u[15]=c[15]=void 0,16<o.length&&(o=i(o,8*n.length)),r=0;r<16;r+=1)u[r]=909522486^o[r],c[r]=1549556828^o[r];return e=i(u.concat(h(t)),512+8*t.length),a(i(c.concat(e),640))}(r(n),r(t))}function t(n,t,r){return t?r?u(t,n):e(u(t,n)):r?o(n):e(o(n))}"function"==typeof define&&define.amd?define(function(){return t}):"object"==typeof module&&module.exports?module.exports=t:n.md5=t}(this);

!(function () {
    /**
     * 模板引擎
     * @name    template
     * @param   {String} content template            
     * @param   {Object}    数据。
     * @return  {String}  渲染好的字符串
     */
    var template = function (content,data,options) {
        options = options||{}
        return compile(content,options)(data);
    };
    template.version = '1.0.0';

    /**
     * 设置全局配置
     * @name    template.config
     * @param   {String}    名称
     * @param   {Any}       值
     */
    template.config = function (name, value) {
        defaults[name] = value;
    };
    
    
    
    var defaults = template.defaults = {
        openTag: '<%',    // 逻辑语法开始标签
        closeTag: '%>',   // 逻辑语法结束标签
        escape: true,     // 是否编码输出变量的 HTML 字符
        cache: true,      // 是否开启缓存（依赖 options 的 filename 字段）
        compress: false,  // 是否压缩输出
        parser: null      // 自定义语法格式器 @see: template-syntax.js
    };
    
    
    var cacheStore = template.cache = {};
    
    
    /**
     * 渲染模板(根据模板名)
     * @name    template.render
     * @param   {String}    模板名
     * @param   {Object}    数据
     * @return  {String}    渲染好的字符串
     */
    var renderFile = template.renderFile = function (filename, data) {
        var fn = template.get(filename) || showDebugInfo({
            filename: filename,
            name: 'Render Error',
            message: 'Template not found'
        });
        return data ? fn(data) : fn;
    };
    
    
    /**
     * 获取编译缓存（可由外部重写此方法）
     * @param   {String}    模板名
     * @param   {Function}  编译好的函数
     */
    template.get = function (filename) {
    
        var cache;
        
        if (cacheStore[filename]) {
            // 使用内存缓存
            cache = cacheStore[filename];
        } else if (typeof document === 'object') {
            // 加载模板并编译
            var elem = document.getElementById(filename);
            
            if (elem) {
                var source = (elem.value || elem.innerHTML)
                .replace(/^\s*|\s*$/g, '');
                cache = compile(source, {
                    filename: filename
                });
            }
        }
    
        return cache;
    };
    
    
    var toString = function (value, type) {
    
        if (typeof value !== 'string') {
    
            type = typeof value;
            if (type === 'number') {
                value += '';
            } else if (type === 'function') {
                value = toString(value.call(value));
            } else {
                value = '';
            }
        }
    
        return value;
    
    };
    
    
    var escapeMap = {
        "<": "&#60;",
        ">": "&#62;",
        '"': "&#34;",
        "'": "&#39;",
        "&": "&#38;"
    };
    
    
    var escapeFn = function (s) {
        return escapeMap[s];
    };
    
    var escapeHTML = function (content) {
        return toString(content)
        .replace(/&(?![\w#]+;)|[<>"']/g, escapeFn);
    };
    
    
    var isArray = Array.isArray || function (obj) {
        return ({}).toString.call(obj) === '[object Array]';
    };
    
    
    var each = function (data, callback) {
        var i, len;        
        if (isArray(data)) {
            for (i = 0, len = data.length; i < len; i++) {
                callback.call(data, data[i], i, data);
            }
        } else {
            for (i in data) {
                callback.call(data, data[i], i);
            }
        }
    };
    
    
    var utils = template.utils = {
    
        $helpers: {},
    
        $include: renderFile,
    
        $string: toString,
    
        $escape: escapeHTML,
    
        $each: each
        
    };/**
     * 添加模板辅助方法
     * @name    template.helper
     * @param   {String}    名称
     * @param   {Function}  方法
     */
    template.helper = function (name, helper) {
        helpers[name] = helper;
    };
    
    var helpers = template.helpers = utils.$helpers;
    
    
    
    
    /**
     * 模板错误事件（可由外部重写此方法）
     * @name    template.onerror
     * @event
     */
    template.onerror = function (e) {
        var message = 'Template Error\n\n';
        for (var name in e) {
            message += '<' + name + '>\n' + e[name] + '\n\n';
        }
       
        if (typeof console === 'object') {
            console.error(message);
            console.error(e.toString());
        }
    };
    
    
    // 模板调试器
    var showDebugInfo = function (e) {
        template.onerror(e);
        return function () {
            return '{Template Error}';
        };
    };
    
    
    /**
     * 编译模板
     * 2012-6-6 @TooBug: define 方法名改为 compile，与 Node Express 保持一致
     * @name    template.compile
     * @param   {String}    模板字符串
     * @param   {Object}    编译选项
     *
     *      - openTag       {String}
     *      - closeTag      {String}
     *      - filename      {String}
     *      - escape        {Boolean}
     *      - compress      {Boolean}
     *      - debug         {Boolean}
     *      - cache         {Boolean}
     *      - parser        {Function}
     *
     * @return  {Function}  渲染方法
     */
    var compile = template.compile = function (source, options) {
        // console.log(source);
        // 合并默认配置
        options = options || {};
        for (var name in defaults) {
            if (options[name] === undefined) {
                options[name] = defaults[name];
            }
        }
    
        var filename = options.filename;
    
        try {
            var Render = compiler(source, options)
        } catch (e) {
        
            e.filename = filename || 'anonymous';
            e.name = 'Syntax Error';
            return showDebugInfo(e);
            
        }
        
        
        // 对编译结果进行一次包装
    
        function render (data) {
            
            try {
                
                return new Render(data, filename) + '';
                
            } catch (e) {
                
                // 运行时出错后自动开启调试模式重新编译
                if (!options.debug) {
                    options.debug = true;
                    return compile(source, options)(data);
                }
                console.error(source);
                return showDebugInfo(e)();
                
            }
            
        }
        
    
        render.prototype = Render.prototype;
        render.toString = function () {
            return Render.toString();
        };
    
    
        if (filename && options.cache) {
            cacheStore[filename] = render;
        }
    
        
        return render;
    
    };
    
    
    
    
    // 数组迭代
    var forEach = utils.$each;
    
    
    // 静态分析模板变量
    var KEYWORDS =
        // 关键字
        'break,case,catch,continue,debugger,default,delete,do,else,false'
        + ',finally,for,function,if,in,instanceof,new,null,return,switch,this'
        + ',throw,true,try,typeof,var,void,while,with'
    
        // 保留字
        + ',abstract,boolean,byte,char,class,const,double,enum,export,extends'
        + ',final,float,goto,implements,import,int,interface,long,native'
        + ',package,private,protected,public,short,static,super,synchronized'
        + ',throws,transient,volatile'
    
        // ECMA 5 - use strict
        + ',arguments,let,yield'
    
        + ',undefined';
    
    var REMOVE_RE = /\/\*[\w\W]*?\*\/|\/\/[^\n]*\n|\/\/[^\n]*$|"(?:[^"\\]|\\[\w\W])*"|'(?:[^'\\]|\\[\w\W])*'|\s*\.\s*[$\w\.]+/g;
    var SPLIT_RE = /[^\w$]+/g;
    var KEYWORDS_RE = new RegExp(["\\b" + KEYWORDS.replace(/,/g, '\\b|\\b') + "\\b"].join('|'), 'g');
    var NUMBER_RE = /^\d[^,]*|,\d[^,]*/g;
    var BOUNDARY_RE = /^,+|,+$/g;
    var SPLIT2_RE = /^$|,+/;
    
    
    // 获取变量
    function getVariable (code) {
        return code
        .replace(REMOVE_RE, '')
        .replace(SPLIT_RE, ',')
        .replace(KEYWORDS_RE, '')
        .replace(NUMBER_RE, '')
        .replace(BOUNDARY_RE, '')
        .split(SPLIT2_RE);
    };
    
    
    // 字符串转义
    function stringify (code) {
        return "'" + code
        // 单引号与反斜杠转义
        .replace(/('|\\)/g, '\\$1')
        // 换行符转义(windows + linux)
        .replace(/\r/g, '\\r')
        .replace(/\n/g, '\\n') + "'";
    }
    
    
    function compiler (source, options) {
        
        var debug = options.debug;
        var openTag = options.openTag;
        var closeTag = options.closeTag;
        var parser = options.parser;
        var compress = options.compress;
        var escape = options.escape;
        
    
        
        var line = 1;
        var uniq = {$data:1,$filename:1,$utils:1,$helpers:1,$out:1,$line:1};
        
    
    
        var isNewEngine = ''.trim;// '__proto__' in {}
        var replaces = isNewEngine
        ? ["$out='';", "$out+=", ";", "$out"]
        : ["$out=[];", "$out.push(", ");", "$out.join('')"];
    
        var concat = isNewEngine
            ? "$out+=text;return $out;"
            : "$out.push(text);";
              
        var print = "function(){"
        +      "var text=''.concat.apply('',arguments);"
        +       concat
        +  "}";
    
        var include = "function(filename,data){"
        +      "data=data||$data;"
        +      "var text=$utils.$include(filename,data,$filename);"
        +       concat
        +   "}";
    
        var headerCode = "'use strict';"
        + "var $utils=this,$helpers=$utils.$helpers,"
        + (debug ? "$line=0," : "");
        
        var mainCode = replaces[0];
    
        var footerCode = "return new String(" + replaces[3] + ");"
        
        // html与逻辑语法分离
        forEach(source.split(openTag), function (code) {
            code = code.split(closeTag);
            
            var $0 = code[0];
            var $1 = code[1];
            
            // code: [html]
            if (code.length === 1) {
                
                mainCode += html($0);
             
            // code: [logic, html]
            } else {
                
                mainCode += logic($0);
                
                if ($1) {
                    mainCode += html($1);
                }
            }
            
    
        });
        
        var code = headerCode + mainCode + footerCode;
        
        // 调试语句
        if (debug) {
            code = "try{" + code + "}catch(e){"
            +       "throw {"
            +           "filename:$filename,"
            +           "name:'Render Error',"
            +           "message:e.message,"
            +           "line:$line,"
            +           "source:" + stringify(source)
            +           ".split(/\\n/)[$line-1].replace(/^\\s+/,'')"
            +       "};"
            + "}";
        }
        
        
        
        try {
            
            
            var Render = new Function("$data", "$filename", code);
            Render.prototype = utils;
    
            return Render;
            
        } catch (e) {
            e.temp = "function anonymous($data,$filename) {" + code + "}";
            throw e;
        }
    
    
    
        
        // 处理 HTML 语句
        function html (code) {
            
            // 记录行号
            line += code.split(/\n/).length - 1;
    
            // 压缩多余空白与注释
            if (compress) {
                code = code
                .replace(/\s+/g, ' ')
                .replace(/<!--[\w\W]*?-->/g, '');
            }
            
            if (code) {
                code = replaces[1] + stringify(code) + replaces[2] + "\n";
            }
    
            return code;
        }
        
        
        // 处理逻辑语句
        function logic (code) {
    
            var thisLine = line;
           
            if (parser) {
            
                 // 语法转换插件钩子
                code = parser(code, options);
                
            } else if (debug) {
            
                // 记录行号
                code = code.replace(/\n/g, function () {
                    line ++;
                    return "$line=" + line +  ";";
                });
                
            }
            
            
            // 输出语句. 编码: <%=value%> 不编码:<%=#value%>
            // <%=#value%> 等同 v2.0.3 之前的 <%==value%>
            if (code.indexOf('=') === 0) {
    
                var escapeSyntax = escape && !/^=[=#]/.test(code);
    
                code = code.replace(/^=[=#]?|[\s;]*$/g, '');
    
                // 对内容编码
                if (escapeSyntax) {
    
                    var name = code.replace(/\s*\([^\)]+\)/, '');
    
                    // 排除 utils.* | include | print
                    
                    if (!utils[name] && !/^(include|print)$/.test(name)) {
                        code = "$escape(" + code + ")";
                    }
    
                // 不编码
                } else {
                    code = "$string(" + code + ")";
                }
                
    
                code = replaces[1] + code + replaces[2];
    
            }
            
            if (debug) {
                code = "$line=" + thisLine + ";" + code;
            }
            
            // 提取模板中的变量名
            forEach(getVariable(code), function (name) {
                
                // name 值可能为空，在安卓低版本浏览器下
                if (!name || uniq[name]) {
                    return;
                }
    
                var value;
    
                // 声明模板变量
                // 赋值优先级:
                // [include, print] > utils > helpers > data
                if (name === 'print') {
    
                    value = print;
    
                } else if (name === 'include') {
                    
                    value = include;
                    
                } else if (utils[name]) {
    
                    value = "$utils." + name;
    
                } else if (helpers[name]) {
    
                    value = "$helpers." + name;
    
                } else {
    
                    value = "$data." + name;
                }
                
                headerCode += name + "=" + value + ",";
                uniq[name] = true;
                
                
            });
            
            return code + "\n";
        }
        
        
    };
    
    
    
    // 定义模板引擎的语法
    
    
    defaults.openTag = '{{';
    defaults.closeTag = '}}';
    
    
    var filtered = function (js, filter) {
        var parts = filter.split(':');
        var name = parts.shift();
        var args = parts.join(':') || '';
    
        if (args) {
            args = ', ' + args;
        }
    
        return '$helpers.' + name + '(' + js + args + ')';
    }
    
    
    defaults.parser = function (code, options) {
    
        // var match = code.match(/([\w\$]*)(\b.*)/);
        // var key = match[1];
        // var args = match[2];
        // var split = args.split(' ');
        // split.shift();
    
        code = code.replace(/^\s/, '');
    
        var split = code.split(' ');
        var key = split.shift();
        var args = split.join(' ');
    
        
    
        switch (key) {
    
            case 'if':
    
                code = 'if(' + args + '){';
                break;
    
            case 'else':
                
                if (split.shift() === 'if') {
                    split = ' if(' + split.join(' ') + ')';
                } else {
                    split = '';
                }
    
                code = '}else' + split + '{';
                break;
    
            case '/if':
    
                code = '}';
                break;
    
            case 'each':
                
                var object = split[0] || '$data';
                var as     = split[1] || 'as';
                var value  = split[2] || '$value';
                var index  = split[3] || '$index';
                
                var param   = value + ',' + index;
                
                if (as !== 'as') {
                    object = '[]';
                }
                
                code =  '$each(' + object + ',function(' + param + '){';
                break;
    
            case '/each':
    
                code = '});';
                break;
    
            case 'echo':
    
                code = 'print(' + args + ');';
                break;
    
            case 'print':
            case 'include':
    
                code = key + '(' + split.join(',') + ');';
                break;
                
            case '_NOW':
            case 'now()':
                code = new Date().getTime()+'';
    
            default:
    
                // 过滤器（辅助方法）
                // {{value | filterA:'abcd' | filterB}}
                // >>> $helpers.filterB($helpers.filterA(value, 'abcd'))
                // TODO: {{ddd||aaa}} 不包含空格
                if (/^\s*\|\s*[\w\$]/.test(args)) {
    
                    var escape = true;
    
                    // {{#value | link}}
                    if (code.indexOf('#') === 0) {
                        code = code.substr(1);
                        escape = false;
                    }
    
                    var i = 0;
                    var array = code.split('|');
                    var len = array.length;
                    var val = array[i++];
    
                    for (; i < len; i ++) {
                        val = filtered(val, array[i]);
                    }
    
                    code = (escape ? '=' : '=#') + val;
    
                // 即将弃用 {{helperName value}}
                } else if (template.helpers[key]) {
                    
                    code = '=#' + key + '(' + split.join(',') + ');';
                
                // 内容直接输出 {{value}}
                } else {
    
                    code = '=' + code;
                }
    
                break;
        }
        
        
        return code;
    };
    
    this.template = template;


    /*
    * 常规通用插件
    */
    //截字
    template.helper('truncate',function(str,num,buf){
        buf = buf||'...';
        if(str.length>num){
            return str.substring(0,num)+buf;
        }else{
            return str;
        }
    });

    //encode plugin
    var htmlDecodeDict = { "quot": '"', "lt": "<", "gt": ">", "amp": "&", "nbsp": " " };
    var htmlEncodeDict = { '"': "quot", "<": "lt", ">": "gt", "&": "amp", " ": "nbsp" };

    template.helper('encode',function(str,type){
        //html encode
        if(type === 'html'){
            return String(str).replace(/["<>& ]/g, function(all) {
                    return "&" + htmlEncodeDict[all] + ";";
                });
        }else if(type === 'url'){
            return encodeURIComponent(String(str));
        }else{
            return str;
        }
    });
    //decode plugin
    template.helper('decode',function(str,type){
        if(type==='html'){
            return String(str).replace(/["<>& ]/g, function(all) {
                    return "&" + htmlDecodeDict[all] + ";";
                });
        }else if(type==='url'){
            return decodeURIComponent(String(str));
        }else{
            return str;
        }
    });

    template.helper('replace',function(str,parten,replacer){
        return str.replace(parten,replacer);
    });


    template.helper('default',function(str,val){
        if(!str||str==="")
            return val;
        return str;
    });

    template.helper('int',function(str){
        if(str){
            return parseInt(str);
        }
        return str;
    });

    template.helper('toFixed',function(str,fix){
        if(str){
            return new Number(str*1).toFixed(fix);
        }
        return str;
    });
    template.helper('ceil',function(str){
        if(str){
            Math.ceil(str*1);
        }
        return str;
    });
    template.helper('round',function(str){
        if(str){
            Math.round(str*1);
        }
        return str;
    });
    template.helper('floor',function(str){
        if(str){
            Math.floor(str*1);
        }
        return str;
    });

    template.helper("md5",function(str){
        if(str){
            try{
                str = md5(str);
            }catch(e){
                console.error(e.toString());
            }
        }
        return str;
    });
    
    // format:
    // YYYY-MM-DD;
    // Y-m-d
    template.helper('dateFormat',function(timeStr,fmt){
        timeStr = timeStr.trim().substr(0,13);
        var time = new Date(timeStr*1);
        var o = {
            "M+": time.getMonth() + 1, //月份 
            "d+": time.getDate(), //日 
            "h+": time.getHours(), //小时 
            "m+": time.getMinutes(), //分 
            "s+": time.getSeconds(), //秒 
            "q+": Math.floor((this.getMonth() + 3) / 3), //季度 
            "S": time.getMilliseconds() //毫秒 
        };
        if (/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (time.getFullYear() + "").substr(4 - RegExp.$1.length));
        for (var k in o)
        if (new RegExp("(" + k + ")").test(fmt)) fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
        return fmt;
    });

    // pubtime
    // @return : 3s前 ，刚刚 , 1天前
    template.helper("pubtimeFormat",function(timeStr,language){
        
      var timestamp  = (timeStr.toString().trim().substr(0,13))*1;
      
      var yearsFoward = language=="en"?" years ago":"天前";
      var yearsLater = language=="en"?" years later":"天后";
      var monthsFoward = language=="en"?" months ago":"天前";
      var monthsLater = language=="en"?" months later":"天后";
      var weeksFoward = language=="en"?" days ago":"天前";
      var weeksLater = language=="en"?" days later":"天后";
      var daysFoward = language=="en"?" days ago":"天前";
      var daysLater = language=="en"?" days later":"天后";
      var hoursFoward = language=="en"?" hours ago":"小时前";
      var hoursLater = language=="en"?" hours later":"小时后";
      var minsFoward = language=="en"?" minutes ago":"分钟前";
      var minsLater = language=="en"?" minutes later":"分钟后";
      
      var now = new Date().getTime();
      var _dis = Math.abs(now - timestamp);
      
      var days = _dis>86400000?parseInt(_dis/86400000):0;
      var hours = _dis>3600000?parseInt(_dis/3600000):0;
      var minutes = 3600000>60000?parseInt(_dis/60000):0;
      
      if(now - timestamp >= 0 ){
        if(days>0){
          if(days>365){
            return (days/365).toFixed(0)+yearsFoward;
          }else if(days>=30){
            return (days/30).toFixed(0)+monthsFoward;
          }else if(days>=7){
            return (days/7).toFixed(0)+weeksFoward;
          }else{
            return days+daysFoward;
          }
        }else{
          if(hours>0){
            return hours+hoursFoward;
          }else if(minutes>=30){
            return (language=="en"?" half":"半")+hoursFoward;
          }else if(minutes>0){
            return minutes.toString()+minsFoward;
          }else{
            return language=="en"?"now":"刚刚";
          }
        }
      }else{
        if(days>0){
          if(days>365){
            return (days/365).toFixed(0)+yearsLater;
          }else if(days>=30){
            return (days/30).toFixed(0)+monthsLater;
          }else if(days>=7){
            return (days/7).toFixed(0)+weeksLater;
          }else{
            return days+daysLater;
          }
        }else{
          if(hours>0){
            return hours+hoursLater;
          }else if(minutes>=30){
            return (language=="en"?" half":"半")+hoursLater;
          }else if(minutes>0){
            return minutes+minsLater;
          }else{
            return language=="en"?"now":"刚刚";
          }
        }
      }
    });

})();


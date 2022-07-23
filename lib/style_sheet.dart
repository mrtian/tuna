
import 'utils/merge_map.dart';
import 'utils/style_parse.dart';

// 样式类型
enum RuleType{
  tagName,
  className,
  inline
}

// 样式
class StyleRule{
  
  final RuleType? type;
  final Map<String,dynamic>? style;
  final String? name;

  StyleRule({
    this.name,this.type,this.style
  });

  @override
  String toString() {
    return "{name: $name, type: $type, style: $style}";
  }
}

// 样式表
class TStyleSheet{

  String? templateId;
  Map<String,StyleRule> sheets = {};

  TStyleSheet(String stylesCode,{String? templateId}){
    this.templateId = templateId;
    // ignore: unnecessary_null_comparison
    if(stylesCode!=null && stylesCode.isNotEmpty){
      _parseCode(stylesCode);
    }
  }

  _parseCode(String code){
    // 去除注释
    code = code.replaceAll(RegExp(r"\/\*.*\*\/"), "");
    code = code.replaceAll(RegExp("[\r\n]"), "");
    
    var ruleReg = RegExp(r"([^{}]+){([^}]+)}");
    var matches = ruleReg.allMatches(code);

    matches.forEach((match) {
      var name = match.group(1);
      var val = match.group(2);
      if(name!=null && name.isNotEmpty && val!=null && val.isNotEmpty){
        val = val.trim();
        name = name.trim().replaceAll(RegExp(r"[\t\r\n\s]+"), " ");
        
        var names = name.split(RegExp(r"[\s]+"));
        var lastName = names[names.length-1];
        Map<String,dynamic>rules = StyleParse.convertAttr(val);
        var ruleType;

        if(lastName.startsWith(".")){
          ruleType = RuleType.className;
        }else{
          ruleType = RuleType.tagName;
        }
        List<String> cNames = [];
        if(names.length>0){
          names.forEach((n) {
            if(!n.startsWith(".")){
              n = "TN:"+n;
            }
            cNames.add(n.replaceAll(".", ".CN:"));
          });
        }
        Map<String,dynamic> _emptyMap = {};
        if(rules is Map){
          _emptyMap = rules;
        }
        var styleRule = StyleRule(
          type:ruleType,
          name: cNames.join(" "),
          style: _emptyMap
        );
        sheets[name] = styleRule;
      }
      
    });
  }

  // 合并样式
  static mergeStyle(Iterable<Map<String, dynamic>>? styleList){
    if(styleList!=null){
      Map<String,dynamic> ret;
      ret = mergeMap(styleList);
      return ret;
    }
  }

  // 获取样式
  getStyle(List<String> sheetTree){
    // print(sheetTree);
    String styleTree = sheetTree.join(" ");
    List<Map<String,dynamic>> styles = [];

    sheets.forEach((idMame, StyleRule styleRule) {
      String name = styleRule.name!.replaceAll(".", "\.");
      var nameList = name.split(RegExp(r"[\s\t]+"));
      var regName = nameList.join("[\\s].*");
      RegExp reg = RegExp(regName);
      
      // 最小匹配
      if(reg.hasMatch(styleTree)){
        // 再判断styleTree 是否包含在最小匹配的样式中
        if(nameList.length==1 && reg.hasMatch(sheetTree.last)){
          styles.add(styleRule.style!);
        }else if(nameList.length>1 && RegExp(nameList.last).hasMatch(sheetTree.last)){
          styles.add(styleRule.style!);
        }
      }
    });
    return TStyleSheet.mergeStyle(styles);
  }

}
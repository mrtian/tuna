import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:tuna3/js_runtime.dart';
import 'package:tuna3/style_sheet.dart';
import 'package:tuna3/utils/style_parse.dart';
import 'package:html/dom.dart' as dom;

import '../../tuna3.dart';
import '../widget.dart';


cupertinoEvaluate(handle, value, map) {
  if (handle != null) {
    var callHandle;

    var args = {};
    if (handle is Map) {
      callHandle = handle["handle"];
      args = Map.from(handle);
      args.remove("handle");
    } else if (handle is String && handle.isNotEmpty) {
      callHandle = handle;
    }
    if (callHandle == null || callHandle == "false" || callHandle.isEmpty) {
      return;
    }
    args["value"] = value;
    // map.jsEngine.evaluate(callHandle+'('+json.encode(args)+')');
    map.jsEngine.evaluateFunc(callHandle, args);
  }
}

getTextWeight(item) {
    var itemStyle = {};
    if (item is String) {
      itemStyle["text"] = item;
    } else if (item is Map) {
      itemStyle = item;
    } else {
      return null;
    }
    return Text(itemStyle["text"] ?? "",
        style: TextStyle(
            color: itemStyle['color'] != null
                ? StyleParse.hexColor(itemStyle['color'])
                : Color(0xFF0E7DFF),
            fontSize: itemStyle['fontSize'] != null
                ? double.parse(itemStyle['fontSize'])
                : 16.0,
            fontWeight: itemStyle.containsKey('fontWeight')
                ? StyleParse.fontWeight(itemStyle['fontWeight'])
                : null));
  }

class TWidgetCupertinoSwitch extends TWidget {
  @override
  parse(dom.Element node, JsRuntime jsRuntime,{TStyleSheet? styleSheet}) {
    Map<String, dynamic> attrs = getAttributes(node);
    var onChanged;
    if (attrs.containsKey("onChanged")) {
      onChanged = StyleParse.convertAttr(attrs["onChanged"].trim());
    }
    var onChangedCall = onChanged != null
        ? (value) {
            cupertinoEvaluate(onChanged, value, node);
          }
        : null;

    var value = attrs["value"];
    return CupertinoSwitch(
        activeColor: StyleParse.hexColor(attrs["activeColor"]),
        trackColor: StyleParse.hexColor(attrs["trackColor"]),
        dragStartBehavior: (attrs.containsKey("down"))
            ? DragStartBehavior.down
            : DragStartBehavior.start,
        value: (value != null && (value == "true" || value == true)),
        onChanged: onChangedCall);
  }
}

class TunaCupertinoSegmentedControl {
  parse(dom.Element node, JsRuntime jsRuntime,{TStyleSheet? styleSheet}) {
    return TunaCupertinoSegmentedControlWidget(node,jsRuntime,styleSheet:styleSheet);
  }
}

class TunaCupertinoSegmentedControlWidget extends StatefulWidget {
  final dom.Element node;
  final JsRuntime jsRuntime;
  final TStyleSheet? styleSheet;
  const TunaCupertinoSegmentedControlWidget(this.node,this.jsRuntime, {Key? key,this.styleSheet}) : super(key: key);

  @override
  _TunaCupertinoSegmentedControlWidgetState createState() =>
      _TunaCupertinoSegmentedControlWidgetState();
}

class _TunaCupertinoSegmentedControlWidgetState
    extends State<TunaCupertinoSegmentedControlWidget> {
  dynamic groupValue;
  dynamic eventParams;
  String? name;

  @override
  void initState() {
    super.initState();
    groupValue = (widget.node.attributes["index"] ?? 0).toString();
    name = widget.node.attributes.containsKey("name") ? widget.node.attributes["name"] : null;
    if (name != null) {
      widget.jsRuntime.addWidgetMessageHandle(
          "CupertinoControls", widget.node.attributes["name"]!, (params) async {
        var method = params["method"];
        var data = params["data"]??{};
        if (method != null && method.isNotEmpty) {
          if (method == "segmentedValue") {
            if (data.containsKey('value') && mounted && groupValue != data['value'].toString()) {
                setState((){
                    groupValue = data['value'].toString();
                });
            }
            return groupValue;
          }
        }
      });
    }
  }
  
  @override
  void dispose() {
    super.dispose();
  }
 
  static colorValue(map, key, dl) {
    if (map is Map) {
      return StyleParse.hexColor(map[key]) ?? dl;
    } else {
      return dl;
    }
  }

  @override
  Widget build(BuildContext context) {
    
    // ignore: unnecessary_null_comparison
    if (widget.node.children == null || widget.node.children.isNotEmpty) {
      return Container();
    }

    Map<String, Widget> children = <String,Widget>{};
    int i = 0;
    widget.node.children.forEach((ele) {
      children[i.toString()] = Tuna3.parseWidget(ele,widget.jsRuntime,styleSheet: widget.styleSheet);
      i++;
    });

    if (groupValue != null && (int.parse(groupValue!) < 0 || int.parse(groupValue!) >= widget.node.children.length)) {
      groupValue = "0";
    }
    
    var onChanged;
    if (widget.node.attributes.containsKey("onChanged")) {
      onChanged = StyleParse.convertAttr(widget.node.attributes["onChanged"]!.trim());
    }

    return CupertinoSegmentedControl<String>(
      groupValue: groupValue,
      unselectedColor: colorValue(widget.node.attributes, "unselectedColor", null),
      selectedColor: colorValue(widget.node.attributes, "selectedColor", null),
      borderColor: colorValue(widget.node.attributes, "borderColor", null),
      pressedColor: colorValue(widget.node.attributes, "pressedColor", null),
      padding: StyleParse.edgeInsetsGeometry(widget.node.attributes["padding"]),
      children: children,
      onValueChanged: (k) {
        if (mounted) {
          setState(() {
            groupValue = k.toString();
          });
        }
        if (onChanged != null) {
          cupertinoEvaluate(onChanged, k.toString(), widget.node);
        }
      },
    ); 
  }
}


class TunaCupertinoDatePicker  extends TWidget{
  static var _value;
  _parseDate(oV) {
    var retV;
    var v = oV.toString();
    if (v != null) {
      try {
        if ((v.length == 10 || "".length == 13)) {
          if (RegExp(r"^[0-9]{10,13}$").hasMatch(v)) {
            var fillNum = 13 - v.length;
            if (fillNum > 0) {
              for (var i = 0; i < fillNum; i++) {
                v += "0";
              }
            }
            retV = DateTime.fromMillisecondsSinceEpoch(int.parse(v));
          }
        }
        retV ??= DateTime.parse(v);
      } catch (e) {
        retV = null;
      }
    }
    return retV;
  }

  @override
  parse(dom.Element node, JsRuntime jsRuntime,{TStyleSheet? styleSheet}) {
    _value = "";
    Map<String, dynamic> attrs = getAttributes(node);
    var onChanged;
    if (attrs.containsKey("onChanged")) {
      onChanged = StyleParse.convertAttr(attrs["onChanged"].trim());
    }
    var minimumYear =
        attrs["minYear"] != null ? int.parse(attrs["minYear"].toString()) : 1;
    var maximumYear = attrs["maxYear"] != null
        ? int.parse(attrs["maxYear"].toString())
        : null;
    var minuteInterval = attrs["minInterval"] != null
        ? int.parse(attrs["minInterval"].toString())
        : 1;

    CupertinoDatePickerMode mode = CupertinoDatePickerMode.dateAndTime;
    if (attrs["mode"] != null && attrs["mode"] == "time") {
      mode = CupertinoDatePickerMode.time;
    } else if (attrs["mode"] != null && attrs["mode"] == "date") {
      mode = CupertinoDatePickerMode.date;
    }

    DateTime initialDateTime = DateTime.now();
    DateTime? minimumDate;
    DateTime? maximumDate;

    if (attrs["maxDate"] != null) {
      maximumDate = (attrs["maxDate"] == "today")
          ? DateTime.now()
          : _parseDate(attrs["maxDate"]);
    }

    if (attrs["minDate"] != null) {
      if (attrs["minDate"] == "today") {
        maximumDate = DateTime.now();
      } else {
        maximumDate = _parseDate(attrs["minDate"]);
      }
    }

    if (attrs["initDate"] != null) {
      initialDateTime = _parseDate(attrs["initDate"]) ?? initialDateTime;
      if (maximumDate != null &&
          initialDateTime.millisecondsSinceEpoch >
              maximumDate.millisecondsSinceEpoch) {
        initialDateTime = maximumDate;
      } else if (minimumDate != null &&
          initialDateTime.millisecondsSinceEpoch <
              minimumDate.millisecondsSinceEpoch) {
        initialDateTime = minimumDate;
      }
    }

    // ignore: prefer_function_declarations_over_variables
    var onChangedCall = (value) {
      _value = value.toString();
      if (onChanged != null) {
        cupertinoEvaluate(onChanged, _value, node);
      }
    };

    if (attrs["name"] != null) {
      jsRuntime.addWidgetMessageHandle(
          "CupertinoControls", attrs["name"], (params) async {
        var method = params["method"];
        // var postData = params["data"];
        if (method != null && method.isNotEmpty) {
          if (method == "datePickerValue") {
            return _value;
          }
        }
      });
    }

    try {
      if (initialDateTime != null) {
        _value = initialDateTime.toString();
      } else if (maximumDate != null &&
          maximumDate.millisecondsSinceEpoch <
              DateTime.now().millisecondsSinceEpoch) {
        _value = maximumDate.toString();
      } else {
        _value = DateTime.now().toString();
      }
    } catch (e) {}

    return CupertinoDatePicker(
      mode: mode,
      onDateTimeChanged: onChangedCall,
      initialDateTime: initialDateTime,
      minimumDate: minimumDate,
      maximumDate: maximumDate,
      minimumYear: minimumYear,
      maximumYear: maximumYear,
      minuteInterval: minuteInterval,
      use24hFormat:
          attrs["fullFormat"] != null && attrs["fullFormat"] == "false"
              ? false
              : true,
      backgroundColor: StyleParse.hexColor(attrs["backgroundColor"]),
    );
  }
}

class TunaCupertinoActionSheet {
  static show(JsRuntime jsRuntime, data) async {
    return await showCupertinoModalPopup(
        context: Get.context!,
        builder: (BuildContext context) {
          var res = data["options"] ?? {};
          List<Widget> actions = [];
          var callHandle = "";
          if (res["handle"] != null && res["handle"] is String) {
            callHandle = res["handle"];
          }

          if (res.containsKey("actions") && res["actions"] is List) {
            int index = 0;
            for (var ele in res["actions"]) {
              var rowParams = {};
              if (ele is Map && ele["ext"] != null) {
                if (ele["ext"] is Map) {
                  ele["ext"].forEach((key, value) {
                    rowParams[key] = value;
                  });
                } else {
                  rowParams["ext"] = ele["ext"];
                }
              }
              rowParams["text"] = "";
              if (ele is String) {
                rowParams["text"] = ele;
              } else if (ele is Map) {
                rowParams["text"] = ele["text"];
              }
              rowParams["_index"] = index.toString();
              index++;
              actions.add(CupertinoActionSheetAction(
                  isDefaultAction: (ele is Map && ele['default'] != null)
                      ? (ele['default'] == "true")
                      : false,
                  isDestructiveAction:
                      (ele is Map && ele['destructive'] != null)
                          ? (ele['destructive'] == "true")
                          : false,
                  child: getTextWeight(ele),
                  onPressed: () {
                    if (callHandle.isNotEmpty) {
                      jsRuntime.evaluateFunc(callHandle, rowParams);
                    } else {
                      Navigator.of(context).pop(rowParams["_index"]);
                    }
                  }));
            }
          }
          var cancel = {"_index": "-1"};
          if (res.containsKey("actions") && res["actions"] is Map) {
            if (res["ext"] is Map) {
              res["ext"].forEach((key, value) {
                cancel[key] = value;
              });
            } else {
              cancel["ext"] = res["ext"];
            }
          }
          var title = data["message"];
          if (res["title"] != null) {
            title = res["title"];
          }

          return CupertinoActionSheet(
              title: title != null ? getTextWeight(res["title"]) : null,
              message: res["message"] != null ? getTextWeight(res["message"]) : null,
              actions: actions,
              cancelButton: res["cancel"] != null
                  ? CupertinoButton(
                      child: getTextWeight(res["cancel"]),
                      onPressed: () {
                        if (callHandle.isNotEmpty) {
                          jsRuntime.evaluateFunc(callHandle, cancel);
                        } else {
                          Navigator.of(context).pop("-1");
                        }
                      })
                  : null);
        });
  }
}

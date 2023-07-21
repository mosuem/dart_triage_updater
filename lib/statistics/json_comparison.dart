import 'dart:convert';

import 'package:json_diff/json_diff.dart';

Object diff(Object json1, Object json2) {
  return JsonDiffer.fromJson(json1, json2).diff().toJson();
}

extension DiffNodeSerialization on DiffNode {
  String toJson() {
    return jsonEncode(_toList());
  }

  Map _toList() {
    final r = removed.map((key, value) => MapEntry(key.toString(), value));
    final a = added.map((key, value) => MapEntry(key.toString(), value));
    final c = changed.map((key, value) => MapEntry(key.toString(), value));
    final m = moved.map((key, value) => MapEntry(key.toString(), value));
    final n = {for (final e in node.entries) e.key: e.value._toList()};
    return {
      'p': path,
      if (r.isNotEmpty) 'r': r,
      if (a.isNotEmpty) 'a': a,
      if (c.isNotEmpty) 'c': c,
      if (m.isNotEmpty) 'm': m,
      if (n.isNotEmpty) 'n': n
    };
  }
}

DiffNode fromJson(String jsonStr) {
  return fromSerialized(jsonDecode(jsonStr));
}

DiffNode fromSerialized(Map<String, dynamic> obj) {
  final diffNode = DiffNode(List.from(obj['p']))
    ..removed.addAll(Map.from(obj['r'] ?? {}))
    ..added.addAll(Map.from(obj['a'] ?? {}))
    ..changed.addAll(Map.from(obj['c'] ?? {}))
    ..moved.addAll(Map.from(obj['m'] ?? {}));
  for (final node in ((obj['n'] ?? {}) as Map).entries) {
    diffNode[node.key] = fromSerialized(node.value);
  }

  return diffNode;
}
// T? diff<T>(T oldJson, T newJson) {
//   if (T is Map<String, dynamic>) {
//     return diffMap(
//         oldJson as Map<String, dynamic>, newJson as Map<String, dynamic>) as T;
//   } else if (T is List) {
//   } else {}
// }

// Map<String, dynamic> diffMap(
//   Map<String, dynamic> oldJson,
//   Map<String, dynamic> newJson,
// ) {
//   final result = <String, dynamic>{};

//   final oldKeys = oldJson.keys.where((key) => !newJson.keys.contains(key));
//   final newKeys = newJson.keys.where((key) => !oldJson.keys.contains(key));
//   final commonKeys = oldJson.keys.where((key) => !oldKeys.contains(key));

//   if (oldKeys.isNotEmpty) {
//     return newJson;
//   }
//   if (newKeys.isNotEmpty) {
//     for (var key in newKeys) {
//       result[key] = newJson[key];
//     }
//   }

//   for (final key in commonKeys) {
//     final oldValue = oldJson[key];
//     final newValue = newJson[key];
//     final diff2 = diff(oldValue, newValue);
//     if (diff2 != null) {
//       result[key] = diff2;
//     }
//   }
//   return result;
// }

// List? diffList(List oldJson, List newJson) {
//   if (!ListEquality().equals(oldJson, newJson)) {
//     return newJson;
//   } else {
//     return null;
//   }
// }

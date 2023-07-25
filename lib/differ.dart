import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:json_diff/json_diff.dart';

typedef Json = Map<String, dynamic>;

Object diff(Object json1, Object json2) {
  return JsonDiffer.fromJson(json1, json2).diff().toJsonString();
}

extension DiffNodeSerialization on DiffNode {
  T apply<T>(T child) {
    Object applied;
    if (child is List) {
      applied = _applyToList(child);
    } else if (child is Map<String, dynamic>) {
      applied = _applyToMap(child);
    } else {
      throw ArgumentError();
    }
    return applied as T;
  }

  List _applyToList(List original) {
    final other = List.from(original);
    for (final entry in added.entries) {
      final key = toInt(entry.key);
      if (key >= other.length) {
        other.add(entry.value);
      } else {
        other[key] = entry.value;
      }
    }
    for (final entry in changed.entries) {
      final key = toInt(entry.key);
      other[key] = entry.value.last;
    }
    for (final entry in removed.entries) {
      final key = toInt(entry.key);
      other.removeAt(key);
    }
    for (final entry in moved.entries) {
      other.swap(entry.key, entry.value);
    }
    for (final entry in node.entries) {
      final key = toInt(entry.key);
      final child = original[key];
      other[key] = entry.value.apply(child);
    }
    return other;
  }

  Map<String, dynamic> _applyToMap(Map<String, dynamic> original) {
    final other = Map<String, dynamic>.from(original);
    for (final entry in added.entries) {
      final key = entry.key as String;
      other[key] = entry.value;
    }
    for (final entry in changed.entries) {
      final key = entry.key.toString();
      other[key] = entry.value.last;
    }
    for (final entry in removed.entries) {
      final key = entry.key as String;
      other.remove(key);
    }
    for (final entry in node.entries) {
      final key = entry.key as String;
      final child = original[key];
      other[key] = entry.value.apply(child);
    }
    return other;
  }

  DiffNode operator +(DiffNode other) {
    return DiffNode(path)
      ..added.addAll({...added, ...other.added})
      ..changed.addAll({...changed, ...other.changed})
      ..moved.addAll({...moved, ...other.moved})
      ..removed.addAll({...removed, ...other.removed})
      ..node.addEntries({...node.keys, ...other.node.keys}.map((e) {
        return MapEntry(
            e, (node[e] ?? DiffNode(path)) + (other.node[e] ?? DiffNode(path)));
      }));
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  Map<String, dynamic> toJson() {
    final r = removed.map((key, value) => MapEntry(toMapKey(key), value));
    final a = added.map((key, value) => MapEntry(toMapKey(key), value));
    final c = changed.map((key, value) => MapEntry(toMapKey(key), value));
    final m = moved.map((key, value) => MapEntry(toMapKey(key), value));
    final n = {for (final e in node.entries) e.key: e.value.toJson()};
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

int toInt(Object key) {
  if (key is int) {
    return key;
  } else {
    return int.parse(key.toString());
  }
}

String toMapKey(Object key) {
  if (key is int) {
    return '@$key';
  }
  return key.toString().isNotEmpty ? key.toString() : '@';
}

DiffNode diffNodeFromJson(Map<String, dynamic> jsonStr) {
  return fromSerialized(jsonStr);
}

DiffNode fromSerialized(Map<String, dynamic> obj) {
  final diffNode = DiffNode(List.from(obj['p'] ?? []))
    ..removed.addAll(Map.from(obj['r'] ?? {}).map(fromKey))
    ..added.addAll(Map.from(obj['a'] ?? {}).map(fromKey))
    ..changed.addAll(Map.from(obj['c'] ?? {}).map(fromKey))
    ..moved.addAll(Map.from(obj['m'] ?? {}).map(fromKey));
  for (final node in ((obj['n'] ?? {}) as Map).entries) {
    diffNode[node.key] = fromSerialized(node.value);
  }
  return diffNode;
}

MapEntry<S, T> fromKey<S, T>(dynamic key, dynamic value) {
  final k = key.toString().startsWith('@') ? key.toString().substring(1) : key;
  return MapEntry(k, value);
}

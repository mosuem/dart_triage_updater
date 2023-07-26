import 'package:dart_triage_updater/differ.dart';
import 'package:json_diff/json_diff.dart';

class DataDiff<S> {
  final Map<String, dynamic> _initial;
  final Map<DateTime, DiffNode> _changes;
  final S Function(Map<String, dynamic> json) fromJson;

  DataDiff(this._initial, this._changes, this.fromJson) {
    assert(_changes.values.first.toJsonString() == DiffNode([]).toJsonString());
  }

  S? applied([DateTime? atTime]) {
    final map = _changes.entries
        .where((entry) => atTime != null ? entry.key.isBefore(atTime) : true)
        .map((e) => e.value);
    if (map.isNotEmpty) {
      final allChanges = map.reduce((node1, node2) => node1 + node2);
      return fromJson(allChanges.apply(_initial));
    }
    return null;
  }

  Map<DateTime, T> getTimeSeries<T>(T Function(S issue) getData) {
    var current = _initial;
    final result = <DateTime, T>{};
    for (final element in _changes.entries) {
      current = element.value.apply(current);
      result[element.key] = getData(fromJson(current));
    }
    return result;
  }

  Duration? getTimeUntil(bool Function(S) condition) {
    var current = _initial;
    final initialEntry = _changes.entries.first.key;
    for (final element in _changes.entries) {
      current = element.value.apply(current);
      if (condition(fromJson(current))) {
        return element.key.difference(initialEntry);
      }
    }
    return null;
  }
}

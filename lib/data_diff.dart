import 'package:dart_triage_updater/differ.dart';
import 'package:json_diff/json_diff.dart';

class DataDiff<S> {
  final Map<String, dynamic> _initial;
  final Map<DateTime, DiffNode> _changes;
  final S Function(Map<String, dynamic> json) fromJson;

  DataDiff(this._initial, this._changes, this.fromJson) {
    assert(_changes.values.first.toJsonString() == DiffNode([]).toJsonString());
  }

  S applied([DateTime? atTime]) {
    final allChanges = _changes.entries
        .where((entry) => atTime != null ? entry.key.isBefore(atTime) : true)
        .map((e) => e.value)
        .fold(DiffNode([]), (node1, node2) => node1 + node2);
    return fromJson(allChanges.apply(_initial));
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
}

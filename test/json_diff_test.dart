import 'package:dart_triage_updater/statistics/json_comparison.dart';
import 'package:json_diff/json_diff.dart';
import 'package:test/test.dart';

void main() {
  final json1 = {
    'id123': {
      'labels': ['P0'],
      'updated_at': 12345,
      'created_at': 10000,
      'assignee': {'login': 'test123'}
    },
  };
  final json2 = {
    'id123': {
      'labels': ['type:bug', 'P1'],
      'updated_at': 12345,
      'created_at': 10000,
      'assignee': {'login': 'test123'}
    },
    'id234': {
      'labels': [],
      'updated_at': 12345,
      'created_at': 10000,
      'assignee': {'login': 'test123'}
    },
  };
  final left = {
    "a": 2,
    "b": 3,
    "c": 5,
    "d": {"x": 4, "y": 8}
  };
  final right = {
    "b": 7,
    "c": 5,
    "d": {"x": 4, "z": 16},
    "e": 11
  };
  test('Diff', () {
    checkDiff(json1, json2);
    checkDiff(left, right);
  });
}

void checkDiff(Map<String, dynamic> json1, Map<String, dynamic> json2) {
  final diff = JsonDiffer.fromJson(json1, json2).diff();
  expect(fromJson(diff.toJson()).toString(), diff.toString());
}

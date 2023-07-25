import 'dart:convert';

import 'package:dart_triage_updater/differ.dart';
import 'package:dart_triage_updater/issue_utils.dart';
import 'package:github/github.dart';
import 'package:json_diff/json_diff.dart';
import 'package:test/test.dart';

import 'dart_triage_updater_test.dart';

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
final jsonA = {
  "a": 2,
  "b": 3,
  "c": 5,
  "d": {"x": 4, "y": 8}
};
final jsonB = {
  "b": 7,
  "c": 5,
  "d": {"x": 4, "z": 16},
  "e": 11
};
void main() {
  test('Diff', () {
    checkDiff(json1, json2);
    checkDiff(jsonA, jsonB);
  });
  test('Add diffs', () {
    final diff1 = getDiff(jsonA, jsonB);
    final jsonC = Map<String, dynamic>.from(jsonB)..['c'] = 4;
    final diff2 = getDiff(jsonB, jsonC);
    // ignore: unnecessary_cast
    expect(diff1.apply(jsonA as Map<String, dynamic>), jsonB);
    // ignore: unnecessary_cast
    expect(diff2.apply(jsonB as Map<String, dynamic>), jsonC);
    final diff3 = diff1 + diff2;
    // ignore: unnecessary_cast
    expect(diff3.apply(jsonA as Map<String, dynamic>), jsonC);
  });

  test('Diff state', () {
    final i1 = Issue.fromJson(issue1);
    final i2 = Issue.fromJson(issue2);
    final oneToTwo = getDiffStr(i1, i2);
    final twoToClosed = getDiffStr(i1, i2.close());
    expect(oneToTwo.node['reactions']!.changed.values.first, [0, 2]);
    expect(twoToClosed.changed['state'], ['open', 'closed']);
  });
}

void checkDiff(Map<String, dynamic> json1, Map<String, dynamic> json2) {
  final diff = getDiff(json1, json2);
  expect(diffNodeFromJson(diff.toJson()).toString(), diff.toString());
}

DiffNode getDiff(Map<String, dynamic> json1, Map<String, dynamic> json2) =>
    JsonDiffer.fromJson(json1, json2).diff();

DiffNode getDiffStr(s, t) => JsonDiffer(jsonEncode(s), jsonEncode(t)).diff();

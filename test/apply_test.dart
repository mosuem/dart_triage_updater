import 'package:dart_triage_updater/differ.dart';
import 'package:json_diff/json_diff.dart';
import 'package:test/test.dart';

import 'dart_triage_updater_test.dart';
import 'diff_test.dart';

void main() {
  test('Diff List', () {
    change([], []);
    change([], ['a']);
    change([], ['a', 'b']);
    change([], ['a', 'b', 'c']);
    change(['a', 'b'], ['a', 'b', 'c']);
    change(['a', 'b'], ['a', 'c']);
    change(['a', 'b'], ['c']);
    change(
      [
        'a',
        ['b', 'c']
      ],
      [
        'a',
        ['b']
      ],
    );
  });
  test('Diff Map', () {
    change(<String, dynamic>{}, <String, dynamic>{'a': 1});
    change(<String, dynamic>{}, <String, dynamic>{'a': 1, 'b': 2});
    change(<String, dynamic>{'a': 1, 'b': 2}, <String, dynamic>{'a': 1});
  });

  test('Diff complex', () {
    change(jsonA, jsonB);
    change(issue1, issue2);
  });
}

void change(Object o, Object t) {
  final diff = JsonDiffer.fromJson(o, t).diff();
  expect(diff.apply(o), t);
}

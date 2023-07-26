import 'dart:convert';

import 'package:dart_triage_updater/data_diff.dart';
import 'package:dart_triage_updater/issue_utils.dart';
import 'package:github/github.dart';
import 'package:json_diff/json_diff.dart';
import 'package:test/test.dart';

import 'dart_triage_updater_test.dart';

void main() {
  test('Show upvotes over time', () {
    final dataDiff = DataDiff(
      jsonDecode(jsonEncode(issue1)),
      {
        DateTime.fromMillisecondsSinceEpoch(0): DiffNode([]),
        DateTime.fromMillisecondsSinceEpoch(5): getDiff(issue1, issue2),
        DateTime.fromMillisecondsSinceEpoch(10): getDiff(issue2, issue3),
      },
      Issue.fromJson,
    );
    final timeSeries = dataDiff.getTimeSeries((issue) => issue.upvotes);
    expect(
      timeSeries,
      {
        DateTime.fromMillisecondsSinceEpoch(0): 0,
        DateTime.fromMillisecondsSinceEpoch(5): 2,
        DateTime.fromMillisecondsSinceEpoch(10): 1,
      },
    );
  });
}

DiffNode getDiff(Issue i1, Issue i2) =>
    JsonDiffer(jsonEncode(i1), jsonEncode(i2)).diff();

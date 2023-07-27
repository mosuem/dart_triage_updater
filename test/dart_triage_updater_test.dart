import 'dart:convert';

import 'package:dart_triage_updater/firebase_database.dart';
import 'package:dart_triage_updater/update_type.dart';
import 'package:github/github.dart';
import 'package:test/test.dart';

void main() {
  final name = 'test_package';
  final databaseReference =
      DatabaseReference(UpdateType.testType, RepositorySlug('dart-lang', name));
  test('addData', () async {
    await databaseReference.addData(
      jsonEncode({
        1234.toString(): {'prName': 'Name of PR'}
      }),
      'data',
    );
  });
  test('addGooglers', () async {
    await DatabaseReference.saveGooglers(jsonEncode(['test1', 'test2']));
  });
  test('set and get last updated', () async {
    await DatabaseReference.setLastUpdated(UpdateType.testType);
    final dateTime =
        await DatabaseReference.getLastUpdated(UpdateType.testType);
    expect(
      dateTime!.millisecondsSinceEpoch,
      closeTo(DateTime.now().millisecondsSinceEpoch,
          Duration(seconds: 1).inMilliseconds),
    );
  });
  test('Get numbers', () async {
    final numbers = await DatabaseReference(
            UpdateType.issues, RepositorySlug('dart-lang', 'api.dart.dev'))
        .getIssueNumbers();
    expect(numbers, isNotEmpty);
  });
}

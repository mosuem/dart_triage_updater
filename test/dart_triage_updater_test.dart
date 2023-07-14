import 'dart:convert';

import 'package:dart_triage_updater/firebase_database.dart';
import 'package:dart_triage_updater/update_type.dart';
import 'package:github/github.dart';
import 'package:test/test.dart';

void main() {
  final dateTime = DateTime(2010, 12, 24);
  final name = 'test_package';
  final databaseReference =
      DatabaseReference(UpdateType.testType, RepositorySlug('dart-lang', name));
  test('getLastUpdated + setLastUpdated', () async {
    await databaseReference.setLastUpdated(dateTime);
    await Future.delayed(Duration(seconds: 1));
    final lastUpdated = await databaseReference.getLastUpdated();
    expect(
      lastUpdated.millisecondsSinceEpoch,
      dateTime.millisecondsSinceEpoch,
    );
  });
  test('addData', () async {
    await databaseReference.addData(
      jsonEncode({
        1234.toString(): jsonEncode({'prName': 'Name of PR'})
      }),
    );
    await databaseReference.deleteAllData();
  });
  test('addGooglers', () async {
    await DatabaseReference.saveGooglers(jsonEncode(['test1', 'test2']));
  });
}

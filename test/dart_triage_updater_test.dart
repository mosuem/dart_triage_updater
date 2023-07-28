import 'dart:convert';

import 'package:dart_triage_updater/firebase_database.dart';
import 'package:dart_triage_updater/pull_request_utils.dart';
import 'package:dart_triage_updater/update_type.dart';
import 'package:github/github.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  final ref = DatabaseReference(UpdateType.testType);
  test('addData', () async {
    final issue = Issue(
      id: 1234,
      createdAt: DateTime.now(),
    );
    final issue2 = Issue(
      id: 2345,
      createdAt: DateTime.now(),
    );
    await ref.addData(jsonEncode({issue.id.toString(): issue}), 'data');
    await ref.addData(jsonEncode({issue2.id.toString(): issue2}), 'data');
  });
  test(
    'addGooglers',
    () async {
      await DatabaseReference.saveGooglers(
          [User(login: 'test1'), User(login: 'test2')]);
    },
    skip: true,
  );
  test('set and get last updated', () async {
    await DatabaseReference(UpdateType.testType).setLastUpdated();
    final dateTime =
        await DatabaseReference(UpdateType.testType).getLastUpdated();
    expect(
      dateTime!.millisecondsSinceEpoch,
      closeTo(DateTime.now().millisecondsSinceEpoch,
          Duration(seconds: 1).inMilliseconds),
    );
  });

  test(
    'Decode data',
    () async {
      final uri =
          Uri.parse('$firebaseUrl${UpdateType.testType.name}/data.json');
      final response = await http.get(uri);
      final extractDataFrom = DatabaseReference.extractDataFrom(
          jsonDecode(response.body), Issue.fromJson);
      expect(extractDataFrom, isNotEmpty);
    },
  );
}

import 'dart:convert';

import 'package:dart_triage_updater/firebase_database.dart';
import 'package:dart_triage_updater/pull_request_utils.dart';
import 'package:dart_triage_updater/update_type.dart';
import 'package:github/github.dart';
import 'package:http/http.dart' as http;
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
    await DatabaseReference.saveGooglers(
        [User(login: 'test1'), User(login: 'test2')]);
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

  test('Decode data', () async {
    final slug = RepositorySlug('dart-lang', 'coverage');
    final uri =
        Uri.parse('${firebaseUrl}pullrequests/data/${slug.toUrl()}.json');
    final response = await http.get(uri);
    final extractDataFrom = DatabaseReference.extractDataFrom(
      {slug.toUrl(): jsonDecode(response.body)},
      decodePR,
    );
    expect(extractDataFrom, isNotEmpty);
  });
}

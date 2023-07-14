import 'dart:convert';

import 'package:dart_triage_updater/update_type.dart';
import 'package:github/github.dart';
import 'package:http/http.dart' as http;

final firebaseUrl =
    'https://dart-pr-dashboard-default-rtdb.europe-west1.firebasedatabase.app/';

class DatabaseReference {
  final UpdateType type;
  final RepositorySlug slug;

  DatabaseReference(this.type, this.slug);

  Future<DateTime> getLastUpdated() async {
    final uri =
        Uri.parse('$firebaseUrl${type.name}/last_updated/${slug.toUrl()}.json');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(response.body) ?? 0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<void> setLastUpdated(DateTime dateTime) async {
    final uri = Uri.parse('$firebaseUrl${type.name}/last_updated.json');
    final body = jsonEncode({slug.toUrl(): dateTime.millisecondsSinceEpoch});
    final response = await http.patch(
      uri,
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception(
          'Error setting last_updated for ${slug.fullName} in $type $body: ${response.body}');
    }
  }

  Future<void> deleteAllData() async {
    final uri = Uri.parse('$firebaseUrl${type.name}/data/${slug.toUrl()}.json');
    final response = await http.delete(uri);
    if (response.statusCode != 200) {
      throw Exception(
          'Error delete data for ${slug.fullName} in $type: ${response.body}');
    }
  }

  Future<void> addData(String data) async {
    final uri = Uri.parse('$firebaseUrl${type.name}/data/${slug.toUrl()}.json');
    final response = await http.patch(uri, body: data);
    if (response.statusCode != 200) {
      throw Exception(
          'Error delete data for ${slug.fullName} in $type: ${response.body}');
    }
  }

  static Future<void> saveGooglers(String googlers) async {
    final uri = Uri.parse('$firebaseUrl.json');
    final response =
        await http.patch(uri, body: jsonEncode({'googlers': googlers}));
    if (response.statusCode != 200) {
      throw Exception('Error adding Googlers ${response.body}');
    }
  }
}

extension on RepositorySlug {
  String toUrl() {
    final ownerClean = owner.replaceAll(r'.', r',');
    final nameClean = name.replaceAll(r'.', r',');
    return '$ownerClean:$nameClean';
  }
}

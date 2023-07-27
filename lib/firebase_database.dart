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

  Future<void> addData(String data, String dataType) async {
    final uri =
        Uri.parse('$firebaseUrl${type.name}/$dataType/${slug.toUrl()}.json');
    final response = await http.patch(uri, body: data);
    if (response.statusCode != 200) {
      throw Exception(
          'Error adding data $data for ${slug.fullName} in $type: ${response.body}');
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

  static setLastUpdated(UpdateType type) async {
    final uri = Uri.parse('${firebaseUrl}last_updated.json');
    final response = await http.patch(uri,
        body: jsonEncode({type.name: DateTime.now().millisecondsSinceEpoch}));
    if (response.statusCode != 200) {
      throw Exception('Error adding Googlers ${response.body}');
    }
  }

  static Future<DateTime?> getLastUpdated(UpdateType type) async {
    final uri = Uri.parse('${firebaseUrl}last_updated.json');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Error adding Googlers ${response.body}');
    }
    return DateTime.fromMillisecondsSinceEpoch(
        jsonDecode(response.body)[type.name]);
  }

  Future<List<int>> getIssueNumbers() async {
    final uri = Uri.parse('$firebaseUrl${type.name}/data/${slug.toUrl()}.json');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Error adding Googlers ${response.body}');
    }
    final jsonDecode2 = jsonDecode(response.body) as Map;
    return jsonDecode2.values.map((e) => e['number'] as int).toList();
  }
}

extension on RepositorySlug {
  String toUrl() {
    final ownerClean = owner.replaceAll(r'.', r',');
    final nameClean = name.replaceAll(r'.', r',');
    return '$ownerClean:$nameClean';
  }
}

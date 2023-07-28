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

  static Future<void> saveGooglers(List googlers) async {
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

  static Map<RepositorySlug, List<T>> extractDataFrom<T>(
    Map<String, dynamic> reposToIds,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final map = <RepositorySlug, List<T>>{};
    for (final repoToIds in reposToIds.entries) {
      final slug = RepositorySlugExtension.fromUrl(repoToIds.key);
      final idsToData = repoToIds.value as Map<String, dynamic>;

      final list = <T>[];
      for (final idToData in idsToData.entries) {
        // ignore: unused_local_variable
        final id = idToData.key;
        final data = fromJson(idToData.value);
        list.add(data);
      }

      map[slug] = list;
    }
    return map;
  }
}

extension RepositorySlugExtension on RepositorySlug {
  String toUrl() {
    final ownerClean = owner.replaceAll(r'.', r',');
    final nameClean = name.replaceAll(r'.', r',');
    return '$ownerClean:$nameClean';
  }

  static RepositorySlug fromUrl(String url) {
    final split = url.split(':');
    final owner = split[0];
    final name = split[1];
    return RepositorySlug(
        owner.replaceAll(r',', r'.'), name.replaceAll(r',', r'.'));
  }
}

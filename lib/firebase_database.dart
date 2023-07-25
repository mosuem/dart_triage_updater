import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dart_triage_updater/differ.dart';
import 'package:dart_triage_updater/update_type.dart';
import 'package:github/github.dart';
import 'package:http/http.dart' as http;
import 'package:json_diff/json_diff.dart';

final firebaseUrl =
    'https://dart-pr-dashboard-default-rtdb.europe-west1.firebasedatabase.app/';

class DatabaseReference {
  final UpdateType type;
  final RepositorySlug slug;

  DatabaseReference(this.type, this.slug);

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

  static Future<Map<RepositorySlug, List<T>>> getData<T>(
    UpdateType type,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final uri = Uri.parse('${firebaseUrl}changes/${type.name}.json');

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Error getting data from $uri: ${response.body}');
    }
    final map = <RepositorySlug, List<T>>{};
    final allDataObj = jsonDecode(response.body) as Map<String, dynamic>;
    for (final entry in allDataObj.entries) {
      // ignore: unused_local_variable
      final id = entry.key;
      final value = entry.value as Map<String, dynamic>;
      Map<String, dynamic>? initial;
      final changes = <DiffNode>[];
      for (final entry in value
          .map((key, value) => MapEntry(
                DateTime.fromMillisecondsSinceEpoch(int.parse(key)),
                value,
              ))
          .entries
          .sorted((a, b) => a.key.compareTo(b.key))) {
        final value = entry.value as Map<String, dynamic>;
        if (value.containsKey('initial') && initial == null) {
          initial = jsonDecode(value['initial']);
        } else if (value.containsKey('diff')) {
          final value2 = value['diff'];
          changes.add(diffNodeFromJson(value2));
        } else {
          throw ArgumentError();
        }
      }
      final repoUrl = initial!['repository_url'] as String;
      final split = repoUrl.split(r'/');
      final repoSlug = split.skip(split.length - 2).join('/');

      final allChanges =
          changes.fold(DiffNode([]), (node1, node2) => node1 + node2);
      final allTogether = allChanges.apply(initial);

      final data = fromJson(allTogether);
      map.update(
        RepositorySlug.full(repoSlug),
        (value) {
          return [...value, data];
        },
        ifAbsent: () => [data],
      );
    }

    return map;
  }

  static Future<void> addChange(
    UpdateType type,
    String id,
    String? oldValue,
    String newValue,
  ) async {
    final uri = Uri.parse('${firebaseUrl}changes/${type.name}/$id.json');
    final diff = JsonDiffer(oldValue ?? '{}', newValue).diff();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final body = jsonEncode({
      timestamp: {
        if (oldValue == null) 'initial': newValue,
        if (oldValue != null) 'diff': diff.toJson(),
      }
    });
    final response = await http.patch(uri, body: body);
    if (response.statusCode != 200) {
      throw Exception('Error adding change ${response.body}');
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

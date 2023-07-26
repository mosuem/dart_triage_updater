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
    T Function(
      Map<String, dynamic> initial,
      Map<DateTime, DiffNode> changes,
    ) fromJson,
  ) async {
    final uri = Uri.parse('${firebaseUrl}changes/${type.name}.json');

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Error getting data from $uri: ${response.body}');
    }
    final map = <RepositorySlug, List<T>>{};
    final allDataObj = jsonDecode(response.body) ??
        // ignore: unnecessary_cast
        <String, dynamic>{} as Map<String, dynamic>;
    for (final entry in allDataObj.entries) {
      // ignore: unused_local_variable
      final id = entry.key;
      final value = entry.value as Map<String, dynamic>;
      Map<String, dynamic>? initial;
      final changes = <DateTime, DiffNode>{};
      for (final entry in value
          .map((key, value) => MapEntry(
                DateTime.fromMillisecondsSinceEpoch(int.parse(key)),
                value,
              ))
          .entries
          .sorted((a, b) => a.key.compareTo(b.key))) {
        final value = entry.value as Map<String, dynamic>;
        if (value.containsKey('initial') && initial == null) {
          initial = value['initial'];
          changes[entry.key] = DiffNode([]);
        } else if (value.containsKey('diff')) {
          final value2 = value['diff'];
          changes[entry.key] = diffNodeFromJson(value2);
        } else {
          throw ArgumentError();
        }
      }
      final repositorySlug = getSlugFromUrl(initial!);

      final data = fromJson(initial, changes);
      map.update(
        repositorySlug,
        (value) => [...value, data],
        ifAbsent: () => [data],
      );
    }

    return map;
  }

  static RepositorySlug getSlugFromUrl(Map<String, dynamic> initial) {
    if (initial['base']?['repo'] != null) {
      return Repository.fromJson(initial['base']?['repo']).slug();
    }
    final repoUrl = initial['repository_url'] as String;
    final split = repoUrl.split(r'/');
    final repoSlug2 = split.skip(split.length - 2).join('/');
    final repoSlug = repoSlug2;
    final repositorySlug = RepositorySlug.full(repoSlug);
    return repositorySlug;
  }

  static Future<void> addChange<S>(
    UpdateType type,
    String id,
    S? oldValue,
    S newValue,
  ) async {
    final uri = Uri.parse('${firebaseUrl}changes/${type.name}/$id.json');
    final nonNullOldValue = oldValue ?? <String, dynamic>{};
    final diff = JsonDiffer(
      jsonEncode(nonNullOldValue),
      jsonEncode(newValue),
    ).diff();
    if (!diff.isEmpty) {
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
}

extension on RepositorySlug {
  String toUrl() {
    final ownerClean = owner.replaceAll(r'.', r',');
    final nameClean = name.replaceAll(r'.', r',');
    return '$ownerClean:$nameClean';
  }
}

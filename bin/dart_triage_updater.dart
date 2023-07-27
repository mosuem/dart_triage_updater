import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_triage_updater/dart_triage_updater.dart';
import 'package:dart_triage_updater/update_type.dart';
import 'package:github/github.dart';

Future<void> main(List<String> arguments) async {
  final argParser = ArgParser()
    ..addMultiOption(
      'update',
      allowed: ['issues', 'pullrequests', 'googlers'],
      defaultsTo: ['issues', 'pullrequests', 'googlers'],
      help: 'Which types to update',
    )
    ..addOption('api-key')
    ..addFlag(
      'help',
      abbr: 'h',
      defaultsTo: false,
      negatable: false,
    );
  List<String> toUpdate;
  String? apikey;
  try {
    final parse = argParser.parse(arguments);
    if (parse['help']) {
      print(argParser.usage);
      exit(0);
    }
    toUpdate = parse['update'] as List<String>;
    apikey = parse['api-key'] as String?;
  } catch (e) {
    print(
        'Invalid arguments "$arguments" passed.\n\n Usage: ${argParser.usage}');
    exit(1);
  }
  var authentication = Authentication.anonymous();
  if (apikey != null) {
    authentication = Authentication.withToken(apikey);
  } else {
    final file = File('.env');
    if (file.existsSync()) {
      final token = file.readAsStringSync();
      authentication = Authentication.withToken(token);
    }
  }
  final github = GitHub(auth: authentication);
  final updateTypes = toUpdate
      .map((e) => UpdateType.values.firstWhere((type) => type.name == e))
      .toList();
  await TriageUpdater(github).updateThese(updateTypes);
}

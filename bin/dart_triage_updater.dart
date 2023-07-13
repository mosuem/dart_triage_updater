import 'package:args/args.dart';

/// Provides the `YouTubeApi` class.
import 'package:googleapis/firestore/v1.dart';

void main(List<String> arguments) {
  var argParser = ArgParser()
    ..addMultiOption(
      'update',
      allowed: ['issues', 'pullrequests', 'googlers'],
      defaultsTo: ['issues', 'pullrequests', 'googlers'],
      help: 'Which types to update',
    );
  try {
    var parse = argParser.parse(arguments);
    var toUpdate = parse['update'] as List<String>;
    Updater(toUpdate);
  } catch (e) {
    print(
        'Invalid arguments "$arguments" passed.\n\n Usage: ${argParser.usage}');
  }
}

class Updater {
  Updater(List<String> toUpdate);
}

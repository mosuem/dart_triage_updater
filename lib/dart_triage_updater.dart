import 'dart:async';
import 'dart:convert';

import 'package:github/github.dart';

import 'firebase_database.dart';
import 'issue_utils.dart';
import 'pull_request_utils.dart';
import 'repos.dart';
import 'update_type.dart';
import 'updater.dart';

Future<void> updateThese(List<UpdateType> updateTypes, GitHub github) async {
  final updater = Updater();
  updater.text.stream.listen((event) => print(event));
  if (updateTypes.contains(UpdateType.issues)) {
    await update(UpdateType.issues, github, updater, saveAllIssues);
  }
  if (updateTypes.contains(UpdateType.pullrequests)) {
    await update(UpdateType.pullrequests, github, updater, saveAllPullrequests);
  }
  if (updateTypes.contains(UpdateType.googlers)) {
    await updateGooglers(github, updater);
  }
}

Future<void> updateGooglers(GitHub github, Updater updater) async {
  updater.open('Fetch googlers');
  final googlersGoogle =
      await github.organizations.listUsers('google').toList();
  updater.set('Fetched ${googlersGoogle.length} googlers from "google"');
  final googlersDart =
      await github.organizations.listUsers('dart-lang').toList();
  updater.set('Fetched ${googlersDart.length} googlers from "dart-lang"');
  final googlers = (googlersGoogle + googlersDart).toSet().toList();
  updater.set('Store googlers in database');
  final jsonEncode2 = jsonEncode(googlers);
  await DatabaseReference.saveGooglers(jsonEncode2);
  updater.set('Done!');
  updater.close();
}

Future<void> update(
  UpdateType type,
  GitHub github,
  Updater updater,
  Future<void> Function(GitHub, RepositorySlug, DatabaseReference, Updater)
      saveToDatabase,
) async {
  final dateTime = DateTime.now();

  updater.status.add(true);

  final repositories =
      github.repositories.listOrganizationRepositories('dart-lang');
  final dartLangRepos = await repositories
      .where((repository) => !repository.archived)
      .map((repository) => repository.slug())
      .where((slug) => !exludeRepos.contains(slug))
      .toList();
  for (final slug in [...dartLangRepos, ...includeRepos]) {
    try {
      final ref = DatabaseReference(type, slug);
      final lastUpdated = await ref.getLastUpdated();
      final daysSinceUpdate = DateTime.now().difference(lastUpdated).inDays;
      if (daysSinceUpdate > -1) {
        ref.setLastUpdated(dateTime);
        final status =
            'Get $type for ${slug.fullName} with ${github.rateLimitRemaining} '
            'remaining requests';
        ref.deleteAllData();

        updater.set(status);
        await saveToDatabase(github, slug, ref, updater);
      } else {
        final status =
            'Not updating ${slug.fullName} has been updated $daysSinceUpdate '
            'days ago';
        updater.set(status);
      }
    } catch (e) {
      updater.set(e.toString());
    }
  }

  updater.close();
}

Future<void> saveAllPullrequests(
  GitHub github,
  RepositorySlug slug,
  DatabaseReference ref,
  Updater updater,
) async {
  await github.pullRequests.list(slug, pages: 1000).forEach((pr) async {
    final list = await getReviewers(github, slug, pr);
    pr.reviewers = list;
    await addPullRequestToDatabase(pr, ref, updater.text.sink);
  });
}

Future<List<User>> getReviewers(
  GitHub github,
  RepositorySlug slug,
  PullRequest pr,
) async {
  final reviewers = await github.pullRequests
      .listReviews(slug, pr.number!)
      .map((prReview) => prReview.user)
      .toList();
  // Deduplicate reviewers
  final uniqueNames = reviewers.map((e) => e.login).whereType<String>().toSet();
  reviewers.retainWhere((reviewer) => uniqueNames.remove(reviewer.login));
  return reviewers;
}

Future<void> saveAllIssues(
  GitHub github,
  RepositorySlug slug,
  DatabaseReference ref,
  Updater updater,
) async {
  await github.issues.listByRepo(slug, perPage: 1000).forEach((pr) async {
    if (pr.pullRequest == null) {
      await addIssueToDatabase(pr, ref, updater.text.sink);
    }
  });
}

Future<void> addPullRequestToDatabase(
  PullRequest pr,
  DatabaseReference ref, [
  StreamSink<String?>? logger,
]) async {
  logger?.add('\tHandle PR ${pr.id} from ${pr.base!.repo!.slug().fullName}');
  final jsonEncode2 = jsonEncode({pr.id!.toString(): encodePR(pr)});
  return await ref.addData(jsonEncode2);
}

Future<void> addIssueToDatabase(
  Issue issue,
  DatabaseReference ref, [
  StreamSink<String?>? logger,
]) async {
  logger?.add(
      '\tHandle Issue ${issue.id} from ${issue.repositoryUrl?.substring('https://api.github.com/repos/'.length)}');
  return await ref
      .addData(jsonEncode({issue.id.toString(): encodeIssue(issue)}));
}

import 'dart:async';
import 'dart:convert';

import 'package:github/github.dart';

import 'firebase_database.dart';
import 'pull_request_utils.dart';
import 'repos.dart';
import 'update_type.dart';

class TriageUpdater {
  final GitHub github;
  late Map<UpdateType, DateTime?> lastUpdated;
  final updater = (StreamController<String>()..stream.listen(print)).sink;

  TriageUpdater(this.github);

  Future<void> updateThese(List<UpdateType> updateTypes) async {
    lastUpdated = Map.fromEntries(await Future.wait(updateTypes.map(
        (e) async => MapEntry(e, await DatabaseReference.setLastUpdated(e)))));

    if (updateTypes.contains(UpdateType.issues)) {
      await update(saveIssues);
    }
    if (updateTypes.contains(UpdateType.pullrequests)) {
      await update(savePullRequests);
    }
    if (updateTypes.contains(UpdateType.googlers)) {
      await updateGooglers(github);
    }

    for (final type in updateTypes) {
      await DatabaseReference.setLastUpdated(type);
    }
  }

  Future<void> updateGooglers(GitHub github) async {
    updater.add('Fetch googlers');
    final googlersGoogle =
        await github.organizations.listUsers('google').toList();
    updater.add('Fetched ${googlersGoogle.length} googlers from "google"');
    final googlersDart =
        await github.organizations.listUsers('dart-lang').toList();
    updater.add('Fetched ${googlersDart.length} googlers from "dart-lang"');
    final googlers = (googlersGoogle + googlersDart).toSet().toList();
    updater.add('Store googlers in database');
    await DatabaseReference.saveGooglers(googlers);
    updater.add('Done!');
    updater.close();
  }

  Future<void> update(
    Future<void> Function(RepositorySlug) saveToDatabase,
  ) async {
    final repositories =
        github.repositories.listOrganizationRepositories('dart-lang');
    final dartLangRepos = await repositories
        .where((repository) => !repository.archived)
        .map((repository) => repository.slug())
        .where((slug) => !exludeRepos.contains(slug))
        .toList()
      ..shuffle();
    final repos = [...dartLangRepos, ...includeRepos];
    for (var i = 0; i < repos.length; i++) {
      final slug = repos[i];
      try {
        updater.add(
            'Get data for ${slug.fullName} with ${github.rateLimitRemaining} '
            'remaining requests, repo $i/${repos.length}');
        await saveToDatabase(slug);
      } catch (e) {
        updater.add(e.toString());
      }
    }

    updater.close();
  }

  Future<void> savePullRequests(RepositorySlug slug) async {
    final ref = DatabaseReference(UpdateType.pullrequests, slug);
    final pullrequests =
        await github.pullRequests.list(ref.slug, pages: 1000).toList();
    await wait();
    for (final pr in pullrequests) {
      updater.add('\tHandle  PR ${pr.number!} from ${ref.slug.fullName}');
      final list = await getReviewers(ref.slug, pr);
      pr.reviewers = list;
      try {
        final timeline =
            await github.issues.listTimeline(ref.slug, pr.number!).toList();
        await wait();
        updater.add(
            '\tHandle timeline of PR ${pr.number!} from ${ref.slug.fullName} with length ${timeline.length}');
        await ref.addData(
            jsonEncode({pr.id!.toString(): timeline}), 'timeline');
      } catch (e) {
        updater.add('Error when getting timeline');
      }
      await ref.addData(jsonEncode({pr.id!.toString(): encodePR(pr)}), 'data');
    }
  }

  Future<List<User>> getReviewers(RepositorySlug slug, PullRequest pr) async {
    final reviewers = await github.pullRequests
        .listReviews(slug, pr.number!)
        .map((prReview) => prReview.user)
        .toList();
    await wait();
    // Deduplicate reviewers
    final uniqueNames =
        reviewers.map((e) => e.login).whereType<String>().toSet();
    reviewers.retainWhere((reviewer) => uniqueNames.remove(reviewer.login));
    return reviewers;
  }

  Future<void> saveIssues(RepositorySlug slug) async {
    final ref = DatabaseReference(UpdateType.issues, slug);
    final issues = await github.issues
        .listByRepo(
          ref.slug,
          perPage: 5000,
          state: 'all',
          since: lastUpdated[UpdateType.issues],
        )
        .toList();
    await wait();
    for (final issue in issues) {
      if (issue.pullRequest == null) {
        try {
          final timeline =
              await github.issues.listTimeline(ref.slug, issue.number).toList();
          await wait();
          updater.add(
              '\tHandle timeline of issue ${issue.number} from ${ref.slug.fullName} with length ${timeline.length}');
          await ref.addData(
              jsonEncode({issue.id.toString(): timeline}), 'timeline');
        } catch (e) {
          updater.add('Error when getting timeline');
        }
        await ref.addData(jsonEncode({issue.id.toString(): issue}), 'data');
      }
    }
  }

  Future<void> wait() async =>
      await Future.delayed(Duration(milliseconds: 400));
}

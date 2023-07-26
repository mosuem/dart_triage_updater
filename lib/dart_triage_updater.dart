import 'dart:async';
import 'dart:convert';

import 'package:dart_triage_updater/data_diff.dart';
import 'package:github/github.dart';

import 'firebase_database.dart';
import 'issue_utils.dart';
import 'pull_request_utils.dart';
import 'repos.dart';
import 'update_type.dart';
import 'updater.dart';

class TriageUpdater {
  final GitHub github;
  final Updater updater;

  TriageUpdater(this.github) : updater = Updater();

  Future<void> updateThese(List<UpdateType> updateTypes) async {
    updater.text.stream.listen((event) => print(event));
    if (updateTypes.contains(UpdateType.issues)) {
      final issuesByRepo = await DatabaseReference.getData(
        UpdateType.issues,
        (initial, changes) =>
            DataDiff(initial, changes, Issue.fromJson).applied,
      );
      await update(
        UpdateType.issues,
        saveAllIssues,
        issuesByRepo,
      );
    }
    if (updateTypes.contains(UpdateType.pullrequests)) {
      final pullrequestsByRepo = await DatabaseReference.getData(
        UpdateType.pullrequests,
        (initial, changes) =>
            DataDiff(initial, changes, PullRequest.fromJson).applied,
      );
      await update(
        UpdateType.pullrequests,
        saveAllPullrequests,
        pullrequestsByRepo,
      );
    }
    if (updateTypes.contains(UpdateType.googlers)) {
      await updateGooglers();
    }
  }

  Future<void> updateGooglers() async {
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

  Future<void> update<T>(
    UpdateType type,
    Future<void> Function(
      RepositorySlug,
      DatabaseReference,
      List<T>,
    ) saveToDatabase,
    Map<RepositorySlug, List<T>> items,
  ) async {
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
        final status =
            'Get $type for ${slug.fullName} with ${github.rateLimitRemaining} '
            'remaining requests';

        updater.set(status);
        await saveToDatabase(slug, ref, items[slug] ?? []);
      } catch (e) {
        updater.set(e.toString());
      }
    }

    updater.close();
  }

  Future<void> saveAllPullrequests(
    RepositorySlug slug,
    DatabaseReference ref,
    List<PullRequest> pullrequests,
  ) async {
    await github.pullRequests
        .list(slug, pages: 1000)
        .forEach((pullrequest) async {
      final oldPullrequest =
          pullrequests.where((pr) => pr.id == pullrequest.id).firstOrNull;
      final reviewers = await getReviewers(github, slug, pullrequest);
      pullrequest.reviewers = reviewers;
      await DatabaseReference.addChange(
        UpdateType.pullrequests,
        pullrequest.id.toString(),
        json.encode(oldPullrequest),
        jsonEncode(pullrequest),
      );
    });
    for (final remainingPr in pullrequests) {
      await DatabaseReference.addChange(
        UpdateType.issues,
        remainingPr.id.toString(),
        json.encode(remainingPr),
        jsonEncode(remainingPr.close()),
      );
    }
  }

  Future<void> saveAllIssues(
    RepositorySlug slug,
    DatabaseReference ref,
    List<Issue> issues,
  ) async {
    await github.issues.listByRepo(slug, perPage: 1000).forEach((issue) async {
      final oldIssue =
          issues.where((element) => element.id == issue.id).firstOrNull;
      await DatabaseReference.addChange(
        UpdateType.issues,
        issue.id.toString(),
        json.encode(oldIssue),
        jsonEncode(issue),
      );
      if (oldIssue != null) issues.remove(oldIssue);
    });
    for (final remainingIssue in issues) {
      await DatabaseReference.addChange(
        UpdateType.issues,
        remainingIssue.id.toString(),
        json.encode(remainingIssue),
        jsonEncode(remainingIssue.close()),
      );
    }
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
    final uniqueNames =
        reviewers.map((e) => e.login).whereType<String>().toSet();
    reviewers.retainWhere((reviewer) => uniqueNames.remove(reviewer.login));
    return reviewers;
  }
}

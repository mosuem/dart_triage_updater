import 'dart:convert';

import 'package:github/github.dart';

extension ReviewerAddition on PullRequest {
  static final _values = Expando<List<User>>();

  List<User>? get reviewers => _values[this];
  set reviewers(List<User>? r) => _values[this] = r;

  String get titleDisplay {
    return draft == true ? '$title [draft]' : title ?? '';
  }

  String? get authorAssociationDisplay {
    if (authorAssociation == null || authorAssociation == 'NONE') return null;
    return authorAssociation!.toLowerCase();
  }

  List<User> get allReviewers =>
      {...?reviewers, ...?requestedReviewers}.toList();

  bool authorIsGoogler(Set<String> googlers) => googlers.contains(user?.login);

  bool get authorIsCopybara => user?.login == 'copybara-service[bot]';

  String encode() {
    final jsonEncode2 = jsonEncode({
      'pr': this,
      'reviewers': reviewers,
    });
    return jsonEncode2;
  }

  PullRequest close() {
    final pullRequest = PullRequest(
      id: id,
      nodeId: nodeId,
      htmlUrl: htmlUrl,
      diffUrl: diffUrl,
      patchUrl: patchUrl,
      number: number,
      state: 'closed',
      title: title,
      body: body,
      createdAt: createdAt,
      updatedAt: updatedAt,
      closedAt: DateTime.now(),
      mergedAt: mergedAt,
      head: head,
      base: base,
      user: user,
      draft: draft,
      mergeCommitSha: mergeCommitSha,
      merged: merged,
      mergeable: mergeable,
      mergedBy: mergedBy,
      commentsCount: commentsCount,
      commitsCount: commitsCount,
      additionsCount: additionsCount,
      deletionsCount: deletionsCount,
      changedFilesCount: changedFilesCount,
      labels: labels,
      requestedReviewers: requestedReviewers,
      reviewCommentCount: reviewCommentCount,
      milestone: milestone,
      rebaseable: rebaseable,
      mergeableState: mergeableState,
      maintainerCanModify: maintainerCanModify,
      authorAssociation: authorAssociation,
    );
    pullRequest.reviewers = reviewers;
    return pullRequest;
  }
}

PullRequest decodePR(String json) {
  final Map<String, dynamic> decoded = jsonDecode(json);
  final decodedPR = decoded['pr'] as Map<String, dynamic>;
  final decodedReviewers = decoded['reviewers'] as List;
  final pr = PullRequest.fromJson(decodedPR);
  pr.reviewers = decodedReviewers.map((e) => User.fromJson(e)).toList();
  pr.requestedReviewers?.removeWhere((user) =>
      pr.reviewers?.any((reviewer) => reviewer.login == user.login) ?? false);
  return pr;
}

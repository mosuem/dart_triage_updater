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

  PullRequest copyWith({
    int? id,
    String? nodeId,
    String? htmlUrl,
    String? diffUrl,
    String? patchUrl,
    int? number,
    String? state,
    String? title,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? closedAt,
    DateTime? mergedAt,
    PullRequestHead? head,
    PullRequestHead? base,
    User? user,
    bool? draft,
    String? mergeCommitSha,
    bool? merged,
    bool? mergeable,
    User? mergedBy,
    int? commentsCount,
    int? commitsCount,
    int? additionsCount,
    int? deletionsCount,
    int? changedFilesCount,
    List<IssueLabel>? labels,
    List<User>? requestedReviewers,
    int? reviewCommentCount,
    Milestone? milestone,
    bool? rebaseable,
    String? mergeableState,
    bool? maintainerCanModify,
    String? authorAssociation,
    List<User>? reviewers,
  }) {
    return PullRequest(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      htmlUrl: htmlUrl ?? this.htmlUrl,
      diffUrl: diffUrl ?? this.diffUrl,
      patchUrl: patchUrl ?? this.patchUrl,
      number: number ?? this.number,
      state: state ?? this.state,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      closedAt: closedAt ?? this.closedAt,
      mergedAt: mergedAt ?? this.mergedAt,
      head: head ?? this.head,
      base: base ?? this.base,
      user: user ?? this.user,
      draft: draft ?? this.draft,
      mergeCommitSha: mergeCommitSha ?? this.mergeCommitSha,
      merged: merged ?? this.merged,
      mergeable: mergeable ?? this.mergeable,
      mergedBy: mergedBy ?? this.mergedBy,
      commentsCount: commentsCount ?? this.commentsCount,
      commitsCount: commitsCount ?? this.commitsCount,
      additionsCount: additionsCount ?? this.additionsCount,
      deletionsCount: deletionsCount ?? this.deletionsCount,
      changedFilesCount: changedFilesCount ?? this.changedFilesCount,
      labels: labels ?? this.labels,
      requestedReviewers: requestedReviewers ?? this.requestedReviewers,
      reviewCommentCount: reviewCommentCount ?? this.reviewCommentCount,
      milestone: milestone ?? this.milestone,
      rebaseable: rebaseable ?? this.rebaseable,
      mergeableState: mergeableState ?? this.mergeableState,
      maintainerCanModify: maintainerCanModify ?? this.maintainerCanModify,
      authorAssociation: authorAssociation ?? this.authorAssociation,
    )..reviewers = reviewers ?? this.reviewers;
  }

  PullRequest close() => copyWith(state: 'closed', closedAt: DateTime.now());
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

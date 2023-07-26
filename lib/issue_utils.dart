import 'dart:convert';

import 'package:github/github.dart';

Issue decodeIssue(String json) {
  final Map<String, dynamic> decoded = jsonDecode(json);
  final decodedIssue = decoded['issue'] as Map<String, dynamic>;
  return Issue.fromJson(decodedIssue);
}

String encodeIssue(Issue pr) {
  return jsonEncode({'issue': pr});
}

String? getMatch(Issue issue, String columnName, List<User> googlers) {
  switch (columnName) {
    case 'title':
      return issue.title;
    default:
      return null;
  }
}

extension IssueUtils on Issue {
  int get upvotes {
    return (reactions?.heart ?? 0) +
        (reactions?.plusOne ?? 0) -
        (reactions?.minusOne ?? 0);
  }

  bool authorIsGoogler(Set<String> googlers) => googlers.contains(user?.login);

  Issue copyWith({
    int? id,
    String? url,
    String? htmlUrl,
    int? number,
    String? state,
    String? title,
    User? user,
    List<IssueLabel>? labels,
    User? assignee,
    List<User>? assignees,
    Milestone? milestone,
    int? commentsCount,
    IssuePullRequest? pullRequest,
    DateTime? createdAt,
    DateTime? closedAt,
    DateTime? updatedAt,
    String? body,
    User? closedBy,
    String? activeLockReason,
    String? authorAssociation,
    String? bodyHtml,
    String? bodyText,
    String? commentsUrl,
    bool? draft,
    String? eventsUrl,
    String? labelsUrl,
    bool? locked,
    String? nodeId,
    GitHubApp? performedViaGithubApp,
    ReactionRollup? reactions,
    Repository? repository,
    String? repositoryUrl,
    String? stateReason,
    String? timelineUrl,
  }) {
    return Issue(
      id: id ?? this.id,
      url: url ?? this.url,
      htmlUrl: htmlUrl ?? this.htmlUrl,
      number: number ?? this.number,
      state: state ?? this.state,
      title: title ?? this.title,
      user: user ?? this.user,
      labels: labels ?? this.labels,
      assignee: assignee ?? this.assignee,
      assignees: assignees ?? this.assignees,
      milestone: milestone ?? this.milestone,
      commentsCount: commentsCount ?? this.commentsCount,
      pullRequest: pullRequest ?? this.pullRequest,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      body: body ?? this.body,
      closedBy: closedBy ?? this.closedBy,
      activeLockReason: activeLockReason ?? this.activeLockReason,
      authorAssociation: authorAssociation ?? this.authorAssociation,
      bodyHtml: bodyHtml ?? this.bodyHtml,
      bodyText: bodyText ?? this.bodyText,
      commentsUrl: commentsUrl ?? this.commentsUrl,
      draft: draft ?? this.draft,
      eventsUrl: eventsUrl ?? this.eventsUrl,
      labelsUrl: labelsUrl ?? this.labelsUrl,
      locked: locked ?? this.locked,
      nodeId: nodeId ?? this.nodeId,
      performedViaGithubApp:
          performedViaGithubApp ?? this.performedViaGithubApp,
      reactions: reactions ?? this.reactions,
      repository: repository ?? this.repository,
      repositoryUrl: repositoryUrl ?? this.repositoryUrl,
      stateReason: stateReason ?? this.stateReason,
      timelineUrl: timelineUrl ?? this.timelineUrl,
    );
  }

  Issue close() => copyWith(state: 'closed', closedAt: DateTime.now());
}

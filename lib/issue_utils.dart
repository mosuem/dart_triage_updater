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

  Issue close() {
    return Issue(
      id: id,
      url: url,
      htmlUrl: htmlUrl,
      number: number,
      state: 'closed',
      title: title,
      user: user,
      labels: labels,
      assignee: assignee,
      assignees: assignees,
      milestone: milestone,
      commentsCount: commentsCount,
      pullRequest: pullRequest,
      createdAt: createdAt,
      closedAt: DateTime.now(),
      updatedAt: updatedAt,
      body: body,
      closedBy: closedBy,
      activeLockReason: activeLockReason,
      authorAssociation: authorAssociation,
      bodyHtml: bodyHtml,
      bodyText: bodyText,
      commentsUrl: commentsUrl,
      draft: draft,
      eventsUrl: eventsUrl,
      labelsUrl: labelsUrl,
      locked: locked,
      nodeId: nodeId,
      performedViaGithubApp: performedViaGithubApp,
      reactions: reactions,
      repository: repository,
      repositoryUrl: repositoryUrl,
      stateReason: stateReason,
      timelineUrl: timelineUrl,
    );
  }
}

import 'dart:convert';

import 'package:dart_triage_updater/firebase_database.dart';
import 'package:dart_triage_updater/issue_utils.dart';
import 'package:dart_triage_updater/update_type.dart';
import 'package:github/github.dart';
import 'package:test/test.dart';

final issue1 = {
  "id": 22498210,
  "url": "https://api.github.com/repos/dart-lang/api.dart.dev/issues/19",
  "html_url": "https://github.com/dart-lang/api.dart.dev/issues/19",
  "number": 19,
  "state": "open",
  "title": "Need a 404 page",
  "user": {
    "login": "sethladd",
    "id": 5479,
    "avatar_url": "https://avatars.githubusercontent.com/u/5479?v=4",
    "html_url": "https://github.com/sethladd",
    "site_admin": false,
    "name": null,
    "company": null,
    "blog": null,
    "location": null,
    "email": null,
    "hirable": null,
    "bio": null,
    "public_repos": null,
    "public_gists": null,
    "followers": null,
    "following": null,
    "created_at": null,
    "updated_at": null,
    "twitter_username": null,
    "events_url": "https://api.github.com/users/sethladd/events{/privacy}",
    "followers_url": "https://api.github.com/users/sethladd/followers",
    "following_url":
        "https://api.github.com/users/sethladd/following{/other_user}",
    "gists_url": "https://api.github.com/users/sethladd/gists{/gist_id}",
    "gravatar_id": "",
    "node_id": "MDQ6VXNlcjU0Nzk=",
    "organizations_url": "https://api.github.com/users/sethladd/orgs",
    "received_events_url":
        "https://api.github.com/users/sethladd/received_events",
    "repos_url": "https://api.github.com/users/sethladd/repos",
    "starred_at": null,
    "starred_url":
        "https://api.github.com/users/sethladd/starred{/owner}{/repo}",
    "subscriptions_url": "https://api.github.com/users/sethladd/subscriptions",
    "type": "User",
    "url": "https://api.github.com/users/sethladd"
  },
  "labels": [
    {"name": "enhancement", "color": "84b6eb", "description": ""}
  ],
  "assignee": null,
  "assignees": [],
  "milestone": null,
  "comments": 0,
  "pull_request": null,
  "created_at": "2013-11-12T05:03:17.000Z",
  "closed_at": null,
  "updated_at": "2015-08-06T16:28:42.000Z",
  "body": "",
  "closed_by": null,
  "active_lock_reason": null,
  "author_association": "CONTRIBUTOR",
  "body_html": null,
  "body_text": null,
  "comments_url":
      "https://api.github.com/repos/dart-lang/api.dart.dev/issues/19/comments",
  "draft": null,
  "events_url":
      "https://api.github.com/repos/dart-lang/api.dart.dev/issues/19/events",
  "labels_url":
      "https://api.github.com/repos/dart-lang/api.dart.dev/issues/19/labels{/name}",
  "locked": false,
  "node_id": "MDU6SXNzdWUyMjQ5ODIxMA==",
  "performed_via_github_app": null,
  "reactions": {
    "+1": 0,
    "-1": 0,
    "confused": 0,
    "eyes": 0,
    "heart": 0,
    "hooray": 0,
    "laugh": 0,
    "rocket": 0,
    "total_count": 0,
    "url":
        "https://api.github.com/repos/dart-lang/api.dart.dev/issues/19/reactions"
  },
  "repository": null,
  "repository_url": "https://api.github.com/repos/dart-lang/api.dart.dev",
  "state_reason": null,
  "timeline_url":
      "https://api.github.com/repos/dart-lang/api.dart.dev/issues/19/timeline"
};

final issue2 = {
  "id": 22498210,
  "url": "https://api.github.com/repos/dart-lang/api.dart.dev/issues/19",
  "html_url": "https://github.com/dart-lang/api.dart.dev/issues/19",
  "number": 19,
  "state": "open",
  "title": "Need a 404 page",
  "user": {
    "login": "sethladd",
    "id": 5479,
    "avatar_url": "https://avatars.githubusercontent.com/u/5479?v=4",
    "html_url": "https://github.com/sethladd",
    "site_admin": false,
    "name": null,
    "company": null,
    "blog": null,
    "location": null,
    "email": null,
    "hirable": null,
    "bio": null,
    "public_repos": null,
    "public_gists": null,
    "followers": null,
    "following": null,
    "created_at": null,
    "updated_at": null,
    "twitter_username": null,
    "events_url": "https://api.github.com/users/sethladd/events{/privacy}",
    "followers_url": "https://api.github.com/users/sethladd/followers",
    "following_url":
        "https://api.github.com/users/sethladd/following{/other_user}",
    "gists_url": "https://api.github.com/users/sethladd/gists{/gist_id}",
    "gravatar_id": "",
    "node_id": "MDQ6VXNlcjU0Nzk=",
    "organizations_url": "https://api.github.com/users/sethladd/orgs",
    "received_events_url":
        "https://api.github.com/users/sethladd/received_events",
    "repos_url": "https://api.github.com/users/sethladd/repos",
    "starred_at": null,
    "starred_url":
        "https://api.github.com/users/sethladd/starred{/owner}{/repo}",
    "subscriptions_url": "https://api.github.com/users/sethladd/subscriptions",
    "type": "User",
    "url": "https://api.github.com/users/sethladd"
  },
  "labels": [
    {"name": "enhancement", "color": "84b6eb", "description": ""},
    {"name": "P1", "color": "85b6eb", "description": ""}
  ],
  "assignee": null,
  "assignees": [],
  "milestone": null,
  "comments": 0,
  "pull_request": null,
  "created_at": "2013-11-12T05:03:17.000Z",
  "closed_at": null,
  "updated_at": "2015-08-06T16:28:42.000Z",
  "body": "",
  "closed_by": null,
  "active_lock_reason": null,
  "author_association": "CONTRIBUTOR",
  "body_html": null,
  "body_text": null,
  "comments_url":
      "https://api.github.com/repos/dart-lang/api.dart.dev/issues/19/comments",
  "draft": null,
  "events_url":
      "https://api.github.com/repos/dart-lang/api.dart.dev/issues/19/events",
  "labels_url":
      "https://api.github.com/repos/dart-lang/api.dart.dev/issues/19/labels{/name}",
  "locked": false,
  "node_id": "MDU6SXNzdWUyMjQ5ODIxMA==",
  "performed_via_github_app": null,
  "reactions": {
    "+1": 2,
    "-1": 0,
    "confused": 0,
    "eyes": 0,
    "heart": 0,
    "hooray": 0,
    "laugh": 0,
    "rocket": 0,
    "total_count": 0,
    "url":
        "https://api.github.com/repos/dart-lang/api.dart.dev/issues/19/reactions"
  },
  "repository": null,
  "repository_url": "https://api.github.com/repos/dart-lang/api.dart.dev",
  "state_reason": null,
  "timeline_url":
      "https://api.github.com/repos/dart-lang/api.dart.dev/issues/19/timeline"
};
void main() {
  test(
    'Add changes',
    () async {
      final id = issue1['id'].toString();
      final j1 = jsonEncode(Issue.fromJson(issue1));
      final issue = Issue.fromJson(issue2);
      final j2 = jsonEncode(issue);
      await DatabaseReference.addChange(UpdateType.issues, id, null, j1);
      await DatabaseReference.addChange(UpdateType.issues, id, j1, j2);
      await DatabaseReference.addChange(
        UpdateType.issues,
        id,
        j2,
        jsonEncode(issue.close()),
      );
    },
    skip: 'This uploads fake data',
  );

  test(
    'Get changes',
    () async {
      final map =
          await DatabaseReference.getData(UpdateType.issues, Issue.fromJson);
      expect(map.values.first.first.state, 'closed');
    },
    skip: 'This checks the uploaded fake data',
  );
}

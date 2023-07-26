enum UpdateType {
  issues('issue'),
  pullrequests('pr'),
  googlers(''),
  testType('testtype');

  final String short;

  const UpdateType(this.short);
}

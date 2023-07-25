enum UpdateType {
  issues('issue'),
  pullrequests('pr'),
  googlers(''),
  testType('');

  final String short;

  const UpdateType(this.short);
}

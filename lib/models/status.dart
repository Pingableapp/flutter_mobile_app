class Status {
  final int statusId, userId, status, groupId;
  final String type, endTime; // TODO may want to change endTime to timestamp

  Status(this.statusId, this.userId, this.status, this.groupId, this.type,
      this.endTime);
}
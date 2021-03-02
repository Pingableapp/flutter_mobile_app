class FriendRequest {
  int sendingUserId;
  String sendingFirstName;
  String sendingLastName;
  String receivingPhoneNumber;
  String expirationTimestamp;

  FriendRequest(
    this.sendingUserId,
    this.sendingFirstName,
    this.sendingLastName,
    this.receivingPhoneNumber,
    this.expirationTimestamp,
  );

  static int compareNames(FriendRequest requestOne, FriendRequest requestTwo) {
    var comparisonResult =
        requestOne.sendingFirstName.toLowerCase().compareTo(requestTwo.sendingFirstName.toLowerCase());
    if (comparisonResult != 0) {
      return comparisonResult;
    }
    // Surnames are the same, so sub-sort by given name.
    return requestOne.sendingLastName.toLowerCase().compareTo(requestTwo.sendingLastName.toLowerCase());
  }

  static List<FriendRequest> sortListFirstLast(List<FriendRequest> friendRequestsList) {
    friendRequestsList.sort(FriendRequest.compareNames);
    return friendRequestsList;
  }
}

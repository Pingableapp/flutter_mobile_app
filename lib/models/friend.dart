import 'package:pingable/models/user.dart';

class Friend extends User {
  bool active;
  int relationshipStatus;

  Friend(
    int id,
    String firstName,
    String lastName,
    String phoneNumber,
    int relationshipStatus,
    bool active,
  ) : super(id, firstName, lastName, phoneNumber) {
    this.relationshipStatus = relationshipStatus;
    this.active = active;
  }
}

List<Friend> filterAcceptedFriends(List<Friend> unfilteredFriends) {
  List<Friend> filteredFriends = [];
  for (int i = 0; i < unfilteredFriends.length; ++i ){
    if (unfilteredFriends[i].relationshipStatus == 1) {
      filteredFriends.add(unfilteredFriends[i]);
    }
  }
  return filteredFriends;
}

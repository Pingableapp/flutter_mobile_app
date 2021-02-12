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
    this.active = active;
  }
}

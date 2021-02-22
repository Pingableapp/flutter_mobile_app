class User {
  int id;
  String firstName, lastName, phoneNumber;

  User(this.id, this.firstName, this.lastName, this.phoneNumber);

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        phoneNumber = json['phoneNumber'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
      };

  static int compareNames(User userOne, User userTwo) {
    var comparisonResult = userOne.firstName
        .toLowerCase()
        .compareTo(userTwo.firstName.toLowerCase());
    if (comparisonResult != 0) {
      return comparisonResult;
    }
    // Surnames are the same, so sub-sort by given name.
    return userOne.lastName
        .toLowerCase()
        .compareTo(userTwo.lastName.toLowerCase());
  }

  static List<User> sortUserListFirstLast(List<User> userList) {
    userList.sort(User.compareNames);
    return userList;
  }
}

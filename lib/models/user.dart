

class User {
  final int id;
  final String firstName, lastName, phoneNumber;

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

}
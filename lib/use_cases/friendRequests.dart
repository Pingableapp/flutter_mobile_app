import 'dart:async';

import 'package:pingable/api/friends.dart' as friendsAPI;
import 'package:pingable/models/friendRequest.dart';
import 'package:pingable/use_cases/users.dart' as usersUseCase;

Future<List<FriendRequest>> getFriendRequests() async {
  int userId = await usersUseCase.getLoggedInUserId();
  List<FriendRequest> friendRequests = await friendsAPI.getFriendRequests(userId);
  return friendRequests;
}

Future<int> getFriendRequestsCount() async {
  int userId = await usersUseCase.getLoggedInUserId();
  List<FriendRequest> friendRequests = await friendsAPI.getFriendRequests(userId);
  return friendRequests.length;
}

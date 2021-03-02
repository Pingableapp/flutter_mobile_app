
import 'package:pingable/api/clickTracking.dart' as clickTrackingAPI;
import 'package:pingable/use_cases/screenSize.dart' as screenSizeUseCase;
import 'package:pingable/use_cases/users.dart' as usersUseCase;

recordClickTrackingEvent(String actionId, String actionType, String additionalInfo) async {
  int userId = await usersUseCase.getLoggedInUserId();
  int screenWidth = await screenSizeUseCase.getScreenWidth();
  int screenHeight = await screenSizeUseCase.getScreenHeight();

  clickTrackingAPI.recordClickTrackingEvent(userId, actionId, actionType, screenWidth, screenHeight, additionalInfo);
}

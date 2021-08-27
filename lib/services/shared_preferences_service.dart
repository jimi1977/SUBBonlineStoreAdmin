import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesServiceProvider =
Provider<SharedPreferencesService>((ref) => throw UnimplementedError());

class SharedPreferencesService {
SharedPreferencesService(this.sharedPreferences);
final SharedPreferences sharedPreferences;

static const onboardingCompleteKey = 'onboardingComplete';
static const onboardingStoreIdKey = 'storeId';
static const onboardingBranchIdKey = 'branchId';
static const lastUserLoginIdKey = 'lastUserLoginId';


Future<void> setOnboardingComplete() async {
  await sharedPreferences.setBool(onboardingCompleteKey, true);
}

Future<void> setStoreId(String storeId) async {
  await sharedPreferences.setString(onboardingStoreIdKey, storeId);
}
Future<void> setBranchId(String branchId) async {
  await sharedPreferences.setString(onboardingBranchIdKey, branchId);
}
Future<void> setLastUserLogin(String userId) async {
  await sharedPreferences.setString(lastUserLoginIdKey, userId);
}

String getStoreId() {
  return sharedPreferences.getString(onboardingStoreIdKey);
}

String getBranchId() {
  return sharedPreferences.getString(onboardingBranchIdKey);
}
String getLastUserLoginId() {
  return sharedPreferences.getString(lastUserLoginIdKey);
}


bool isOnboardingComplete() =>
    sharedPreferences.getBool(onboardingCompleteKey) ?? false;
}

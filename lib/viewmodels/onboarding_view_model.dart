import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:models/store.dart';
import 'package:subbonline_storeadmin/providers_general.dart';
import 'package:subbonline_storeadmin/services/shared_preferences_service.dart';
import 'package:services/store_service.dart';

final onboardingViewModelProvider = StateNotifierProvider<OnboardingViewModel, bool>((ref) {
  final sharedPreferencesService = ref.watch(sharedPreferencesServiceProvider);
  final storeService = ref.watch(storeServiceProvider);
  return OnboardingViewModel(sharedPreferencesService, storeService);
});

class OnboardingViewModel extends StateNotifier<bool> {
  OnboardingViewModel(this.sharedPreferencesService, this.storeService) : super(sharedPreferencesService.isOnboardingComplete());
  final SharedPreferencesService sharedPreferencesService;
  final StoreService storeService;

  Future<void> completeOnboarding() async {
    print('COMPLETE ONBOARDING');
    await sharedPreferencesService.setOnboardingComplete();
    state = true;
  }

  Future<void>   setStoreId(String storeId) async {
    await sharedPreferencesService.setStoreId(storeId);
  }
  Future<void> setBranchId(String branchId) async {
    await sharedPreferencesService.setBranchId(branchId);
  }

  Future<Store> getStore(String storeId) async {
    return await storeService.getStore(storeId);
  }

  Future<StoreBranch> getStoreBranch(String storeId, String branchCode) async {
    return await storeService.getStoreBranch(storeId, branchCode);
  }
  bool get isOnboardingComplete => state;
}






import 'package:flutter/foundation.dart';
import 'package:models/store.dart';
import 'package:subbonline_storeadmin/services/shared_preferences_service.dart';
import 'package:services/store_service.dart';

class StoreBranchSelectionViewModel extends ChangeNotifier {
  StoreBranchSelectionViewModel({@required this.storeService, @required this.sharedPreferencesService}):
        storeId = sharedPreferencesService.getStoreId(),
        branchId = sharedPreferencesService.getBranchId();

  final StoreService storeService;
  final SharedPreferencesService sharedPreferencesService;

  String storeId;
  String branchId;


  setStoreId(String storeId) {
    this.storeId = storeId;
    print("Set Store Id");
    notifyListeners();
  }

  setBranchId(String branchId) {
    this.branchId = branchId;
    notifyListeners();
  }

  Future<List<Store>> getAllActiveStores() async {
    return await storeService.getAllActiveStores();
  }

  Future<List<StoreBranch>> getActiveStoreBranches(String storeId) {
    if (storeId == null) return null;
    return storeService.getAllActiveStoreBranches(storeId);
  }

}
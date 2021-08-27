



import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/models/strore_users.dart';
import 'package:subbonline_storeadmin/providers_general.dart';
import 'package:subbonline_storeadmin/services/shared_preferences_service.dart';
import 'package:subbonline_storeadmin/services/store_users_service.dart';
import 'package:uuid/uuid.dart';




final userLoginViewModelProvider = StateNotifierProvider<UserLoginViewModel, bool>((ref) {
  final storeUsersService = ref.watch(storeUsersServiceProvider);
  final sharedPreferencesService = ref.watch(sharedPreferencesServiceProvider);
    return UserLoginViewModel(storeUsersService,sharedPreferencesService );
} );


class UserLoginViewModel extends StateNotifier<bool> {

  String errorMessage;

  final StoreUserService storeUsersService;
  final SharedPreferencesService sharedPreferencesService;

  StoreUsers _storeUsers;


  UserLoginViewModel(this.storeUsersService, this.sharedPreferencesService) : super(false);


  bool get isUserLoginComplete => state;

  StoreUsers get storeUsers => _storeUsers;

  set storeUsers(StoreUsers value) {
    _storeUsers = value;
  }
  Future<void> saveLastLoginId(String userId) async {
    await sharedPreferencesService.setLastUserLogin(userId);
  }

  String getLastLoginId() {
    var lastLoginId = sharedPreferencesService.getLastUserLoginId();
    if (lastLoginId != null && lastLoginId.length > 0){
      return lastLoginId;
    }
    return null;
  }

  String getStoreId() {
    String storeId =sharedPreferencesService.getStoreId();
    return storeId;
  }

  String getBranchId() {
    String branchId =sharedPreferencesService.getBranchId();
    return branchId;
  }


  Future<bool> verifyUserPassword(String userId, String password) async {
    String storeId = sharedPreferencesService.getStoreId();
    String branchId = sharedPreferencesService.getBranchId();
    var storeUsers = await storeUsersService.verifyStoreUserPassword(storeId, branchId, userId, password);
    if (storeUsers !=null) {
      _storeUsers = storeUsers;
      return true;
    }
    return false;
  }
  Future<StoreUsers> checkIfUserExists({String storeId, String branchId, String userId}) async {
    if (storeId == null) {
      storeId = sharedPreferencesService.getStoreId();
      branchId = sharedPreferencesService.getBranchId();
    }

    var storeUsers = await storeUsersService.checkIfUserExists(storeId, branchId, userId);
    return storeUsers;
  }

  Future<StoreUsers> getUserById({String storeId, String branchId, String userId} ) async {
    if (storeId == null) {
      storeId = sharedPreferencesService.getStoreId();
      branchId = sharedPreferencesService.getBranchId();
    }
    var storeUsers = await storeUsersService.getStoreUser(storeId, branchId, userId);
    return storeUsers;
  }

  Future<bool> updateUser(StoreUsers storeUsers) async {
    bool _result = true;
    try {
      await storeUsersService.updateUser(storeUsers);
    } on Exception catch (e) {
      errorMessage = storeUsersService.errorMessage;
      _result = false;
    }
    return _result;

  }

  Future<bool> createNewUser({String storeId, String branchId, String userId, String userName, int roleCode, String password}) async {
    if (storeId == null) {
       storeId = sharedPreferencesService.getStoreId();
       branchId = sharedPreferencesService.getBranchId();
    }
    bool _result = true;
    StoreUsers _storeUser;
    DateTime _dateCreated = DateTime.now().toLocal();
    String _status = 'A';

    var id = Uuid();
    String uid = id.v1();


    _storeUser = StoreUsers(
      uid: uid,
      storeId: storeId,
      branchId: branchId,
      userId: userId,
      name: userName,
      roleCode: roleCode,
      status: _status,
      dateCreated: _dateCreated,
      password: password
    );
    try {
      await storeUsersService.createNewUser(_storeUser);
    } on Exception catch (e) {
      errorMessage = storeUsersService.errorMessage;
      _result = false;
    }
    return _result;

  }

  Future<bool> inactivateUser(String uid, DateTime dateInactivate) async {
    bool _result = true;
    try {
      await storeUsersService.inActivateUser(uid, dateInactivate);
    } on Exception catch (e) {
      errorMessage = storeUsersService.errorMessage;
      _result = false;
    }
    return _result;
  }

  Future<bool> resetPassword(StoreUsers user ) async {
    bool _result = true;
    try {
      await storeUsersService.resetPassword(user.uid, user.userId);
    } on Exception catch (e) {
      errorMessage = storeUsersService.errorMessage;
      _result = false;
    }
    return _result;
  }


  loginSuccess() {
    state = true;
  }

  logout() {
    state = false;
  }

  Future<List<StoreUsers>> getStoreUsersList() async {
    String storeId = sharedPreferencesService.getStoreId();
    String branchId = sharedPreferencesService.getBranchId();
    return await storeUsersService.getStoreUsers(storeId, branchId);
  }

}
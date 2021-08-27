import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/viewmodels/store_view_model.dart';

import '../models/store.dart';
import '../providers_general.dart';
import '../services/shared_preferences_service.dart';
import '../services/store_service.dart';

final branchViewModelProvider = ChangeNotifierProvider((ref) => BranchViewModel(
    ref.watch(storeServiceProvider), ref.watch(sharedPreferencesServiceProvider), ref.watch(storeViewModelProvider)));

class BranchViewModel extends ChangeNotifier {
  final StoreService storeService;
  final SharedPreferencesService sharedPreferencesService;
  final StoreViewModel storeViewModelProvider;

  BranchViewModel(this.storeService, this.sharedPreferencesService, this.storeViewModelProvider);

  String _branchId;
  String _name;
  String _address;
  String _suburb;
  String _city;
  String _mainBranch;
  String _status;
  GeoPoint _geoPoints;
  DateTime _createdDate;
  List<BranchTimings> _branchTimings;


  String get branchId => _branchId;

  set branchId(String value) {
    _branchId = value;
  }

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get address => _address;

  set address(String value) {
    _address = value;
  }

  String get suburb => _suburb;

  set suburb(String value) {
    _suburb = value;
  }

  String get city => _city;

  set city(String value) {
    _city = value;
  }

  String get mainBranch => _mainBranch;

  set mainBranch(String value) {
    _mainBranch = value;
  }


  String get status => _status;

  set status(String value) {
    _status = value;
  }

  GeoPoint get geoPoints => _geoPoints;

  set geoPoints(GeoPoint value) {
    _geoPoints = value;
  }


  DateTime get createdDate => _createdDate;

  set createdDate(DateTime value) {
    _createdDate = value;
  }

  List<BranchTimings> get branchTimings => _branchTimings;

  set branchTimings(List<BranchTimings> value) {
    _branchTimings = value;
  }
  initialise() {
    _branchId = null;
    _name = null;
    _address = null;
    _suburb = null;
    _city = null;
    _mainBranch = null;
    _status = null;
    _geoPoints = null;
    _createdDate =  null;
    _branchTimings = null;
  }
  bool isStoreSelected() {
    if (storeViewModelProvider.getStoreId() != null && storeViewModelProvider.getStoreName() != null) {
      return true;
    }
    return false;
  }

  String getSelectedStoreId() {
    return storeViewModelProvider.getStoreId();
  }

  String getCurrentStoreId() {
    return sharedPreferencesService.getStoreId();
  }

  Future<StoreBranch> getCurrentBranchId() async {
    String _storeId = sharedPreferencesService.getStoreId();
    String _branchId =  sharedPreferencesService.getBranchId();
    return await storeService.getStoreBranch(_storeId, _branchId);
  }

  Future<StoreBranch> getStoreBranch(String storeId, String branchCode) async {
    return await storeService.getStoreBranch(storeId, branchCode);
  }

  buildState(){
    notifyListeners();
  }
}

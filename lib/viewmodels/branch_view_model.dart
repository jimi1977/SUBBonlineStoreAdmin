import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:subbonline_storeadmin/providers_general.dart';
import 'package:subbonline_storeadmin/services/geocoding_service.dart';
import 'package:subbonline_storeadmin/viewmodels/branch_schedule_view_model.dart';
import 'package:subbonline_storeadmin/viewmodels/store_view_model.dart';

import '../models/store.dart';
import '../providers_general.dart';
import '../services/shared_preferences_service.dart';
import '../services/store_service.dart';

final branchViewModelProvider = ChangeNotifierProvider((ref) => BranchViewModel(
    ref.watch(storeServiceProvider),
    ref.watch(sharedPreferencesServiceProvider),
    ref.watch(geoCodingServiceProvider),
    ref.watch(storeViewModelProvider),
    ref.watch(branchScheduleViewProvider)));

class BranchViewModel extends ChangeNotifier {
  final StoreService storeService;
  final SharedPreferencesService sharedPreferencesService;
  final GeoCodingService geoCodingService;
  final StoreViewModel storeViewModelProvider;
  final BranchScheduleViewModel branchScheduleViewModel;

  BranchViewModel(
    this.storeService,
    this.sharedPreferencesService,
    this.geoCodingService,
    this.storeViewModelProvider,
    this.branchScheduleViewModel,
  );

  String _storeId;
  String _branchId;
  String _name;
  String _address;
  String _suburb;
  String _city;
  String _mainBranch;
  String _status;
  GeoPoint _geoPoints;
  DateTime _createdDate;
  double _deliveryRange;
  double _deliveryThreshold;
  double _flatCharges = 0.0;
  double _freeDeliveryAmount = 0.0;

  List<BranchTimings> _branchTimings;

  String errorMessage;

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

  String get storeId => _storeId;

  set storeId(String value) {
    _storeId = value;
  }


  double get deliveryRange => _deliveryRange;

  set deliveryRange(double value) {
    _deliveryRange = value;
  }


  double get flatCharges => _flatCharges;

  set flatCharges(double value) {
    _flatCharges = value;
  }
  double get freeDeliveryAmount => _freeDeliveryAmount;

  set freeDeliveryAmount(double value) {
    _freeDeliveryAmount = value;
  }


  double get deliveryThreshold => _deliveryThreshold;

  set deliveryThreshold(double value) {
    _deliveryThreshold = value;
  }

  initialise() {
    print("BranchViewModel...initialise");
    _branchId = null;
    _name = null;
    _address = null;
    _suburb = null;
    _city = null;
    _mainBranch = null;
    _status = null;
    _geoPoints = null;
    _createdDate = null;
  //  _branchTimings = null;
    _deliveryRange = null;
    _flatCharges = null;
    _freeDeliveryAmount = null;
    _deliveryThreshold = null;
    branchScheduleViewModel.initialise();
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
    String _branchId = sharedPreferencesService.getBranchId();
    return getStoreBranch(_storeId, _branchId);

  }

  Future<StoreBranch> getStoreBranch(String storeId, String branchCode) async {
    var branches = await storeService.getStoreBranch(storeId, branchCode);
    if (branches != null) {
      branchScheduleViewModel.setBranchTimings(branches.branchTimings);
    }
    //branchScheduleViewModel.buildState();
    return branches;
  }

  List<BranchTimings> getBranchTimings() {
    return branchScheduleViewModel.getBranchTimings();
  }

  Future<bool> branchSave() async {
    bool isSave = true;
    storeId = storeViewModelProvider.getStoreId();
    StoreDeliveryCharges _storeDeliveryCharges;
    if (flatCharges != null || freeDeliveryAmount != null) {
      _storeDeliveryCharges = StoreDeliveryCharges(flatCharges:flatCharges, freeDeliveryAmount:freeDeliveryAmount  );
    }
    StoreBranch _storeBranch = StoreBranch(
        branchId: branchId,
        name: name,
        address: address,
        suburb: suburb,
        city: city,
        status: status,
        geoPoints: geoPoints,
        mainBranch: mainBranch,
        createDate: createdDate,
        deliveryRange: deliveryRange,
        deliveryThreshold: deliveryThreshold,
        storeDeliveryCharges: _storeDeliveryCharges,
        branchTimings: branchTimings);

    try {
      await storeService.saveStoreBranch(storeId, _storeBranch);
    } on Exception catch (e) {
      isSave = false;
      errorMessage = e.toString();
    }
    return isSave;
  }

  updateBranchTimings() {
    branchScheduleViewModel.updateBranchTimings();
  }

  Future<List<Location>> verifyAddress(String address) async {
    List<Location> location;
    try {
      location = await geoCodingService.getAddressGeoCodes(address);
    } on Exception catch (e) {
      errorMessage = e.toString();
    }
    return location;
  }

  Future<List<Placemark>> getAddressFromGeoCodes(Location location) async {
    var placeMarks =  await geoCodingService.getGeoCodesAddress(location);
    return placeMarks;
  }

  buildState() {
    notifyListeners();
  }


}

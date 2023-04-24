import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subbonline_storeadmin/models/order.dart';
import 'package:subbonline_storeadmin/models/rider_quque.dart';
import 'package:subbonline_storeadmin/models/strore_users.dart';
import 'package:subbonline_storeadmin/services/shared_preferences_service.dart';
import 'package:subbonline_storeadmin/services/store_users_service.dart';

import '../providers_general.dart';

final riderViewProvider = ChangeNotifierProvider(
    (ref) => RiderViewModel(ref.watch(sharedPreferencesServiceProvider), ref.watch(storeUsersServiceProvider)));

class RiderViewModel extends ChangeNotifier {
  final SharedPreferencesService sharedPreferencesService;
  final StoreUserService storeUsersService;
  String selectedRiderUid;
  String errorMessage;

  RiderViewModel(this.sharedPreferencesService, this.storeUsersService );

  Future<List<StoreUsers>> getAvailableRiders(String storeId, String branchId) {
    return storeUsersService.getBranchRiders(storeId, branchId);
  }

  Future<void> addToRiderQueue(String riderId, Order order) async {
    try {
      await storeUsersService.addRiderQueue(riderId);
      RiderQueue riderQueue = prepareQueue(riderId, order, order.storeOrders.storeId, order.storeOrders.branchId);
      await storeUsersService.addOrderToRiderQueue(riderQueue);
    } on Exception catch (e) {
      errorMessage = e.toString();
      throw (errorMessage);
    }
  }
  RiderQueue prepareQueue(String riderId, Order order, String storeId, String branchId) {
    DateTime _currentDatetime = DateTime.now();
    DateTime _deliveryDatetime = _currentDatetime.add(Duration(minutes: 30));
    RiderQueue riderQueue = RiderQueue(
      orderId: order.orderId,
      uid: riderId,
      userId: order.uid,
      storeId: storeId,
      branchId: branchId,
      orderAssignedDateTime: _currentDatetime,
      deliveryInProgress: 'N',
      deliveryAddress: order.deliveryAddress
    );
    return riderQueue;

  }

  removeFromRiderQueue(String riderId) async {
    try {
      await storeUsersService.subtractRiderQueue(riderId);
    } on Exception catch (e) {
      errorMessage = e.toString();
      throw (errorMessage);
    }
  }

  String getStoreId() {
    return sharedPreferencesService.getStoreId();
  }

  String getBranchId() {
    return sharedPreferencesService.getBranchId();
  }
}

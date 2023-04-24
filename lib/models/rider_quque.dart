

import 'package:subbonline_storeadmin/models/delivery_address.dart';

class RiderQueue {

  final String uid;
  final String userId;
  final String orderId;
  final String storeId;
  final String branchId;
  final DateTime orderAssignedDateTime;
  final DateTime orderDeliveredDatetime;
  final String deliveryInProgress;
  final DeliveryAddress deliveryAddress;

  RiderQueue({this.uid, this.userId, this.orderId, this.storeId, this.branchId, this.orderAssignedDateTime,
      this.orderDeliveredDatetime, this.deliveryInProgress, this.deliveryAddress});

  Map<String, dynamic> toMap() {
    return {
      'uid': this.uid,
      'userId': this.userId,
      'orderId': this.orderId,
      'storeId': this.storeId,
      'branchId': this.branchId,
      'orderAssignedDateTime': this.orderAssignedDateTime,
      'orderDeliveredDatetime': this.orderDeliveredDatetime,
      'deliveryInProgress': this.deliveryInProgress,
      'deliveryAddress': this.deliveryAddress.toMap(),
    };
  }

  factory RiderQueue.fromMap(Map<String, dynamic> map) {
    return RiderQueue(
      uid: map['uid'] as String,
      userId: map['userId'] as String,
      orderId: map['orderId'] as String,
      storeId: map['storeId'] as String,
      branchId: map['branchId'] as String,
      orderAssignedDateTime: map['orderAssignedDateTime'] as DateTime,
      orderDeliveredDatetime: map['orderDeliveredDatetime'] as DateTime,
      deliveryInProgress: map['deliveryInProgress'] as String,
      deliveryAddress: map['deliveryAddress'] as DeliveryAddress,
    );
  }
}




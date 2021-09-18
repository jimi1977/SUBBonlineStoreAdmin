import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../utility/utility_functions.dart';

class Store {
  final String storeCode;
  final String store;
  final String status;
  final String aboutStore;
  final String storeLogo;
  final DateTime createDate;

  Store({this.storeCode, this.store, this.status, this.aboutStore, this.storeLogo, this.createDate});

  factory Store.fromMap(Map<String, dynamic> map) {
    return new Store(
        storeCode: map['storeCode'] as String,
        store: map['store'] as String,
        status: map['status'] as String,
        aboutStore: map['aboutStore'] as String,
        storeLogo: map['storeLogo'] as String,
        createDate: convertTimeStampToDatetimeWithNull(map['createDate']));
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'storeCode': this.storeCode,
      'store': this.store,
      'status': this.status,
      'aboutStore': this.aboutStore,
      'storeLogo': this.storeLogo,
      'createDate': this.createDate
    } as Map<String, dynamic>;
  }

  factory Store.fromFireStore(DocumentSnapshot map) {
    if (!map.exists) return null;
    return new Store(
        storeCode: map.data()['storeCode'] as String,
        store: map.data()['store'] as String,
        status: map.data()['status'] as String,
        aboutStore: map.data()['aboutStore'] as String,
        storeLogo: map.data()['storeLogo'] as String,
        createDate: convertTimeStampToDatetimeWithNull(map.data()['createDate']));
  }

  @override
  String toString() {
    return 'Store{storeCode: $storeCode, store: $store, status: $status, aboutStore: $aboutStore, storeLogo: $storeLogo, createDate: $createDate}';
  }
}

class StoreBranch {
  final String branchId;
  final String name;
  final String address;
  final String suburb;
  final String city;
  final String mainBranch;
  final String status;
  final GeoPoint geoPoints;
  final DateTime createDate;
  final double deliveryRange;
  final double deliveryThreshold;
  final List<BranchTimings> branchTimings;
  final StoreDeliveryCharges storeDeliveryCharges;



  StoreBranch({
    @required this.branchId,
    this.name,
    this.address,
    this.suburb,
    this.city,
    this.mainBranch,
    this.status,
    this.geoPoints,
    this.createDate,
    this.deliveryRange,
    this.deliveryThreshold,
    this.branchTimings,
    this.storeDeliveryCharges,
  });

  factory StoreBranch.fromFireStore(DocumentSnapshot map) {
    if (!map.exists) return StoreBranch();
    return new StoreBranch(
        branchId: map.data()['branchId'] as String,
        name: map.data()['name'] as String,
        address: map.data()['address'] as String,
        suburb: map.data()['suburb'] as String,
        city: map.data()['city'] as String,
        mainBranch: map.data()['mainBranch'],
        status: map.data()['status'] as String,
        geoPoints: map.data()['geoPoints'] as GeoPoint,
        createDate: convertTimeStampToDatetimeWithNull(map.data()['createDate']),
        deliveryRange: map.data()['deliveryRange'],
        deliveryThreshold : map.data()['deliveryThreshold'],
        branchTimings: map.data()["branchTimings"] != null
            ? List.from(map.data()["branchTimings"]).map((e) => BranchTimings.fromMap(e)).toList()
            : null,
        storeDeliveryCharges: map.data()["storeDeliveryCharges"]);
  }

  factory StoreBranch.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) return null;
    return new StoreBranch(
      branchId: map['branchId'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      suburb: map['suburb'] as String,
      city: map['city'] as String,
      mainBranch: map['mainBranch'],
      status: map['status'] as String,
      geoPoints: map['geoPoints'] as GeoPoint,
      createDate: convertTimeStampToDatetimeWithNull(map['createDate']),
      deliveryRange: map['deliveryRange'],
        deliveryThreshold: map['deliveryThreshold'],
      branchTimings: map["branchTimings"] != null
          ? List.from(map["branchTimings"]).map((e) => BranchTimings.fromMap(e)).toList()
          : null,
      storeDeliveryCharges: StoreDeliveryCharges.fromMap(map["storeDeliveryCharges"]),
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'branchId': this.branchId,
      'name': this.name,
      'address': this.address,
      'suburb': this.suburb,
      'city': this.city,
      'mainBranch': this.mainBranch,
      'status': this.status,
      'geoPoints': this.geoPoints,
      'createDate': this.createDate,
      'deliveryRange': this.deliveryRange,
      'deliveryThreshold': this.deliveryThreshold,
      'branchTimings': firesStoreBranchTimings(),
      'storeDeliveryCharges': this.storeDeliveryCharges.toMap(),
    } as Map<String, dynamic>;
  }

  List<Map<String, dynamic>> firesStoreBranchTimings() {
    List<Map<String, dynamic>> convertedBranchTimings = [];
    this.branchTimings.forEach((branchTiming) {
      BranchTimings _branchTimings = branchTiming;
      convertedBranchTimings.add(_branchTimings.toMap());
    });
    return convertedBranchTimings;
  }
}

class TimeClass {
  @required
  int hour;
  @required
  int minute;
  @required
  String period;

  TimeClass({this.hour, this.minute, this.period});

  factory TimeClass.fromMap(Map<String, dynamic> map) {
    return new TimeClass(
      hour: map['hour'],
      minute: map['minute'],
      period: map['period'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'hour': this.hour,
      'minute': this.minute,
      'period': this.period,
    } as Map<String, dynamic>;
  }
}

class BranchTimings {
  final String day;
  final String openFlag;
  final TimeClass fromTime;
  final TimeClass toTime;

  BranchTimings({this.day, this.openFlag, this.fromTime, this.toTime});

  factory BranchTimings.fromMap(Map<String, dynamic> map) {
    return new BranchTimings(
      day: map['day'] as String,
      openFlag: map['openFlag'] as String,
      fromTime: TimeClass.fromMap(map['fromTime']),
      toTime: TimeClass.fromMap(map['toTime']),
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'day': this.day,
      'openFlag': this.openFlag,
      'fromTime': this.fromTime.toMap(),
      'toTime': this.toTime.toMap(),
    } as Map<String, dynamic>;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BranchTimings &&
          runtimeType == other.runtimeType &&
          day == other.day &&
          openFlag == other.openFlag &&
          fromTime == other.fromTime &&
          toTime == other.toTime;

  @override
  int get hashCode => day.hashCode ^ openFlag.hashCode ^ fromTime.hashCode ^ toTime.hashCode;
}

class StoreDeliveryCharges {
  final double flatCharges;
  final double freeDeliveryAmount;


  StoreDeliveryCharges({this.flatCharges, this.freeDeliveryAmount});

  factory StoreDeliveryCharges.fromMap(Map<String, dynamic> map) {
    return new StoreDeliveryCharges(
        flatCharges: map['flatCharges'] as double,
        freeDeliveryAmount: map['freeDeliveryAmount'] as double,

    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'flatCharges': this.flatCharges,
      'freeDeliveryAmount': this.freeDeliveryAmount,
    } as Map<String, dynamic>;
  }
}

class TieredDeliveryCharges {
  final double distance;
  final double charges;

  TieredDeliveryCharges({this.distance, this.charges});

  factory TieredDeliveryCharges.fromMap(Map<String, dynamic> map) {
    return new TieredDeliveryCharges(
      distance: map['distance'] as double,
      charges: map['charges'] as double,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'distance': this.distance,
      'charges': this.charges,
    } as Map<String, dynamic>;
  }
}

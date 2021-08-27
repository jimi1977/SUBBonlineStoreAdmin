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

  StoreBranch(
      {this.branchId,
      this.name,
      this.address,
      this.suburb,
      this.city,
      this.mainBranch,
      this.status,
      this.geoPoints,
      this.createDate});

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
        createDate: convertTimeStampToDatetimeWithNull(map.data()['createDate']));
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
        createDate: convertTimeStampToDatetimeWithNull(map['createDate']));
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
      'createDate': this.createDate
    } as Map<String, dynamic>;
  }

  @override
  String toString() {
    return 'StoreBranch{branchId: $branchId, name: $name, address: $address, suburb: $suburb, city: $city, mainBranch: $mainBranch, status: $status, geoPoints: $geoPoints}';
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
      fromTime: map['fromTime'] as TimeClass,
      toTime: map['toTime'] as TimeClass,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'day': this.day,
      'openFlag': this.openFlag,
      'fromTime': this.fromTime,
      'toTime': this.toTime,
    } as Map<String, dynamic>;
  }
}

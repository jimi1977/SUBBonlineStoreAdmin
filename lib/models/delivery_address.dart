

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DeliveryAddress {
  final String uid;
  final String receiverName;
  final String addressLine1;
  final String addressLine2;
  final String suburb;
  final String city;
  final String country;
  final bool   saveAddress;

  const


  DeliveryAddress({
    @required this.uid,
    @required this.receiverName,
    @required this.addressLine1,
    @required this.addressLine2,
    @required this.suburb,
    @required this.city,
    @required this.country,
    @required this.saveAddress
  });

  factory DeliveryAddress.fromMap(Map<String, dynamic> map) {
    return new DeliveryAddress(
      uid: map['uid'] as String,
      receiverName: map['receiverName'] as String,
      addressLine1: map['addressLine1'] as String,
      addressLine2: map['addressLine2'] as String,
      suburb: map['suburb'] as String,
      city: map['city'] as String,
      country: map['country'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'uid': this.uid,
      'receiverName': this.receiverName,
      'addressLine1': this.addressLine1,
      'addressLine2': this.addressLine2,
      'suburb': this.suburb,
      'city': this.city,
      'country': this.country,
    } as Map<String, dynamic>;
  }
  factory DeliveryAddress.fromFireStore(DocumentSnapshot map) {
    Map doc = map.data();
    return new DeliveryAddress(
      uid: doc['uid'] as String,
      receiverName:  doc['receiverName'] as String,
      addressLine1: doc['addressLine1'] as String,
      addressLine2: doc['addressLine2'] as String,
      suburb: doc['suburb'] as String,
      city: doc['city'] as String,
      country: doc['country'] as String,
    );
  }

}
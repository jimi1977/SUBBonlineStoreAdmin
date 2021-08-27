import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {

  final String uid;
  String userName;
  final String email;
  final String photoUrl;
  String mobileNumber;
  String preferredCommunication;
  bool signUpComplete;
  final String userLevel;
  final String deviceToken;
  final List<String> favouriteProducts;
  final String storeId;
  final Address address;



  Customer(
      {this.uid, this.userName, this.email, this.photoUrl, this.mobileNumber, this.preferredCommunication, this.signUpComplete, this.userLevel, this.deviceToken, this.favouriteProducts, this.storeId, this.address});

  factory Customer.fromMap(DocumentSnapshot map) {
    // List<String> _favouriteProducts;
    // if (map == null || map.data() == null || map.data()['favouriteProducts'] == null){
    //   _favouriteProducts = [];
    // }
    // else {
    //   _favouriteProducts = List.from(map.data()['favouriteProducts']);
    //
    // }

    return new Customer(
        uid: map.data()['uid'] as String,
        userName: map.data()['userName'] as String,
        email: map.data()['email'] as String,
        photoUrl: map.data()['photoUrl'] as String,
        mobileNumber: map.data()['mobileNumber'] as String,
        preferredCommunication: map.data()['preferredCommunication'] as String,
        signUpComplete: map.data()['signUpComplete'] ?? false,
        userLevel: map.data()['userLevel'] as String ?? '',
        deviceToken: map.data()['deviceToken'] as String,
        //favouriteProducts: _favouriteProducts,
        storeId: map.data()['storeId'] as String,
        address: map.data()['address'] == null? null: Address.fromMap(map.data()['address'])
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'uid': this.uid,
      'userName': this.userName,
      'email': this.email,
      'photoUrl': this.photoUrl,
      'mobileNumber': this.mobileNumber,
      'preferredCommunication': this.preferredCommunication,
      'signUpComplete': this.signUpComplete,
      'userLevel': this.userLevel,
      'deviceToken': this.deviceToken,
      'favouriteProducts': this.favouriteProducts,
      'storeId': this.storeId,
      'address': this.address.toMap()
    } as Map<String, dynamic>;
  }
}

class Address{
  final String addressLine1;
  final String addressLine2;
  final String suburb;
  final String city;
  final String country;
  final GeoPoint geopoints;

  Address({this.addressLine1, this.addressLine2, this.suburb, this.city, this.country, this.geopoints});

  factory Address.fromMap(Map<String, dynamic> map) {
    return new Address(
        addressLine1: map['addressLine1'] as String,
        addressLine2: map['addressLine2'] as String,
        suburb: map['suburb'] as String,
        city: map['city'] as String,
        country: map['country'] as String,
        geopoints: map['geopoints'] as GeoPoint
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'addressLine1': this.addressLine1,
      'addressLine2': this.addressLine2,
      'suburb': this.suburb,
      'city': this.city,
      'country': this.country,
      'geopoints' : geopoints,
    } as Map<String, dynamic>;
  }
}
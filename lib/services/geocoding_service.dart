


import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';


class GeoCodingService {


  Future<List<Location>> getAddressGeoCodes(String address) async {
    List<Location> locations;
    try {
      locations = await locationFromAddress(address);
    } on PlatformException catch (e) {
      rethrow;
    }
    return locations;
  }

  Future<List<Placemark>> getGeoCodesAddress(Location location) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
    return placemarks;
  }

}
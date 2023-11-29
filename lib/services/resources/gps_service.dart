import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// Singleton class for handling GPS-related operations.
class GPS {
  factory GPS() => _singleton;
  static final GPS _singleton = GPS._internal();

  /// Notifier for the current latitude.
  static ValueNotifier<double> lat = ValueNotifier<double>(0.0);

  /// Notifier for the current longitude.
  static ValueNotifier<double> long = ValueNotifier<double>(0.0);

  GPS._internal();

  /// Fetches the current location and updates the latitude and longitude.
  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      lat.value = 0.0;
      long.value = 0.0;
      throw Exception('Location service is disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        lat.value = 0.0;
        long.value = 0.0;
        throw Exception('App does not have location access permission');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      lat.value = 0.0;
      long.value = 0.0;
      throw Exception('App does not have location access permission');
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      lat.value = position.latitude;
      long.value = position.longitude;
      liveLocation();
    } catch (e) {
      lat.value = 0.0;
      long.value = 0.0;
      throw Exception('Error getting current location: $e');
    }
  }

  /// Gets the current latitude.
  double getLat() {
    return lat.value;
  }

  /// Gets the current longitude.
  double getLong() {
    return long.value;
  }

  /// Starts a stream to get live location updates.
  void liveLocation() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 10,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        lat.value = position.latitude;
        long.value = position.longitude;
      },
      onError: (Object error, StackTrace) {
        lat.value = 0.0;
        long.value = 0.0;
      },
    );
  }
}

/// Converts degrees to radians.
double radians(double degrees) {
  return degrees * (pi / 180.0);
}

/// Calculates the distance between two geographical coordinates using the Haversine formula.
double calculateDistance(double lat1, double lat2, double lon1, double lon2) {
  const double earthRadius = 6371; // Radius of Earth in kilometers

  // Convert degrees to radians
  lat1 = radians(lat1);
  lat2 = radians(lat2);
  lon1 = radians(lon1);
  lon2 = radians(lon2);

  // Haversine formula
  double dlon = lon2 - lon1;
  double dlat = lat2 - lat1;
  double a =
      pow(sin(dlat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dlon / 2), 2);

  double c = 2 * asin(sqrt(a));

  // Calculate the distance in kilometers
  double distance = earthRadius * c;

  return distance;
}

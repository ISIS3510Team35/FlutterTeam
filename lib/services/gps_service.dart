import 'package:geolocator/geolocator.dart';
import 'dart:math';

class GPS {
  factory GPS() => _singleton;
  static final GPS _singleton = GPS._internal();
  static var lat = 0.0;
  static var long = 0.0;

  GPS._internal();

  void getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
        lat = 0.0;
        long = 0.0;
      return Future.error('Servicio de localización deshabilitado');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        lat = 0.0;
        long = 0.0;
        return Future.error(
            'La app no tiene permiso para acceder a la ubicación');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      lat = 0.0;
      long = 0.0;
      return Future.error(
          'La app no tiene permiso para acceder a la ubicación');
    }
    Geolocator.getCurrentPosition().then((value) {
      lat = value.latitude;
      long = value.longitude;
      liveLocation();
    });
  }

  double getLat() {
    return lat;
  }

  double getLong() {
    return long;
  }

  void liveLocation() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      lat = position.latitude;
      long = position.longitude;
    });
  }
}

double radians(double degrees) {
  return degrees * (pi / 180.0);
}

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

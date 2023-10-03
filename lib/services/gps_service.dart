import 'package:geolocator/geolocator.dart';

class GPS{
  factory GPS() => _singleton;
  static final GPS _singleton = GPS._internal();
  static var lat = 0.0;
  static var long = 0.0;
  
  GPS._internal();

  void getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      return Future.error('Servicio de localización deshabilitado');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission==LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission==LocationPermission.denied){
        return Future.error('La app no tiene permiso para acceder a la ubicación');
      }
    }
    if(permission==LocationPermission.deniedForever){
      return Future.error('La app no tiene permiso para acceder a la ubicación');
    }
    Geolocator.getCurrentPosition().then((value) {
      lat = value.latitude;
      long = value.longitude;
      liveLocation();
    });
    

  }
  double getLat(){
    return lat;
  }
  double getLong(){
    return long;
  }
  
  void liveLocation(){
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
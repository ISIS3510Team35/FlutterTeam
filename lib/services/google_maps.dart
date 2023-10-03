import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  MapUtils._();

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    Uri uri = Uri.parse(googleUrl); // Convert the String to a Uri
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri); // Pass the Uri as a String
    } else {
      throw 'Could not open the map.';
    }
  }
}

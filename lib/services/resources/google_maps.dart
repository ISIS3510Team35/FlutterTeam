import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  MapUtils._(); // Private constructor to prevent instantiation

  static final MapUtils _instance = MapUtils._();

  factory MapUtils() => _instance;

  /// Opens the map application with the specified [latitude] and [longitude].
  Future<void> openMap(double latitude, double longitude) async {
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final uri = Uri.parse(googleMapsUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not open the map.';
    }
  }
}

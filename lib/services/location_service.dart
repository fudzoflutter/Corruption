import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Joylashuv xizmati yoqilmagan");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse && 
            permission != LocationPermission.always) {
          throw Exception("Lokatsiya ruxsati rad etilgan");
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'address': "${place.country}, ${place.administrativeArea}, "
                     "${place.locality}, ${place.street}",
          'fullAddress': [
            place.name,
            place.street,
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((part) => part != null && part.isNotEmpty).join(', '),
        };
      } else {
        return {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'address': "${position.latitude}, ${position.longitude}",
          'fullAddress': "${position.latitude}, ${position.longitude}",
        };
      }
    } catch (e) {
      throw Exception("Joylashuvni olishda xatolik: ${e.toString()}");
    }
  }
}
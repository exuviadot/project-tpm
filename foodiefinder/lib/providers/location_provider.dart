import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:geolocator/geolocator.dart';

part 'location_provider.g.dart';

class UserLocation {
  final double latitude;
  final double longitude;
  UserLocation(this.latitude, this.longitude);
}

@riverpod
class LocationNotifier extends _$LocationNotifier {
  @override
  Future<UserLocation?> build() async {
    return _determinePosition();
  }

  Future<UserLocation?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition();
    return UserLocation(position.latitude, position.longitude);
  }
}

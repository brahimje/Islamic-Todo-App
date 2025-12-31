import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Service for handling location permissions and getting user location
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check and request location permission, with platform-specific error handling
  Future<LocationPermission> checkAndRequestPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission;
    } catch (e) {
      // Catch platform exceptions and return denied
      return LocationPermission.denied;
    }
  }

  /// Get current location with robust error handling and platform-specific messages
  Future<LocationResult> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        String platformHint = '';
        // Platform-specific instructions
        if (GeolocatorPlatform.instance is GeolocatorPlatform) {
          // No-op, fallback
        }
        // Add more platform-specific hints if needed
        return LocationResult.error('Location services are disabled. Please enable them in your device settings. $platformHint');
      }

      // Check permission
      final permission = await checkAndRequestPermission();
      if (permission == LocationPermission.denied) {
        return LocationResult.error('Location permission denied. Please grant permission to get accurate prayer times.');
      }
      if (permission == LocationPermission.deniedForever) {
        return LocationResult.error('Location permission permanently denied. Please enable it in your app settings.');
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // Try to get address from coordinates
      String? locationName;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final parts = <String>[];
          if (place.locality != null && place.locality!.isNotEmpty) {
            parts.add(place.locality!);
          }
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
            parts.add(place.administrativeArea!);
          }
          if (place.country != null && place.country!.isNotEmpty) {
            parts.add(place.country!);
          }
          locationName = parts.join(', ');
        }
      } catch (e) {
        // Continue without location name, but log error if needed
      }

      return LocationResult.success(
        latitude: position.latitude,
        longitude: position.longitude,
        locationName: locationName,
      );
    } on PermissionDeniedException catch (e) {
      return LocationResult.error('Location permission denied: ${e.toString()}');
    } on LocationServiceDisabledException catch (e) {
      return LocationResult.error('Location services are disabled: ${e.toString()}');
    } catch (e) {
      // General fallback for any other error
      return LocationResult.error('Failed to get location. Please check your permissions and try again. (${e.runtimeType}: ${e.toString()})');
    }
  }

  /// Get location name from coordinates
  Future<String?> getLocationName(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[];
        if (place.locality != null && place.locality!.isNotEmpty) {
          parts.add(place.locality!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          parts.add(place.country!);
        }
        return parts.join(', ');
      }
    } catch (e) {
    }
    return null;
  }

  /// Get coordinates from location name (city search)
  Future<LocationResult> searchLocation(String query) async {
    try {
      final locations = await locationFromAddress(query);
      
      if (locations.isNotEmpty) {
        final location = locations.first;
        final locationName = await getLocationName(
          location.latitude,
          location.longitude,
        );
        
        return LocationResult.success(
          latitude: location.latitude,
          longitude: location.longitude,
          locationName: locationName ?? query,
        );
      }
      
      return LocationResult.error('Location not found. Try a different search term.');
    } catch (e) {
      return LocationResult.error('Failed to search location: ${e.toString()}');
    }
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Calculate distance between two points in kilometers
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    ) / 1000; // Convert to kilometers
  }
}

/// Result class for location operations
class LocationResult {
  final bool isSuccess;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String? errorMessage;

  LocationResult._({
    required this.isSuccess,
    this.latitude,
    this.longitude,
    this.locationName,
    this.errorMessage,
  });

  factory LocationResult.success({
    required double latitude,
    required double longitude,
    String? locationName,
  }) {
    return LocationResult._(
      isSuccess: true,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
    );
  }

  factory LocationResult.error(String message) {
    return LocationResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}

/// Predefined cities for manual selection
class PredefinedCity {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  const PredefinedCity({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  String get displayName => '$name, $country';

  static const List<PredefinedCity> cities = [
    // Middle East
    PredefinedCity(name: 'Makkah', country: 'Saudi Arabia', latitude: 21.4225, longitude: 39.8262),
    PredefinedCity(name: 'Madinah', country: 'Saudi Arabia', latitude: 24.5247, longitude: 39.5692),
    PredefinedCity(name: 'Riyadh', country: 'Saudi Arabia', latitude: 24.7136, longitude: 46.6753),
    PredefinedCity(name: 'Jeddah', country: 'Saudi Arabia', latitude: 21.5433, longitude: 39.1728),
    PredefinedCity(name: 'Dubai', country: 'UAE', latitude: 25.2048, longitude: 55.2708),
    PredefinedCity(name: 'Abu Dhabi', country: 'UAE', latitude: 24.4539, longitude: 54.3773),
    PredefinedCity(name: 'Doha', country: 'Qatar', latitude: 25.2854, longitude: 51.5310),
    PredefinedCity(name: 'Kuwait City', country: 'Kuwait', latitude: 29.3759, longitude: 47.9774),
    PredefinedCity(name: 'Manama', country: 'Bahrain', latitude: 26.2285, longitude: 50.5860),
    PredefinedCity(name: 'Muscat', country: 'Oman', latitude: 23.5880, longitude: 58.3829),
    PredefinedCity(name: 'Amman', country: 'Jordan', latitude: 31.9454, longitude: 35.9284),
    PredefinedCity(name: 'Jerusalem', country: 'Palestine', latitude: 31.7683, longitude: 35.2137),
    PredefinedCity(name: 'Beirut', country: 'Lebanon', latitude: 33.8938, longitude: 35.5018),
    PredefinedCity(name: 'Damascus', country: 'Syria', latitude: 33.5138, longitude: 36.2765),
    PredefinedCity(name: 'Baghdad', country: 'Iraq', latitude: 33.3152, longitude: 44.3661),
    
    // North Africa
    PredefinedCity(name: 'Cairo', country: 'Egypt', latitude: 30.0444, longitude: 31.2357),
    PredefinedCity(name: 'Alexandria', country: 'Egypt', latitude: 31.2001, longitude: 29.9187),
    PredefinedCity(name: 'Casablanca', country: 'Morocco', latitude: 33.5731, longitude: -7.5898),
    PredefinedCity(name: 'Rabat', country: 'Morocco', latitude: 34.0209, longitude: -6.8416),
    PredefinedCity(name: 'Tunis', country: 'Tunisia', latitude: 36.8065, longitude: 10.1815),
    PredefinedCity(name: 'Algiers', country: 'Algeria', latitude: 36.7538, longitude: 3.0588),
    PredefinedCity(name: 'Tripoli', country: 'Libya', latitude: 32.8872, longitude: 13.1913),
    
    // South Asia
    PredefinedCity(name: 'Islamabad', country: 'Pakistan', latitude: 33.6844, longitude: 73.0479),
    PredefinedCity(name: 'Karachi', country: 'Pakistan', latitude: 24.8607, longitude: 67.0011),
    PredefinedCity(name: 'Lahore', country: 'Pakistan', latitude: 31.5204, longitude: 74.3587),
    PredefinedCity(name: 'Dhaka', country: 'Bangladesh', latitude: 23.8103, longitude: 90.4125),
    PredefinedCity(name: 'Delhi', country: 'India', latitude: 28.7041, longitude: 77.1025),
    PredefinedCity(name: 'Mumbai', country: 'India', latitude: 19.0760, longitude: 72.8777),
    
    // Southeast Asia
    PredefinedCity(name: 'Jakarta', country: 'Indonesia', latitude: -6.2088, longitude: 106.8456),
    PredefinedCity(name: 'Kuala Lumpur', country: 'Malaysia', latitude: 3.1390, longitude: 101.6869),
    PredefinedCity(name: 'Singapore', country: 'Singapore', latitude: 1.3521, longitude: 103.8198),
    PredefinedCity(name: 'Brunei', country: 'Brunei', latitude: 4.9031, longitude: 114.9398),
    
    // Turkey & Central Asia
    PredefinedCity(name: 'Istanbul', country: 'Turkey', latitude: 41.0082, longitude: 28.9784),
    PredefinedCity(name: 'Ankara', country: 'Turkey', latitude: 39.9334, longitude: 32.8597),
    PredefinedCity(name: 'Tehran', country: 'Iran', latitude: 35.6892, longitude: 51.3890),
    PredefinedCity(name: 'Kabul', country: 'Afghanistan', latitude: 34.5553, longitude: 69.2075),
    PredefinedCity(name: 'Tashkent', country: 'Uzbekistan', latitude: 41.2995, longitude: 69.2401),
    
    // Europe
    PredefinedCity(name: 'London', country: 'UK', latitude: 51.5074, longitude: -0.1278),
    PredefinedCity(name: 'Paris', country: 'France', latitude: 48.8566, longitude: 2.3522),
    PredefinedCity(name: 'Berlin', country: 'Germany', latitude: 52.5200, longitude: 13.4050),
    PredefinedCity(name: 'Amsterdam', country: 'Netherlands', latitude: 52.3676, longitude: 4.9041),
    PredefinedCity(name: 'Brussels', country: 'Belgium', latitude: 50.8503, longitude: 4.3517),
    PredefinedCity(name: 'Stockholm', country: 'Sweden', latitude: 59.3293, longitude: 18.0686),
    PredefinedCity(name: 'Oslo', country: 'Norway', latitude: 59.9139, longitude: 10.7522),
    
    // Americas
    PredefinedCity(name: 'New York', country: 'USA', latitude: 40.7128, longitude: -74.0060),
    PredefinedCity(name: 'Los Angeles', country: 'USA', latitude: 34.0522, longitude: -118.2437),
    PredefinedCity(name: 'Chicago', country: 'USA', latitude: 41.8781, longitude: -87.6298),
    PredefinedCity(name: 'Houston', country: 'USA', latitude: 29.7604, longitude: -95.3698),
    PredefinedCity(name: 'Toronto', country: 'Canada', latitude: 43.6532, longitude: -79.3832),
    PredefinedCity(name: 'Montreal', country: 'Canada', latitude: 45.5017, longitude: -73.5673),
    
    // Africa
    PredefinedCity(name: 'Lagos', country: 'Nigeria', latitude: 6.5244, longitude: 3.3792),
    PredefinedCity(name: 'Nairobi', country: 'Kenya', latitude: -1.2921, longitude: 36.8219),
    PredefinedCity(name: 'Johannesburg', country: 'South Africa', latitude: -26.2041, longitude: 28.0473),
    PredefinedCity(name: 'Khartoum', country: 'Sudan', latitude: 15.5007, longitude: 32.5599),
    
    // Australia
    PredefinedCity(name: 'Sydney', country: 'Australia', latitude: -33.8688, longitude: 151.2093),
    PredefinedCity(name: 'Melbourne', country: 'Australia', latitude: -37.8136, longitude: 144.9631),
  ];
}

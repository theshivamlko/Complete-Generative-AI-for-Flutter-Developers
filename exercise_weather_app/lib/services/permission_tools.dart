import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

class PermissionTools {
  static final Tool permissionTool = Tool(
    functionDeclarations: [
      FunctionDeclaration(
        'check_location_permission',
        'Check if the app currently has permission to access GPS location. '
            'Call this FIRST before trying to get location. '
            'Returns: granted (true/false), denied, permanentlyDenied, status.',
        Schema(SchemaType.object, properties: {}),
      ),
      FunctionDeclaration(
        'request_location_permission',
        'Request permission to access GPS location from the user. '
            'Call this ONLY if check_location_permission shows permission is NOT granted. '
            'This will show a system permission dialog to the user. '
            'Returns: granted (true/false), status, message.',
        Schema(SchemaType.object, properties: {}),
      ),
      FunctionDeclaration(
        'get_current_location',
        'Get the current GPS coordinates (latitude and longitude) of the device. '
            'Call this ONLY AFTER permission is granted. '
            'Returns: latitude, longitude, and coordinates string in "lat,long" format for weather API.',
        Schema(SchemaType.object, properties: {}),
      ),
    ],
  );

  /// Check if location permission is granted
  static Future<String> checkLocationPermission() async {
    try {
      print('Checking location permission...');
      final permission = await Permission.location.status;

      return permission.toString();
    } catch (e) {
      print('Error checking permission: $e');
      return 'Error: Failed to check location permission: ${e.toString()}';
    }
  }

  /// Request location permission from the user
  static Future<String> requestLocationPermission() async {
    try {
      print('Requesting location permission...');
      final status = await Permission.location.request();


      return status.toString();
    } catch (e) {
      print('Error requesting permission: $e');
      return 'Error: Failed to check location permission: ${e.toString()}';

    }
  }

  /// Get current GPS location coordinates
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      print('Getting current location...');

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services disabled');
        return {'error': 'Location services are disabled. Please enable GPS.'};
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print('Permission denied, requesting...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Permission request denied');
          return {'error': 'Location permission denied'};
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('Permission permanently denied');
        return {
          'error':
              'Location permissions are permanently denied. Please enable them in settings.',
        };
      }

      // Get current position
      print('Fetching GPS coordinates...');
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final coordinates = '${position.latitude},${position.longitude}';
      print('Location obtained: $coordinates');

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'heading': position.heading,
        'speed': position.speed,
        'timestamp': position.timestamp.toIso8601String(),
        'coordinates': coordinates,
      };
    } catch (e) {
      print('Error getting location: $e');
      return {'error': 'Failed to get current location: ${e.toString()}'};
    }
  }

  /// Handle function calls from Gemini
  static Future<String> handleFunctionCall(FunctionCall functionCall) async {
    switch (functionCall.name) {
      case 'check_location_permission':
        final result = await checkLocationPermission();
        return jsonEncode(result);

      case 'request_location_permission':
        final result = await requestLocationPermission();
        return jsonEncode(result);

      case 'get_current_location':
        final result = await getCurrentLocation();
        return jsonEncode(result);

      default:
        return jsonEncode({'error': 'Unknown function: ${functionCall.name}'});
    }
  }
}

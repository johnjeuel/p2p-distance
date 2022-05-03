import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:p2p_distance/config/config.dart';

import '../models/direction_model.dart';

class DirectionController {
  static const String _url = 'https://maps.googleapis.com/maps/api/directions/json?';
  final Dio _dio = Dio();

  Future? getDirections({
    required LatLng origin,
    required LatLng destination
}) async {
    final response = await _dio.get(
      _url,
      queryParameters: {
        'origin': '${origin.latitude}, ${origin.longitude}',
        'destination': '${destination.latitude}, ${destination.longitude}',
        'key': googleApiKey
      }
    );
    print(response.data);
    /// Check if response is successful
    if(response.statusCode == 200) {
      return Directions.fromMap(response.data);
    }

  }

}
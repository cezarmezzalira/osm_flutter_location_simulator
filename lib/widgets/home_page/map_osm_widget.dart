import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:map_poc/entities/map_location.dart';
import 'package:map_poc/services/geolocator_services.dart';

class MapOsmWidget extends StatelessWidget {
  final List<MapLocation> locations;

  const MapOsmWidget({super.key, required this.locations});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: GeolocatorServices.getCurrentLocation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        }

        Position currentPosition = snapshot.data as Position;

        return FlutterMap(
          mapController: MapController(),
          options: MapOptions(
            initialCenter: LatLng(
              currentPosition.latitude,
              currentPosition.longitude,
            ),
            initialZoom: 14,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.flutter_map_osrm',
            ),
            MarkerLayer(markers: _buildMarkers()),
            Center(
              child: PolylineLayer(
                polylines: [
                  Polyline(
                    strokeWidth: 3,
                    strokeJoin: StrokeJoin.round,
                    points: [
                      for (var location in locations)
                        LatLng(location.latitude, location.longitude),
                    ],
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            // PolylineBuilderWidget(locations: locations),
          ],
        );
      },
    );
  }

  _buildMarkers() {
    return locations.map((location) {
      return Marker(
        point: LatLng(location.latitude, location.longitude),
        width: 32,
        height: 32,
        child: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(
            IconData(0xe2a0, fontFamily: 'MaterialIcons'),
            color: Colors.white,
            size: 24,
          ),
        ),
      );
    }).toList();
  }
}

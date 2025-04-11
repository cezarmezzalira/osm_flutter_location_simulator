import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'package:map_poc/entities/map_location.dart';
import 'package:map_poc/services/geolocator_services.dart';

class MapOsmWidget extends StatelessWidget {
  final List<MapLocation> locations;
  final MapController mapController; // Adicione um MapController

  const MapOsmWidget({
    super.key,
    required this.locations,
    required this.mapController,
  });

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

        // Define o centro inicial baseado no último ponto da lista, ou um padrão
        LatLng initialCenter =
            locations.isNotEmpty
                ? LatLng(locations.last.latitude, locations.last.longitude)
                : LatLng(currentPosition.latitude, currentPosition.longitude);

        // Se tivermos localizações, move o mapa para o último ponto adicionado
        // Use addPostFrameCallback para garantir que o controller esteja pronto
        if (locations.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Verifica se o controller está pronto
            mapController.move(initialCenter, mapController.camera.zoom);
          });
        }
        return FlutterMap(
          mapController: mapController,
          options: MapOptions(initialCenter: initialCenter, initialZoom: 14),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.flutter_map_osrm',
            ),
            // Só mostra marcadores se houver localizações
            if (locations.isNotEmpty) MarkerLayer(markers: _buildMarkers()),
            // Só mostra a polilinha se houver pelo menos 2 pontos
            if (locations.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    strokeWidth: 3,
                    strokeJoin: StrokeJoin.round,
                    points:
                        locations
                            .map((loc) => LatLng(loc.latitude, loc.longitude))
                            .toList(),
                    color: Colors.blue.shade800, // Cor ajustada
                  ),
                ],
              ),
            // PolylineBuilderWidget(locations: locations),
          ],
        );
      },
    );
  }

  List<Marker> _buildMarkers() {
    if (locations.isEmpty) {
      return [];
    }

    List<MapLocation> markersToShow = [];
    // Mostra marcador no primeiro ponto
    markersToShow.add(locations.first);
    // Se houver mais de um ponto, mostra marcador no último também
    if (locations.length > 1) {
      markersToShow.add(locations.last);
    }

    return markersToShow.map((location) {
      return Marker(
        point: LatLng(location.latitude, location.longitude),
        width: 32,
        height: 32,
        child: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.location_pin, color: Colors.white, size: 24),
        ),
      );
    }).toList();
  }
}

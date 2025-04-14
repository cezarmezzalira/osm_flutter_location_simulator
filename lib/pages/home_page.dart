import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_poc/entities/map_location.dart';
import 'package:map_poc/services/geolocator_services.dart';
import 'package:map_poc/widgets/home_page/map_osm_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MapLocation> locations = [];

  // Lista de localizações que serão exibidas no mapa (começa vazia)
  List<MapLocation> _displayedLocations = [];

  // Lista "fonte" simulando os dados do sistema externo
  final List<MapLocation> _sourceLocations = [
    MapLocation(latitude: -26.216650, longitude: -52.670818),
    MapLocation(latitude: -26.217155, longitude: -52.672784),
    MapLocation(latitude: -26.217284, longitude: -52.673620),
    MapLocation(latitude: -26.218371, longitude: -52.673312),
    MapLocation(latitude: -26.220478, longitude: -52.672442),
    MapLocation(latitude: -26.222499, longitude: -52.671573),
    MapLocation(latitude: -26.223249, longitude: -52.672618),
    MapLocation(latitude: -26.224383, longitude: -52.675010),
    MapLocation(latitude: -26.225388, longitude: -52.677110),
    MapLocation(latitude: -26.226325, longitude: -52.678970),
    MapLocation(latitude: -26.227769, longitude: -52.679893),
    MapLocation(latitude: -26.228194, longitude: -52.680519),
    MapLocation(latitude: -26.229005, longitude: -52.682248),
    MapLocation(latitude: -26.229534, longitude: -52.683328),
    MapLocation(latitude: -26.230471, longitude: -52.684834),
    MapLocation(latitude: -26.231486, longitude: -52.686500),
  ];

  Timer? _locationAddTimer; // Timer para adicionar localizações
  int _currentSourceIndex = 0; // Índice da próxima localização a ser adicionada
  final MapController _mapController =
      MapController(); // Controller para o mapa
  @override
  void initState() {
    super.initState();
  }

  void _startAddingLocations() {
    // Cancela timer anterior, se houver
    _locationAddTimer?.cancel();

    // Configura o timer para executar a cada 5 segundos
    _locationAddTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _addNextLocationFromSource();
    });
  }

  void _addNextLocationFromSource() {
    // Verifica se ainda há localizações na lista fonte
    if (_currentSourceIndex < _sourceLocations.length) {
      final nextLocation = _sourceLocations[_currentSourceIndex];

      // Verifica se o widget ainda está montado
      if (mounted) {
        setState(() {
          // Adiciona a próxima localização à lista exibida
          _displayedLocations = [..._displayedLocations, nextLocation];
        });
        // Move o mapa para a nova localização adicionada (opcional)
        _mapController.move(
          LatLng(nextLocation.latitude, nextLocation.longitude),
          _mapController.camera.zoom, // Mantém o zoom atual
        );
      }
      _currentSourceIndex++; // Avança para o próximo índice
    } else {
      // Se não houver mais localizações, para o timer
      _locationAddTimer?.cancel();
      print("Todas as localizações foram adicionadas."); // Log opcional
    }
  }

  @override
  void dispose() {
    // Cancela o timer ao sair da tela para evitar memory leaks
    _locationAddTimer?.cancel();
    _mapController.dispose(); // Libera recursos do MapController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: FutureBuilder<bool>(
        future: GeolocatorServices.checkPermission(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            var errorMessage = snapshot.error.toString();
            return Center(child: Text(errorMessage));
          }

          // Inicia o processo de adicionar localizações
          _startAddingLocations();

          bool hasPermission = snapshot.data!;

          if (!hasPermission) {
            return const Center(child: Text('Permission denied'));
          }

          return MapOsmWidget(
            locations: _displayedLocations,
            mapController: _mapController,
          );
        },
      ),
    );
  }
}

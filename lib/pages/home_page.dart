import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    locations = [
      MapLocation(
        latitude: -37.32169083949532,
        longitude: -59.132343586491906,
      ),
      MapLocation(
        latitude: -37.32479766767583,
        longitude: -59.140583273672166,
      ),
      MapLocation(
        latitude: -37.32574681915889,
        longitude: -59.135188272840836,
      ),
    ];
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
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text('Error'),
              );
            }

            bool hasPermission = snapshot.data!;

            if (!hasPermission) {
              return const Center(
                child: Text('Permission denied'),
              );
            }

            return MapOsmWidget(locations: locations);
          }),
    );
  }
}

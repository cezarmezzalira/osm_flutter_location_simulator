class MapLocation {
  final double latitude;
  final double longitude;
  final DateTime? dateTime;

  MapLocation({
    required this.latitude,
    required this.longitude,
    this.dateTime,
  });

  MapLocation copyWith({
    double? latitude,
    double? longitude,
    DateTime? dateTime,
  }) {
    return MapLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      dateTime: dateTime ?? this.dateTime,
    );
  }

  toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'dateTime': dateTime,
    };
  }

  factory MapLocation.fromMap(Map<String, dynamic> map) {
    return MapLocation(
      latitude: map['latitude'],
      longitude: map['longitude'],
      dateTime: map['dateTime'],
    );
  }
}

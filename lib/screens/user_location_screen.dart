import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;

class MapScreenUser extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreenUser> {
  LatLng userLocation = const LatLng(24.0975, 32.8999); // Set to Aswan, Egypt
  List<Map<String, dynamic>> nodes = [];
  Map<String, dynamic>? nearestNode;
  List<LatLng> routeCoordinates = [];
  LatLng? selectedLocation;
  double zoomLevel = 15.0;

  @override
  void initState() {
    super.initState();
    initializeMap();
  }

  Future<void> initializeMap() async {
    List<Map<String, dynamic>> loadedNodes = await loadNodesFromExcel();

    setState(() {
      nodes = loadedNodes;
    });
  }

  Future<List<Map<String, dynamic>>> loadNodesFromExcel() async {
    ByteData data = await rootBundle.load('assets/NodesPlaces_DS(4).xlsx');
    var bytes = data.buffer.asUint8List();
    var excel = Excel.decodeBytes(bytes);

    List<Map<String, dynamic>> nodeList = [];
    for (var row in excel.tables[excel.tables.keys.first]!.rows.skip(1)) {
      if (row.length >= 3 &&
          row[0] != null &&
          row[1] != null &&
          row[2] != null) {
        double? latitude = double.tryParse(row[0]?.value.toString() ?? '');
        double? longitude = double.tryParse(row[1]?.value.toString() ?? '');
        String name = row[2]?.value.toString() ?? '';

        if (latitude != null && longitude != null && name.isNotEmpty) {
          nodeList.add({
            'latitude': latitude,
            'longitude': longitude,
            'nodes': name,
          });
        }
      }
    }
    if (nodeList.isEmpty) {
      throw Exception("No valid nodes found in the Excel file.");
    }
    return nodeList;
  }

  Map<String, dynamic>? findNearestNode(LatLng userLocation) {
    double shortestDistance = double.infinity;
    Map<String, dynamic>? nearestNode;

    for (var node in nodes) {
      double distance = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        node['latitude'],
        node['longitude'],
      );
      if (distance < shortestDistance) {
        shortestDistance = distance;
        nearestNode = node;
      }
    }
    return nearestNode;
  }

  Future<List<LatLng>> calculateRoute(
      LatLng userLocation, Map<String, dynamic> nearestNode) async {
    final dio = Dio();
    try {
      final response = await dio.get(
          'http://router.project-osrm.org/route/v1/driving/${userLocation.longitude},${userLocation.latitude};${nearestNode['longitude']},${nearestNode['latitude']}',
          queryParameters: {'geometries': 'geojson'});

      if (response.statusCode == 200 &&
          response.data['routes'] != null &&
          response.data['routes'].isNotEmpty) {
        List coordinates =
            response.data['routes'][0]['geometry']['coordinates'];
        return coordinates
            .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
            .toList();
      } else {
        throw Exception("Failed to fetch route.");
      }
    } catch (e) {
      throw Exception("Error fetching route: $e");
    }
  }

  void _onTap(LatLng tappedLocation) {
    setState(() {
      selectedLocation = tappedLocation;
    });
  }

  void _getNearestNodeAndRoute() async {
    if (selectedLocation != null) {
      setState(() {
        routeCoordinates.clear(); // Clear the previous route
      });

      nearestNode = findNearestNode(selectedLocation!);
      if (nearestNode != null) {
        try {
          routeCoordinates =
              await calculateRoute(selectedLocation!, nearestNode!);
          setState(() {});
        } catch (e) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Route Error"),
              content: const Text("Failed to calculate the route. Please try again."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text("Map View")),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: userLocation, // Set the initial map center
              zoom: 15.0, // Initial zoom level
              minZoom: 5.0, // Minimum zoom level
              maxZoom: 18.0, // Maximum zoom level
              interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag | InteractiveFlag.doubleTapZoom, 
              onTap: (tapPosition, point) {
                _onTap(point); // Handle tap logic (if needed)
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  if (selectedLocation != null)
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: selectedLocation!,
                      builder: (ctx) => const Icon(Icons.location_pin, color: Colors.red),
                    ),
                  if (nearestNode != null)
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(nearestNode!['latitude'], nearestNode!['longitude']),
                      builder: (ctx) => const Icon(Icons.location_pin, color: Colors.blue),
                    ),
                  ...nodes.map((node) {
                    return Marker(
                      width: 30.0,
                      height: 30.0,
                      point: LatLng(node['latitude'], node['longitude']),
                      builder: (ctx) => Image.asset(
                        'assets/images/recycle_bin.png',
                        width: 0.1,
                        height: 0.1,
                      ),
                    );
                  }),
                ],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routeCoordinates,
                    strokeWidth: 4.0,
                    color: const Color.fromARGB(255, 0, 0, 255),
                  ),
                ],
              ),
            ],
          )
          // Positioned(
          //   bottom: 20,
          //   left: screenWidth * 0.05,
          //   right: screenWidth * 0.05,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       FloatingActionButton(
          //         heroTag: "current_location",
          //         onPressed: () {
          //           // Logic to fetch and center on user's current location
          //         },
          //         backgroundColor: Colors.green,
          //         child: const Icon(Icons.my_location, color: Colors.white),
          //       ),
          //       FloatingActionButton(
          //         heroTag: "zoom_out",
          //         onPressed: () {
          //           setState(() {
          //             zoomLevel = (zoomLevel - 1).clamp(1.0, 18.0);
          //           });
          //         },
          //         backgroundColor: Colors.green,
          //         child: const Icon(Icons.zoom_out, color: Colors.white),
          //       ),
          //       FloatingActionButton(
          //         heroTag: "zoom_in",
          //         onPressed: () {
          //           setState(() {
          //             zoomLevel = (zoomLevel + 1).clamp(1.0, 18.0);
          //           });
          //         },
          //         backgroundColor: Colors.green,
          //         child: const Icon(Icons.zoom_in, color: Colors.white),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getNearestNodeAndRoute,
        tooltip: "Start",
        child: Icon(Icons.directions),
      ),
    );
  }
}

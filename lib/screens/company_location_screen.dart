import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;

class MapScreenCompany extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreenCompany> {
  List<Map<String, dynamic>> nodes = [];
  Map<String, List<String>> adjacencyList = {};
  Map<String, double> population = {};
  String? selectedStartNode;
  String? selectedGoalNode;
  List<String> path = [];
  List<LatLng> pathCoordinates = [];

  @override
  void initState() {
    super.initState();
    loadNodesFromExcel();
  }

  Future<void> loadNodesFromExcel() async {
    try {
      ByteData data = await rootBundle.load('assets/NodesPlaces_DS(4).xlsx');
      var bytes = data.buffer.asUint8List();
      var excel = Excel.decodeBytes(bytes);

      List<Map<String, dynamic>> loadedNodes = [];
      Map<String, List<String>> loadedAdjacencyList = {};
      Map<String, double> loadedPopulation = {};

      for (var row in excel.tables[excel.tables.keys.first]!.rows.skip(1)) {
        if (row[0] != null && row[1] != null && row[2] != null) {
          String nodeName = row[2]?.value.toString() ?? '';
          double latitude = double.parse(row[0]?.value.toString() ?? '0');
          double longitude = double.parse(row[1]?.value.toString() ?? '0');
          double nodePopulation =
              double.tryParse(row[3]?.value.toString() ?? '0') ?? 0;

          loadedNodes.add({'nodes': nodeName, 'latitude': latitude, 'longitude': longitude});
          loadedPopulation[nodeName] = nodePopulation;

          String neighborsRaw = row[4]?.value.toString() ?? '';
          List<String> neighbors = neighborsRaw.isNotEmpty
              ? neighborsRaw.split(', ').map((e) => e.trim()).toList()
              : [];
          loadedAdjacencyList[nodeName] = neighbors;
        }
      }

      setState(() {
        nodes = loadedNodes;
        adjacencyList = loadedAdjacencyList;
        population = loadedPopulation;
      });
    } catch (e) {
      debugPrint("Error loading Excel data: $e");
    }
  }

  double haversine(LatLng point1, LatLng point2) {
    const R = 6371; // Earth's radius in kilometers
    double dLat = (point2.latitude - point1.latitude) * pi / 180;
    double dLon = (point2.longitude - point1.longitude) * pi / 180;

    double lat1 = point1.latitude * pi / 180;
    double lat2 = point2.latitude * pi / 180;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c * 1000; // Distance in meters
  }

  double heuristic(String node) {
    double wastePercentage = 0.1 * (population[node] ?? 0);
    return wastePercentage > 0 ? 1 / wastePercentage : double.infinity;
  }

  Future<List<String>> aStar(String startNode, String goalNode) async {
    Map<String, double> gScore = {startNode: 0};
    Map<String, double> fScore = {startNode: heuristic(startNode)};
    Map<String, String?> cameFrom = {};
    List<String> openSet = [startNode];

    while (openSet.isNotEmpty) {
      openSet.sort((a, b) => fScore[a]!.compareTo(fScore[b]!));
      String currentNode = openSet.removeAt(0);

      if (currentNode == goalNode) {
        List<String> path = [];
        while (cameFrom[currentNode] != null) {
          path.insert(0, currentNode);
          currentNode = cameFrom[currentNode]!;
        }
        path.insert(0, startNode);
        return path;
      }

      for (String neighbor in adjacencyList[currentNode] ?? []) {
        var currentNodeDetails = nodes.firstWhere(
          (n) => n['nodes'] == currentNode,
          orElse: () => {'latitude': 0.0, 'longitude': 0.0, 'nodes': ''},
        );

        if (currentNodeDetails['nodes'] == '') {
          continue;
        }

        var neighborDetails = nodes.firstWhere(
          (n) => n['nodes'] == neighbor,
          orElse: () => {'latitude': 0.0, 'longitude': 0.0, 'nodes': ''},
        );

        if (neighborDetails['nodes'] == '') {
          continue;
        }

        double tentativeGScore = gScore[currentNode]! +
            haversine(
              LatLng(currentNodeDetails['latitude'], currentNodeDetails['longitude']),
              LatLng(neighborDetails['latitude'], neighborDetails['longitude']),
            );

        if (tentativeGScore < (gScore[neighbor] ?? double.infinity)) {
          cameFrom[neighbor] = currentNode;
          gScore[neighbor] = tentativeGScore;
          fScore[neighbor] = tentativeGScore + heuristic(neighbor);

          if (!openSet.contains(neighbor)) openSet.add(neighbor);
        }
      }
    }
    return [];
  }

  Future<void> findPath() async {
    if (selectedStartNode != null && selectedGoalNode != null) {
      List<String> calculatedPath = await aStar(selectedStartNode!, selectedGoalNode!);

      if (calculatedPath.isNotEmpty) {
        List<LatLng> calculatedPathCoordinates = calculatedPath
            .map((node) => LatLng(
                  nodes.firstWhere((n) => n['nodes'] == node)['latitude'],
                  nodes.firstWhere((n) => n['nodes'] == node)['longitude'],
                ))
            .toList();

        setState(() {
          path = calculatedPath;
          pathCoordinates = calculatedPathCoordinates;
        });
      }
    }
  }

  void showPathDetails() {
  List<Map<String, dynamic>> details = [];

  for (int i = 0; i < path.length - 1; i++) {
    String currentNode = path[i];
    String nextNode = path[i + 1];

    var currentDetails = nodes.firstWhere((n) => n['nodes'] == currentNode);
    var nextDetails = nodes.firstWhere((n) => n['nodes'] == nextNode);

    double distance = haversine(
      LatLng(currentDetails['latitude'], currentDetails['longitude']),
      LatLng(nextDetails['latitude'], nextDetails['longitude']),
    );

    double waste = (population[currentNode] ?? 0) / 10;

    details.add({
      'from': currentNode,
      'to': nextNode,
      'distance': distance,
      'waste': waste.isFinite ? waste.toStringAsFixed(2) : 'N/A',
    });
  }

  // Display the details in a dialog
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Path Details"),
        content: SingleChildScrollView(
          child: Column(
            children: details.map((detail) {
              return ListTile(
                title: Text("From: ${detail['from']} to: ${detail['to']}"),
                subtitle: Text(
                  "Distance: ${(detail['distance'] / 1000).toStringAsFixed(2)} km\n"
                  "Waste: ${detail['waste']}",
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Close"),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('RecycleLink A* Pathfinding')),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                buildSearchableDropdown(
                  hint: "Select Start Node",
                  value: selectedStartNode,
                  onChanged: (value) => setState(() => selectedStartNode = value),
                ),
                buildSearchableDropdown(
                  hint: "Select Goal Node",
                  value: selectedGoalNode,
                  onChanged: (value) => setState(() => selectedGoalNode = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: LatLng(24.0889, 32.8997),
                zoom: 13,
                onTap: (_, __) => showPathDetails(),
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: buildMarkers(),
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: pathCoordinates,
                      strokeWidth: 4.0,
                      color: Colors.blue[900]!,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: findPath,
        child: Icon(Icons.directions),
        tooltip: "Find Route",
      ),
    );
  }

  DropdownButton<String> buildSearchableDropdown({
    required String hint,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return DropdownButton<String>(
      isExpanded: true,
      hint: Text(hint, style: TextStyle(color: Colors.green)),
      value: value,
      items: nodes
          .map<DropdownMenuItem<String>>((node) => DropdownMenuItem<String>(
                value: node['nodes'],
                child: Text(node['nodes']),
              ))
          .toList(),
      onChanged: (newValue) {
        setState(() {
          if (newValue != (selectedStartNode == value ? selectedGoalNode : selectedStartNode)) {
            onChanged(newValue);
          }
        });
      },
    );
  }

  List<Marker> buildMarkers() {
  return nodes.map((node) {
    Widget markerIcon;

    if (node['nodes'] == selectedStartNode) {
      markerIcon = Icon(Icons.location_pin, color: Colors.blue[900]);
    } else if (node['nodes'] == selectedGoalNode) {
      markerIcon = Icon(Icons.location_pin, color: Colors.red);
    } else {
      markerIcon = Image.asset(
        'assets/images/recycle_bin.png',
        width: 30, // You can adjust the size of the image marker
        height: 30,
      );
    }

    return Marker(
      point: LatLng(node['latitude'], node['longitude']),
      builder: (_) => markerIcon,
    );
  }).toList();
}

}
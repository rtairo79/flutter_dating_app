import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // 1. Made mapController nullable for safety
  GoogleMapController? mapController; 
  
  // 2. Used a default, non-(0,0) location (e.g., London)
  LatLng userLocation = const LatLng(51.5074, 0.1278); 

  @override
  void initState() {
    super.initState();
    // Start location fetching early
    // We still call _getUserLocation in _onMapCreated to ensure mapController is ready
  }

  @override
  void dispose() {
    mapController?.dispose(); // 3. Added dispose
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getUserLocation(); // Call after controller is ready
  }

  // New helper function for handling permissions
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled. Please enable them.')),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions denied.')),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions permanently denied. Please enable them in app settings.')),
      );
      return false;
    }
    return true; // Permissions granted
  }

  void _getUserLocation() async {
    // 4. Use the permission handler
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    // 5. Check if mapController is ready before using it
    if (mapController == null) return; 

    // Now safe to get location
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (!mounted) return;

      final newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        userLocation = newLocation;
        // Use the nullable operator for safety, though checked above
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(userLocation, 14),
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dating App Map')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        // The initial camera position uses the default location until userLocation updates
        initialCameraPosition: CameraPosition(target: userLocation, zoom: 14),
        myLocationEnabled: true, // Enable the blue dot for current location
        markers: {
          Marker(markerId: const MarkerId('user'), position: userLocation),
        },
      ),
    );
  }
}
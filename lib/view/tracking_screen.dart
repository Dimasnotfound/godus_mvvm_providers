import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:godus/viewModel/tracking_view_model.dart';
import 'package:provider/provider.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  @override
  void initState() {
    super.initState();
    // Panggil method untuk mengambil data latitude dan longitude dari database
    Provider.of<TrackingViewModel>(context, listen: false)
        .fetchGooglePlexLatLng();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TrackingViewModel>(
        builder: (context, model, child) {
          final googlePlexLatLng = model.googlePlexLatLng;
          return googlePlexLatLng != null
              ? GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: googlePlexLatLng,
                    zoom: 18,
                  ),
                  markers: Set<Marker>.from([
                    Marker(
                      markerId: MarkerId("googlePlexMarker"),
                      position: googlePlexLatLng,
                      infoWindow: InfoWindow(
                        title: "Googleplex",
                        snippet: "Google Headquarters",
                      ),
                    ),
                  ]),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }
}

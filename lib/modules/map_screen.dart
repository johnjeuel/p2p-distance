import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:p2p_distance/controllers/direction_controller.dart';
import 'package:p2p_distance/models/direction_model.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Marker? _origin;
  Marker? _destination;
  Directions? _info;

  Location currentLocation = Location();

  final _initialCameraPosition = const CameraPosition(
    target: LatLng(45.521563, -122.677433),
    zoom: 11.0,
  );

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void getLocation() async{
    var location = await currentLocation.getLocation();
    currentLocation.onLocationChanged.listen((LocationData loc){
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(loc.latitude ?? 0.0,loc.longitude?? 0.0),
        zoom: 11,
    )));
      print(loc.latitude);
      print(loc.longitude);
      setState(() {

      });
    });
  }

  void _addMarker(LatLng pos) async {
    if(_origin == null || (_origin != null && _destination != null)) {
      /// Origin is not set OR Origin/Destination are both set
      /// Set origin
      setState(() {
        _origin = Marker(
            markerId: const MarkerId('origin'),
            infoWindow: const InfoWindow(title: 'Origin'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            position: pos
        );

        /// Reset destination
        _destination = null;
        /// Reset info
        _info = null;
      });
    } else {
      /// Origin is already set
      /// Set destination
      setState(() {
        _destination = Marker(
            markerId: const MarkerId('destination'),
            infoWindow: const InfoWindow(title: 'Destination'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            position: pos
        );
      });

      /// Get directions
      final _directions = await DirectionController().getDirections(
          origin: _origin!.position,
          destination: _destination!.position);
      setState(() {
        _info = _directions;
      });
    }
  }


  @override
  void initState(){
    super.initState();

  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.yellowAccent,
          foregroundColor: Colors.black,
          onPressed: () => mapController.animateCamera(
              _info != null
                  ? CameraUpdate.newLatLngBounds(_info!.bounds, 100.0)
                  : CameraUpdate.newCameraPosition(_initialCameraPosition)
          ),
          // onPressed: () => getLocation(),
          child: const Icon(Icons.center_focus_strong),
        ),
        appBar: AppBar(
          title: Text('P2P Distance', style: GoogleFonts.bakbakOne(fontSize: 20, color: Colors.red[900]),),
          backgroundColor: Colors.white,
          actions: [
            if(_origin != null)
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.green,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700)
                  ),
                  onPressed: () => mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                          CameraPosition(
                              target: _origin!.position,
                              zoom: 14.5,
                              tilt: 50.0
                          )
                      )
                  ),
                  child: const Text('Origin')),
            if(_destination != null)
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.blue,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700)
                  ),
                  onPressed: () => mapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                          CameraPosition(
                              target: _destination!.position,
                              zoom: 14.5,
                              tilt: 50.0
                          )
                      )
                  ),
                  child: const Text('Destination')),
          ],
        ),
        body: Stack(
          children: [
            GoogleMap(
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: _onMapCreated,
              initialCameraPosition: _initialCameraPosition,
              markers: {
                if(_origin != null) _origin!,
                if(_destination != null) _destination!
              },
              onTap: _addMarker,
              polylines: {
                if(_info != null)
                  Polyline(
                    polylineId: const PolylineId('overview_polyline'),
                    color: Colors.red,
                    width: 5,
                    points: _info!.polylinePoints
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList(),
                  )
              },
            ),
            if(_info != null)
              Positioned(
                top: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12
                  ),
                  decoration: BoxDecoration(
                      color: Colors.yellowAccent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 6
                        )
                      ]
                  ),
                  child: Text(
                    '${_info!.totalDistance}, ${_info!.totalDuration}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sehha_app/core/utils/app_colors.dart';
import 'package:sehha_app/widgets/lottie_loading_Indicator.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});
  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? mapController;
  LatLng? selectedLocation;

  late AnimationController _btnCtrl;
  late Animation<double> _btnScale;

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
    _btnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _btnScale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _btnCtrl.dispose();
    super.dispose();
  }

  Future<void> _setInitialLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (!mounted) return;

    setState(
      () => selectedLocation = LatLng(position.latitude, position.longitude),
    );
    mapController?.animateCamera(CameraUpdate.newLatLng(selectedLocation!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          selectedLocation == null
              ? Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0D1B2A), Color(0xFF1B3A5C)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomCircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'جارٍ تحديد موقعك...',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: selectedLocation!,
                    zoom: 16,
                  ),
                  onMapCreated: (controller) => mapController = controller,
                  markers: {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: selectedLocation!,
                      draggable: true,
                      onDragEnd: (newPos) =>
                          setState(() => selectedLocation = newPos),
                    ),
                  },
                  onTap: (latLng) => setState(() => selectedLocation = latLng),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1B2A).withValues(alpha: .85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: .1)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'اختر موقعك',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          if (selectedLocation != null)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1B2A).withValues(alpha: .75),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.touch_app_rounded,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'اضغط على الخريطة أو اسحب الدبوس',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (selectedLocation != null)
            Positioned(
              bottom: 28,
              left: 60,
              right: 60,
              child: GestureDetector(
                onTapDown: (_) => _btnCtrl.forward(),
                onTapUp: (_) {
                  _btnCtrl.reverse();
                  Navigator.pop(context, selectedLocation);
                },
                onTapCancel: () => _btnCtrl.reverse(),
                child: ScaleTransition(
                  scale: _btnScale,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1B2A).withValues(alpha: .85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .1),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'تأكيد الموقع',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

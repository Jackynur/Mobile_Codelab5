import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system, // Dark mode mengikuti pengaturan perangkat
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final LocationController locationController = Get.put(LocationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Real-Time',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Obx(() => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on,
                      size: 60, color: Colors.deepPurple),
                  const SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            locationController.locationMessage.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          locationController.locationMessage.value !=
                                  "Mencari lokasi..."
                              ? Text(
                                  'Latitude: ${locationController.latitude.value}\nLongitude: ${locationController.longitude.value}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.grey),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  locationController.isLoading.value
                      ? Lottie.asset(
                          'assets/loading_animation.json',
                          width: 150,
                          height: 150,
                        )
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                          onPressed: locationController.getCurrentLocation,
                          icon: const Icon(Icons.my_location),
                          label: const Text('Cari Lokasi'),
                        ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      final url =
                          'https://www.google.com/maps?q=${locationController.latitude.value},${locationController.longitude.value}';
                      locationController.launchUrl(url);
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('Buka Google Maps'),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}

class LocationController extends GetxController {
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var locationMessage = "Mencari lokasi...".obs;
  var isLoading = false.obs;

  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isLoading.value = false;
        throw Exception("Layanan lokasi tidak aktif.");
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          isLoading.value = false;
          throw Exception("Izin lokasi ditolak.");
        }
      }
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      latitude.value = position.latitude;
      longitude.value = position.longitude;
      locationMessage.value =
          "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
    } catch (e) {
      locationMessage.value = "Gagal mendapatkan lokasi: $e";
    } finally {
      isLoading.value = false;
    }
  }

  void launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

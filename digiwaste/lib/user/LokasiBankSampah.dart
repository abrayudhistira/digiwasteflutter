import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../model/BankSampah.dart';
import '../model/User.dart';
import '../service/BankSampahService.dart';
import 'RiwayatPembelian.dart';
import 'Dashboard.dart';
import 'Notifikasi.dart';
import 'UserProfile.dart';

class LokasiBankSampah extends StatefulWidget {
  final User user;
  const LokasiBankSampah({super.key, required this.user});

  @override
  State<LokasiBankSampah> createState() => _LokasiBankSampahState();
}

class _LokasiBankSampahState extends State<LokasiBankSampah> {
  late final Future<List<BankSampah>> _futureBanks;
  late final MapController _mapController;

  // kapasitas dummy, bisa diganti dari model jika tersedia
  final Map<String, double> kapasitasSampah = {
    'Organik': 0.8,
    'Kertas': 0.6,
    'Plastik': 0.4,
    'Kaca': 0.3,
  };

  String? selectedBankName;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _futureBanks = BankSampahService().fetchAll();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    final pages = [
      RiwayatPembelianPage(user: widget.user),
      LokasiBankSampah(user: widget.user),
      Dashboard(user: widget.user),
      NotifikasiPage(user: widget.user),
      UserProfilePage(user: widget.user),
    ];
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => pages[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text('DigiWaste', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 20),
                SizedBox(width: 6),
                Text('Lokasi Bank Sampah', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<BankSampah>>(
        future: _futureBanks,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return Center(child: Text('Error: ${snap.error ?? 'Unknown'}'));
          }
          final banks = snap.data!;
          if (banks.isEmpty) {
            // Hanya tampilkan peta kosong, sesuai MapOptions-mu
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 150),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: LatLng(-7.797068, 110.370529), // default center
                    zoom: 13,
                    minZoom: 5,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    // no MarkerLayer
                  ],
                ),
              ),
            );
          }
          selectedBankName ??= banks.first.namaBankSampah;

          // Buat marker list
          final markers = banks.map((b) => Marker(
            point: LatLng(b.lat, b.lng),
            width: 40, height: 40,
            builder: (_) => const Icon(Icons.location_on, size: 40, color: Colors.red),
          )).toList();

          // cari object BankSampah yang dipilih
          final selectedBank = banks.firstWhere((b) => b.namaBankSampah == selectedBankName!);

          return SingleChildScrollView(
            child: Column(
              children: [
                // DROPDOWN
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: DropdownButtonFormField<String>(
                    value: selectedBankName,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: banks.map((b) =>
                      DropdownMenuItem(value: b.namaBankSampah, child: Text(b.namaBankSampah))
                    ).toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedBankName = v;
                        final newBank = banks.firstWhere((b) => b.namaBankSampah == v);
                        _mapController.move(LatLng(newBank.lat, newBank.lng), 15.0);
                      });
                    },
                  ),
                ),
                // MAP
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 250,
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          center: LatLng(selectedBank.lat, selectedBank.lng),
                          zoom: 13,
                          minZoom: 5,
                          maxZoom: 18,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          MarkerLayer(markers: markers),
                        ],
                      ),
                    ),
                  ),
                ),
                // KAPASITAS & TOMBOL
                Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Column(
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 12,
                        children: kapasitasSampah.entries.map((e) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularPercentIndicator(
                                radius: 28, lineWidth: 6,
                                percent: e.value,
                                center: Text('${(e.value * 100).toInt()}%'),
                                progressColor: Colors.black,
                              ),
                              const SizedBox(height: 4),
                              Text(e.key, style: const TextStyle(fontSize: 12)),
                            ],
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          // aksi beli
                        },
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Beli'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      //   selectedItemColor: Colors.black,
      //   unselectedItemColor: Colors.grey,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Riwayat'),
      //     BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Lokasi'),
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      //     BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
      //     BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      //   ],
      // ),
    );
  }
}

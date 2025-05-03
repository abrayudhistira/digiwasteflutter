import 'package:digiwaste/user/UserProfile.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:digiwaste/user/RiwayatPembelian.dart';
import 'package:digiwaste/user/Notifikasi.dart';
import 'package:digiwaste/user/Dashboard.dart';
import 'package:digiwaste/model/User.dart';

class LokasiBankSampah extends StatefulWidget {
  final User user;
  const LokasiBankSampah({super.key, required this.user});

  @override
  State<LokasiBankSampah> createState() => _LokasiBankSampahState();
}

class _LokasiBankSampahState extends State<LokasiBankSampah> {
  final List<String> bankSampahList = [
    'Bank Sampah Tirtonirmolo',
    'Bank Sampah Mulyodadi',
    'Bank Sampah Panggungharjo',
  ];

  String selectedBank = 'Bank Sampah Tirtonirmolo';

  final Map<String, double> kapasitasSampah = {
    'Sampah Organik': 0.8,
    'Sampah Kertas': 0.8,
    'Sampah Plastik': 0.8,
    'Sampah Kaca': 0.8,
  };

  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => RiwayatPembelianPage(user: widget.user)),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LokasiBankSampah(user: widget.user)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Dashboard(user: widget.user)),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => NotifikasiPage(user: widget.user)),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UserProfilePage(user: widget.user)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text(
          'DigiWaste',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.location_on, size: 20),
                SizedBox(width: 6),
                Text(
                  'Lokasi Bank Sampah',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedBank,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: bankSampahList.map((bank) {
                return DropdownMenuItem(value: bank, child: Text(bank));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBank = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                height: 200,
                color: Colors.black12,
                child: const Center(
                  child: Text('Map Placeholder', style: TextStyle(color: Colors.black54)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 12,
                children: kapasitasSampah.entries.map((entry) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularPercentIndicator(
                        radius: 30,
                        lineWidth: 8,
                        percent: entry.value,
                        center: Text('${(entry.value * 100).toInt()}%'),
                        progressColor: Colors.black,
                      ),
                      const SizedBox(height: 6),
                      Text(entry.key, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Beli'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Lokasi'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

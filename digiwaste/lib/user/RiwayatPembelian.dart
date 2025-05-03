import 'package:flutter/material.dart';
import 'package:digiwaste/model/User.dart';
import 'package:digiwaste/user/LokasiBankSampah.dart';
import 'package:digiwaste/user/Notifikasi.dart';
import 'package:digiwaste/user/Dashboard.dart';
import 'package:digiwaste/user/UserProfile.dart';

class RiwayatPembelianPage extends StatefulWidget {
  final User user;
  
  const RiwayatPembelianPage({super.key, required this.user});

  @override
  State<RiwayatPembelianPage> createState() => _RiwayatPembelianPageState();
}

class _RiwayatPembelianPageState extends State<RiwayatPembelianPage> {
  final List<Map<String, String>> riwayatPembelian = [
    {
      'tanggal': '18 Mei 2025',
      'waktu': '18.25',
      'nama': 'Abra Yudhistira Rachmadi',
      'noHp': '087840866596',
      'total': 'Rp85.000',
    },
    {
      'tanggal': '17 Mei 2025',
      'waktu': '14.10',
      'nama': 'Abra Yudhistira Rachmadi',
      'noHp': '087840866596',
      'total': 'Rp75.000',
    },
    {
      'tanggal': '16 Mei 2025',
      'waktu': '10.45',
      'nama': 'Abra Yudhistira Rachmadi',
      'noHp': '087840866596',
      'total': 'Rp65.000',
    },
  ];

  int _selectedIndex = 0;

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
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: riwayatPembelian.length,
        itemBuilder: (context, index) {
          final riwayat = riwayatPembelian[index];
          return Card(
            color: Colors.grey[300],
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tanggal: ${riwayat['tanggal']}', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Waktu: ${riwayat['waktu']}', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('Nama Lengkap: ${riwayat['nama']}', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('No. Hp: ${riwayat['noHp']}', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Total: ${riwayat['total']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
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
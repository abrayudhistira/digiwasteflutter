import 'package:flutter/material.dart';
import 'package:digiwaste/model/User.dart';
import 'package:digiwaste/user/RiwayatPembelian.dart';
import 'package:digiwaste/user/LokasiBankSampah.dart';
import 'package:digiwaste/user/Dashboard.dart';
import 'package:digiwaste/user/UserProfile.dart';

class NotifikasiPage extends StatefulWidget {
  final User user;
  
  const NotifikasiPage({super.key, required this.user});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  final List<String> notifikasiList = [
    'Pengajuan Tanggal 18 Mei 2025 Sudah di ACC',
    'Pengajuan Tanggal 20 Mei 2025 Sudah di ACC',
    'Pengajuan Tanggal 22 Mei 2025 Sudah di ACC',
  ];

  int _selectedIndex = 3; // Indeks aktif untuk Notifikasi

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
      // Sudah di halaman Notifikasi
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
        title: const Text('Notifikasi'),
        centerTitle: true,
        backgroundColor: Colors.grey.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: notifikasiList.map((notifikasi) => _buildNotificationCard(notifikasi)).toList(),
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

  Widget _buildNotificationCard(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
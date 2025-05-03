import 'package:digiwaste/model/User.dart';
import 'package:digiwaste/user/JadwalBeli.dart';
import 'package:flutter/material.dart';
import 'package:digiwaste/user/LiveHargaSampah.dart';
import 'package:digiwaste/user/LokasiBankSampah.dart';
import 'package:digiwaste/user/RiwayatPembelian.dart';
import 'package:digiwaste/user/Ulasan.dart';
import 'package:digiwaste/user/Notifikasi.dart';
import 'package:digiwaste/user/UserProfile.dart';

class Dashboard extends StatefulWidget {
  final User user;
  const Dashboard({super.key, required this.user});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RiwayatPembelianPage(user: widget.user)),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LokasiBankSampah(user: widget.user)),
        );
        break;
      case 2:
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NotifikasiPage(user: widget.user)),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserProfilePage(user: widget.user)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: _buildDashboardContent(),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildDashboardIcons(),
          const SizedBox(height: 16),
          _buildNewsSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.grey[300],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 135, top: 30),
            child: Text('DigiWaste', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.account_circle, size: 40),
              SizedBox(width: 8),
              Text(
                'Hai, ${widget.user.namaLengkap}',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari Lokasi Bank Sampah Terdekat',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey[300],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardIcons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        crossAxisCount: 3,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _DashboardIcon(
            icon: Icons.receipt_long,
            label: 'Riwayat\nPembelian',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RiwayatPembelianPage(user: widget.user)),
              );
            },
          ),
          _DashboardIcon(
            icon: Icons.calendar_month,
            label: 'Penjadwalan\nPembelian',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Jadwalbeli()),
              );
            },
          ),
          _DashboardIcon(
            icon: Icons.sync_alt,
            label: 'Live Harga\nSampah',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LiveHargaSampah()),
              );
            },
          ),
          _DashboardIcon(
            icon: Icons.location_on,
            label: 'Lokasi\nBank Sampah',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LokasiBankSampah(user: widget.user)),
              );
            },
          ),
          _DashboardIcon(
            icon: Icons.star_rate,
            label: 'Ulasan',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UlasanPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: Colors.grey[300],
          padding: const EdgeInsets.only(left: 145, top: 10, bottom: 10),
          child: const Text('Berita Terkini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 200,
          child: Center(
            child: Text('Tidak ada berita terbaru', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ),
        ),
      ],
    );
  }
}

class _DashboardIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _DashboardIcon({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: Colors.black),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

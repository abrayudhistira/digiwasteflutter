import 'package:digiwaste/service/RiwayatService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:digiwaste/model/User.dart';
import 'package:digiwaste/model/Riwayat.dart';
import 'package:digiwaste/service/RiwayatService.dart';
import 'LokasiBankSampah.dart';
import 'Dashboard.dart';
import 'Notifikasi.dart';
import 'UserProfile.dart';

class RiwayatPembelianPage extends StatefulWidget {
  final User user;
  const RiwayatPembelianPage({Key? key, required this.user}) : super(key: key);

  @override
  State<RiwayatPembelianPage> createState() => _RiwayatPembelianPageState();
}

class _RiwayatPembelianPageState extends State<RiwayatPembelianPage> {
  late Future<List<Riwayat>> _futureRiwayat;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  void _loadRiwayat() {
    _futureRiwayat = RiwayatService().fetchAll();
  }

  Future<void> _refresh() async {
    // Re-fetch data
    _loadRiwayat();
    // Tunggu hingga selesai
    await _futureRiwayat;
    // setState untuk rebuild
    setState(() {});
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    final pages = <Widget>[
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

  String _formatDate(DateTime dt) {
    // contoh: 18 Mei 2025
    return DateFormat('dd MMMM yyyy', 'id').format(dt);
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
      body: FutureBuilder<List<Riwayat>>(
        future: _futureRiwayat,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Ambil data lengkap
          final allRiwayats = snapshot.data!;
          final idRiwayat = allRiwayats.where((r) => r.idUser == widget.user.id).toList();

          // Filter hanya yang status == 'confirmed'
          final confirmedRiwayats = idRiwayat
            .where((r) => r.status.toLowerCase() == 'confirmed')
            .toList();

          // Jika tidak ada yang confirmed
          if (confirmedRiwayats.isEmpty) {
            // Tetap support pull-to-refresh
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('Belum ada riwayat pembelian')),
                ],
              ),
            );
          }

          // Tampilkan ListView dari confirmedRiwayats
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: confirmedRiwayats.length,
              itemBuilder: (context, index) {
                final r = confirmedRiwayats[index];
                return Card(
                  color: Colors.grey[200],
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Id : ${r.idTransaksi}',
                          style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Tanggal: ${_formatDate(r.tanggal)}',
                          style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('Waktu: ${r.waktu}',
                          style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 4),
                        Text('Total: Rp${r.total}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Status: ${r.status}',
                          style: const TextStyle(fontSize: 14)),
                        const Icon(Icons.done_rounded, color: Colors.green),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      //   type: BottomNavigationBarType.fixed,
      //   selectedItemColor: Colors.black,
      //   unselectedItemColor: Colors.grey,
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.receipt_long),
      //       label: 'Riwayat',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.location_on),
      //       label: 'Lokasi',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.notifications),
      //       label: 'Notifikasi',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Profil',
      //     ),
      //   ],
      // ),
    );
  }
}
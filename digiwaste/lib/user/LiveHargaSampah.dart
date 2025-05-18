import 'package:flutter/material.dart';
import '../model/Kategori.dart';
import '../service/KategoriService.dart';

// Custom color scheme based on provided hex colors
class AppColors {
  static const Color black = Color(0xFF000000);
  static const Color darkGreen = Color(0xFF01271A);
  static const Color seaGreen = Color(0xFF008C44);
  static const Color teaGreen = Color(0xFFE0FBC0);
}

class LiveHargaSampah extends StatefulWidget {
  const LiveHargaSampah({super.key});

  @override
  State<LiveHargaSampah> createState() => _LiveHargaSampahState();
}

class _LiveHargaSampahState extends State<LiveHargaSampah> {
  final KategoriService _kategoriService = KategoriService();
  List<Kategori> _kategoriList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKategori();
  }

  Future<void> _fetchKategori() async {
    try {
      List<Kategori> kategoriList = await _kategoriService.getAllKategori();
      setState(() {
        _kategoriList = kategoriList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      print('Failed to load kategori: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.teaGreen.withOpacity(0.3),
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, // Ubah warna arrow back menjadi putih
        ),
        title: const Text(
          'DigiWaste',
          style: TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 12.0),
            decoration: const BoxDecoration(
              color: AppColors.darkGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.receipt_long, size: 22, color: AppColors.teaGreen),
                SizedBox(width: 8),
                Text(
                  'Live Harga Sampah',
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.seaGreen))
          : RefreshIndicator(
              color: AppColors.seaGreen,
              onRefresh: _fetchKategori,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader('Harga Beli', Icons.arrow_downward),
                    const SizedBox(height: 12),
                    ..._kategoriList.map((kategori) => _buildHargaCard(kategori.kategoriSampah, kategori.hargaBeli, true)),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Harga Jual', Icons.arrow_upward),
                    const SizedBox(height: 12),
                    ..._kategoriList.map((kategori) => _buildHargaCard(kategori.kategoriSampah, kategori.hargaJual, false)),
                    const SizedBox(height: 80), // Add extra padding at bottom for better scrolling
                  ],
                ),
              ),
            ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: AppColors.seaGreen,
      //   onPressed: () {
      //     _fetchKategori(); // Refresh data when tapped
      //   },
      //   child: const Icon(Icons.refresh, color: Colors.white),
      // ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: 2,
      //   type: BottomNavigationBarType.fixed,
      //   backgroundColor: AppColors.darkGreen,
      //   selectedItemColor: AppColors.teaGreen,
      //   unselectedItemColor: Colors.white.withOpacity(0.6),
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Transaksi'),
      //     BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Lokasi'),
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      //     BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
      //     BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Profil'),
      //   ],
      // ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.seaGreen,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHargaCard(String jenis, double harga, bool isBeli) {
    final formattedPrice = harga.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isBeli ? AppColors.teaGreen : Colors.white,
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: isBeli ? AppColors.seaGreen : AppColors.darkGreen,
            child: Icon(
              isBeli ? Icons.shopping_cart : Icons.sell,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            jenis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreen,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isBeli ? AppColors.seaGreen : AppColors.darkGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Rp $formattedPrice',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
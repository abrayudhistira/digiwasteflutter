import 'package:flutter/material.dart';
import '../model/Kategori.dart';
import '../service/KategoriService.dart';

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
                Icon(Icons.receipt_long, size: 20),
                SizedBox(width: 6),
                Text(
                  'Live Harga Sampah',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    const Text('Harga Beli', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ..._kategoriList.map((kategori) => _buildHargaCard(kategori.kategoriSampah, kategori.hargaBeli)),
                    const SizedBox(height: 24),
                    const Text('Harga Jual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ..._kategoriList.map((kategori) => _buildHargaCard(kategori.kategoriSampah, kategori.hargaJual)),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: ''),
        ],
      ),
    );
  }

  Widget _buildHargaCard(String jenis, double harga) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        children: [
          Text(jenis, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          Container(
            width: 180,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('Rp.${harga.toString()}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

import 'package:digiwaste/model/User.dart';
import 'package:digiwaste/user/JadwalBeli.dart';
import 'package:flutter/material.dart';
import 'package:digiwaste/user/LiveHargaSampah.dart';
import 'package:digiwaste/user/LokasiBankSampah.dart';
import 'package:digiwaste/user/RiwayatPembelian.dart';
import 'package:digiwaste/user/Ulasan.dart';
import 'package:digiwaste/user/Notifikasi.dart';
import 'package:digiwaste/user/UserProfile.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

// App theme colors
class DigiWasteColors {
  static const Color black = Color(0xFF000000);
  static const Color darkGreen = Color(0xFF01271A);
  static const Color seaGreen = Color(0xFF008C44);
  static const Color teaGreen = Color(0xFFE0FBC0);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFFE0E0E0);
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF252525);
  static const Color darkAccent = Color(0xFF00A651);
  static const Color darkAccentSecondary = Color(0xFF00E676);
  static const Color darkText = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFAAAAAA);
}

class Dashboard extends StatefulWidget {
  final User user;
  const Dashboard({super.key, required this.user});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 2;

  late final List<Widget> _pages = [
    RiwayatPembelianPage(user: widget.user),
    LokasiBankSampah(user: widget.user),
    _buildDashboardContent(),
    NotifikasiPage(user: widget.user),
    UserProfilePage(user: widget.user),
  ];

  // Dummy news data, replace with your own data source or API call
  final List<Map<String, String>> _newsData = [
    {
      'imageUrl': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
      'title': 'Bank Sampah Digital Resmi Diluncurkan',
      'date': '2024-06-01',
    },
    {
      'imageUrl': 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
      'title': 'Gerakan Pilah Sampah Nasional',
      'date': '2024-05-28',
    },
    {
      'imageUrl': 'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=400&q=80',
      'title': 'Edukasi Pengelolaan Sampah untuk Anak',
      'date': '2024-05-20',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DigiWasteColors.darkBackground,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: DigiWasteColors.darkAccentSecondary,
            unselectedItemColor: DigiWasteColors.darkTextSecondary,
            backgroundColor: DigiWasteColors.darkSurface,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Riwayat'),
              BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Lokasi'),
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 30),
                label: 'Home',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifikasi'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _pages[_selectedIndex],
      ),
    );
  }

  Future<void> _onRefresh() async {
    // Tambahkan logic refresh sesuai kebutuhan, misal fetch ulang data dari API
    setState(() {
      // Contoh: jika ingin refresh news, bisa fetch ulang _newsData di sini
      // Untuk demo, hanya delay sebentar
    });
    await Future.delayed(const Duration(seconds: 1));
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSearchBar(),
          //_buildQuickStats(),
          _buildDashboardIcons(),
          const SizedBox(height: 16),
          _buildNewsSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // Determine ImageProvider based on photo format
    ImageProvider avatarImage;
    final foto = widget.user.foto;
    if (foto != null && foto.isNotEmpty) {
      if (foto.startsWith('data:image')) {
        // Base64 → MemoryImage
        final base64Str = foto.split(',').last;
        final bytes = base64Decode(base64Str);
        avatarImage = MemoryImage(bytes);
      } else {
        // Assume URL
        avatarImage = NetworkImage(foto);
      }
    } else {
      // Placeholder asset
      avatarImage = const AssetImage('assets/default_avatar.png');
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: DigiWasteColors.darkSurface,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [DigiWasteColors.darkGreen, DigiWasteColors.darkAccent],
          stops: const [0.2, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco, color: DigiWasteColors.darkAccentSecondary, size: 28),
              const SizedBox(width: 8),
              Text(
                'DigiWaste',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: DigiWasteColors.darkAccent.withOpacity(0.3),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage: avatarImage,
                  backgroundColor: DigiWasteColors.darkCard,
                  onBackgroundImageError: (_, __) {
                    setState(() {}); // Force rebuild with default_avatar
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang,',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: DigiWasteColors.darkAccentSecondary,
                      ),
                    ),
                    Text(
                      '${widget.user.namaLengkap}',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotifikasiPage(user: widget.user),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.notifications_on_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari Lokasi Bank Sampah Terdekat',
          hintStyle: GoogleFonts.poppins(
            color: DigiWasteColors.darkTextSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search, color: DigiWasteColors.darkAccent),
          filled: true,
          fillColor: DigiWasteColors.darkSurface,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: DigiWasteColors.darkAccent, width: 1.5),
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: DigiWasteColors.darkAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune, color: Colors.white, size: 20),
          ),
        ),
        style: GoogleFonts.poppins(color: DigiWasteColors.darkText),
      ),
    );
  }

  // Widget _buildQuickStats() {
  //   return Container(
  //     margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       gradient: const LinearGradient(
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //         colors: [Color(0xFF004D25), DigiWasteColors.darkAccent],
  //       ),
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.3),
  //           blurRadius: 15,
  //           offset: const Offset(0, 5),
  //         ),
  //       ],
  //       border: Border.all(
  //         color: DigiWasteColors.darkAccentSecondary.withOpacity(0.3),
  //         width: 1,
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: _StatItem(
  //             title: "25kg",
  //             subtitle: "Sampah Terjual",
  //             icon: Icons.delete_outline,
  //           ),
  //         ),
  //         Container(
  //           height: 40,
  //           width: 1,
  //           color: Colors.white.withOpacity(0.3),
  //         ),
  //         Expanded(
  //           child: _StatItem(
  //             title: "Rp350K",
  //             subtitle: "Total Pendapatan",
  //             icon: Icons.account_balance_wallet_outlined,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildDashboardIcons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: DigiWasteColors.darkSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: DigiWasteColors.darkAccent.withOpacity(0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Layanan",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DigiWasteColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            crossAxisCount: 3,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _DashboardIcon(
                icon: Icons.receipt_long,
                label: 'Riwayat\nPembelian',
                color: const Color(0xFF00A651),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RiwayatPembelianPage(user: widget.user)),
                  );
                },
              ),
              _DashboardIcon(
                icon: Icons.calendar_month,
                label: 'Jadwal\nPembelian',
                color: const Color(0xFF00A651),
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
                color: const Color(0xFF00A651),
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
                color: const Color(0xFF008C44),
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
                color: const Color(0xFF69F0AE),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UlasanPage()),
                  );
                },
              ),
              // _DashboardIcon(
              //   icon: Icons.help_outline,
              //   label: 'Bantuan',
              //   color: const Color(0xFF00796B),
              //   onTap: () {
              //     // Add help page navigation here
              //   },
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Berita Terkini',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: DigiWasteColors.darkText,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all news
                },
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: DigiWasteColors.darkAccentSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: _newsData.isEmpty
              ? Center(
                  child: Text(
                    'Tidak ada berita terbaru',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: DigiWasteColors.darkTextSecondary,
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _newsData.length,
                  padding: const EdgeInsets.only(left: 16),
                  itemBuilder: (context, index) {
                    final news = _newsData[index];
                    return _NewsCard(
                      imageUrl: news['imageUrl']!,
                      title: news['title']!,
                      date: news['date'] ?? 'Tanggal tidak tersedia',
                    );
                  },
                ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _StatItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DashboardIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _DashboardIcon({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 30,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: DigiWasteColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String date;

  const _NewsCard({
    required this.imageUrl,
    required this.title,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.network(
              imageUrl,
              height: 130,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 130,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: DigiWasteColors.darkGreen,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: DigiWasteColors.seaGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
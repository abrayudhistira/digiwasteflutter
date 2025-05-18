import 'package:flutter/material.dart';
import 'package:digiwaste/model/User.dart';
import 'package:digiwaste/user/RiwayatPembelian.dart';
import 'package:digiwaste/user/LokasiBankSampah.dart';
import 'package:digiwaste/user/Dashboard.dart';
import 'package:digiwaste/user/UserProfile.dart';

// Custom color scheme based on provided hex colors
class AppColors {
  static const Color black = Color(0xFF000000);
  static const Color darkGreen = Color(0xFF01271A);
  static const Color seaGreen = Color(0xFF008C44);
  static const Color teaGreen = Color(0xFFE0FBC0);
}

class NotifikasiPage extends StatefulWidget {
  final User user;
  
  const NotifikasiPage({super.key, required this.user});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  final List<Map<String, dynamic>> notifikasiList = [
    {
      'message': 'Pengajuan Tanggal 18 Mei 2025 Sudah di ACC',
      'time': '10 menit yang lalu',
      'isRead': false,
    },
    {
      'message': 'Saldo berhasil ditambahkan',
      'time': '1 jam yang lalu',
      'isRead': false,
    },
    {
      'message': 'Transaksi berhasil diproses',
      'time': '2 hari yang lalu',
      'isRead': true,
    },
    {
      'message': 'Jadwal penjemputan besok pukul 09.00',
      'time': '3 hari yang lalu',
      'isRead': true,
    },
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

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifikasiList) {
        notification['isRead'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int unreadCount = notifikasiList.where((notif) => notif['isRead'] == false).length;
    
    return Scaffold(
      backgroundColor: AppColors.teaGreen.withOpacity(0.3),
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.darkGreen,
        elevation: 0,
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: Icon(Icons.done_all, color: Colors.white),
              onPressed: _markAllAsRead,
              tooltip: 'Tandai semua telah dibaca',
            ),
        ],
      ),
      body: Column(
        children: [
          // Header with notification count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.darkGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_active, color: AppColors.teaGreen),
                SizedBox(width: 8),
                Text(
                  'Anda memiliki $unreadCount notifikasi belum dibaca',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          
          // Notification list
          Expanded(
            child: notifikasiList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off,
                          size: 64,
                          color: AppColors.darkGreen.withOpacity(0.5),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Tidak ada notifikasi',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.darkGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: notifikasiList.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(
                        notifikasiList[index]['message'],
                        notifikasiList[index]['time'],
                        notifikasiList[index]['isRead'],
                        index,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(String message, String time, bool isRead, int index) {
    return Dismissible(
      key: Key('notification_$index'),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          notifikasiList.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notifikasi dihapus'),
            backgroundColor: AppColors.seaGreen,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'BATALKAN',
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  // Logic to restore notification if needed
                });
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          if (!isRead) {
            setState(() {
              notifikasiList[index]['isRead'] = true;
            });
          }
        },
        child: Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: isRead ? 1 : 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isRead
                ? BorderSide.none
                : BorderSide(color: AppColors.seaGreen, width: 1.5),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isRead
                    ? [Colors.white, Colors.white]
                    : [AppColors.teaGreen.withOpacity(0.3), Colors.white],
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: isRead ? AppColors.darkGreen.withOpacity(0.7) : AppColors.seaGreen,
                child: Icon(
                  isRead ? Icons.notifications : Icons.notifications_active,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                message,
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              trailing: !isRead
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.seaGreen,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
              dense: false,
            ),
          ),
        ),
      ),
    );
  }
}
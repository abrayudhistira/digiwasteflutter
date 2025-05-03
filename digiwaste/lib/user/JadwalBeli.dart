import 'package:flutter/material.dart';

class Jadwalbeli extends StatefulWidget {
  const Jadwalbeli({super.key});

  @override
  State<Jadwalbeli> createState() => _JadwalbeliState();
}

class _JadwalbeliState extends State<Jadwalbeli> {
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final List<String> bankSampahList = [
    'Bank Sampah Tirtonirmolo',
    'Bank Sampah Mulyodadi',
    'Bank Sampah Panggungharjo',
  ];

  String selectedBank = 'Bank Sampah Tirtonirmolo';

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _confirmSchedule() {
    final fullname = _fullnameController.text;
    final phone = _phoneController.text;
    final date = _selectedDate != null ? _selectedDate.toString().split(' ')[0] : 'Not selected';
    final time = _selectedTime != null ? _selectedTime!.format(context) : 'Not selected';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text('Nama: $fullname\nNo HP: $phone\nTanggal: $date\nWaktu: $time'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DigiWaste'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Text('Jadwal Pembelian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildInputField(Icons.person, 'Fullname', _fullnameController),
            const SizedBox(height: 16),
            _buildInputField(Icons.phone, 'No Handphone', _phoneController, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildDateTimeField(Icons.calendar_today, 'Tanggal', _selectedDate != null ? _selectedDate.toString().split(' ')[0] : 'Tanggal', _pickDate),
            const SizedBox(height: 16),
            _buildDateTimeField(Icons.access_time, 'Waktu', _selectedTime != null ? _selectedTime!.format(context) : 'Waktu', _pickTime),
            const SizedBox(height: 16),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmSchedule,
              child: const Text('Konfirmasi'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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

  Widget _buildInputField(IconData icon, String hint, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildDateTimeField(IconData icon, String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(value, style: TextStyle(color: value == label ? Colors.grey : Colors.black)),
      ),
    );
  }
}

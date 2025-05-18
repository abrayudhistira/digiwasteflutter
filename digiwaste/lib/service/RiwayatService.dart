import 'dart:convert';

import 'package:digiwaste/model/Riwayat.dart';
import 'package:http/http.dart' as http;

class RiwayatService {
  static const _baseUrl = 'http://10.100.200.209:3000';

  Future<List<Riwayat>> fetchAll() async {
    final uri = Uri.parse('$_baseUrl/transaksi');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final List jsonList = json.decode(resp.body);
      return jsonList.map((e) => Riwayat.fromJson(e)).toList();
    } else {
      throw Exception('Gagal Fetch Data');
    }
  }
}
import 'dart:convert';

import 'package:digiwaste/model/BankSampah.dart';
import 'package:http/http.dart' as http;

class BankSampahService {
  static const _baseUrl = 'http://10.100.200.209:3000';

  Future<List<BankSampah>> fetchAll() async {
    final uri = Uri.parse('$_baseUrl/banksampah');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final List jsonList = json.decode(resp.body);
      return jsonList.map((e) => BankSampah.fromJson(e)).toList();
    } else {
      throw Exception('Gagal Fetch Data');
    }
  }
}
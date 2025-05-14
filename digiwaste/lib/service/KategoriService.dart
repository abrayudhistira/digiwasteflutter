import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/Kategori.dart';

class KategoriService {
  final String baseUrl = 'http://192.168.100.142:3000';

  Future<List<Kategori>> getAllKategori() async {
    final response = await http.get(Uri.parse('$baseUrl/live'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Kategori> kategoriList = body.map((dynamic item) => Kategori.fromJson(item)).toList();
      return kategoriList;
    } else {
      throw Exception('Failed to load kategori');
    }
  }
}
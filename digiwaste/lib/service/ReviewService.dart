import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/Review.dart';

class ReviewService {
  final String baseUrl = 'http://192.168.100.39:3000/review/new';

  Future<void> createReview(Review review) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(review.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      print('Failed to create review: ${response.statusCode} ${response.body}');
      throw Exception('Failed to create review');
    }
  }
}
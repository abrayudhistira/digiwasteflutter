class Kategori {
  int id;
  String kategoriSampah;
  double hargaJual;
  double hargaBeli;

  Kategori({
    required this.id,
    required this.kategoriSampah,
    required this.hargaJual,
    required this.hargaBeli,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'],
      kategoriSampah: json['kategori_sampah'],
      hargaJual: json['harga_jual'] is String ? double.parse(json['harga_jual']) : json['harga_jual'],
      hargaBeli: json['harga_beli'] is String ? double.parse(json['harga_beli']) : json['harga_beli'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kategori_sampah': kategoriSampah,
      'harga_jual': hargaJual,
      'harga_beli': hargaBeli,
    };
  }
}
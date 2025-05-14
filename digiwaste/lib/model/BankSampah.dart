class BankSampah {
  int idSampah;
  String namaBankSampah;
  String percentage;
  String lokasi;    // misal "-7.810698, 110.322222"
  
  // Tambahan: computed properties
  double get lat {
    final parts = lokasi.split(',');
    return double.parse(parts[0].trim());
  }
  double get lng {
    final parts = lokasi.split(',');
    return double.parse(parts[1].trim());
  }

  BankSampah({
    required this.idSampah,
    required this.namaBankSampah,
    required this.percentage,
    required this.lokasi,
  });

  factory BankSampah.fromJson(Map<String, dynamic> json) => BankSampah(
    idSampah: json["id_sampah"],
    namaBankSampah: json["nama_bank_sampah"],
    percentage: json["percentage"],
    lokasi: json["lokasi"],
  );

  Map<String, dynamic> toJson() => {
    "id_sampah": idSampah,
    "nama_bank_sampah": namaBankSampah,
    "percentage": percentage,
    "lokasi": lokasi,
  };
}
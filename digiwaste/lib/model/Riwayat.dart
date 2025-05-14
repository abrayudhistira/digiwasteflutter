// To parse this JSON data, do
//
//     final riwayat = riwayatFromJson(jsonString);

import 'dart:convert';

List<Riwayat> riwayatFromJson(String str) => List<Riwayat>.from(json.decode(str).map((x) => Riwayat.fromJson(x)));

String riwayatToJson(List<Riwayat> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Riwayat {
    String idTransaksi;
    DateTime tanggal;
    String waktu;
    String total;
    String status;
    int idUser;

    Riwayat({
        required this.idTransaksi,
        required this.tanggal,
        required this.waktu,
        required this.total,
        required this.status,
        required this.idUser,
    });

    factory Riwayat.fromJson(Map<String, dynamic> json) => Riwayat(
        idTransaksi: json["id_transaksi"],
        tanggal: DateTime.parse(json["tanggal"]),
        waktu: json["waktu"],
        total: json["total"],
        status: json["status"],
        idUser: json["id_user"],
    );

    Map<String, dynamic> toJson() => {
        "id_transaksi": idTransaksi,
        "tanggal": tanggal.toIso8601String(),
        "waktu": waktu,
        "total": total,
        "status": status,
        "id_user": idUser,
    };
}

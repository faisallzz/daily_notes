
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/catatan.dart';

class CatatanService {
  static const String _keyCatatan = 'daftar_catatan';

  // Menyimpan daftar catatan
  Future<void> simpanCatatan(List<Catatan> catatan) async {
    final prefs = await SharedPreferences.getInstance();

    final data = catatan.map((item) => item.toMap()).toList();

    final jsonString = jsonEncode(data);

    await prefs.setString(_keyCatatan, jsonString);
  }

  // Mengambil daftar catatan
  Future<List<Catatan>> ambilCatatan() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(_keyCatatan);

    if (jsonString == null) {
      return [];
    }

    final List<dynamic> data = jsonDecode(jsonString);

    return data.map((item) {
      return Catatan.fromMap(
        Map<String, dynamic>.from(item),
      );
    }).toList();
  }

  // Menghapus seluruh catatan
  Future<void> hapusSemuaCatatan() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_keyCatatan);
  }
}

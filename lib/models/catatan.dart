class Catatan {
  final String judul;
  final String isi;
  final String tanggal;

  Catatan({
    required this.judul,
    required this.isi,
    required this.tanggal,
  });

  // Mengubah objek Catatan menjadi Map
  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'isi': isi,
      'tanggal': tanggal,
    };
  }

  // Mengubah Map menjadi objek Catatan
  factory Catatan.fromMap(Map<String, dynamic> map) {
    return Catatan(
      judul: map['judul'],
      isi: map['isi'],
      tanggal: map['tanggal'],
    );
  }
}

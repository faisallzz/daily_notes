import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'models/catatan.dart';
import 'services/catatan_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catatan Harian',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF795548),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F5F0),
        useMaterial3: true,
      ),
      home: const HalamanUtama(),
    );
  }
}

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  final CatatanService _service = CatatanService();

  List<Catatan> daftarCatatan = [];

  bool sedangMemuat = true;

  @override
  void initState() {
    super.initState();
    _muatCatatan();
  }

  // Mengambil catatan dari penyimpanan lokal
  Future<void> _muatCatatan() async {
    final hasil = await _service.ambilCatatan();

    if (!mounted) return;

    setState(() {
      daftarCatatan = hasil;
      sedangMemuat = false;
    });
  }

  // Menambahkan catatan baru
  Future<void> _tambahCatatan(
    String judul,
    String isi,
  ) async {
    final tanggal = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());

    final catatan = Catatan(
      judul: judul,
      isi: isi,
      tanggal: tanggal,
    );

    setState(() {
      daftarCatatan.insert(0, catatan);
    });

    await _service.simpanCatatan(daftarCatatan);
  }

  // Menghapus catatan
  Future<void> _hapusCatatan(int index) async {
  setState(() {
    daftarCatatan.removeAt(index);
  });

  await _service.simpanCatatan(daftarCatatan);

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Catatan berhasil dihapus!'),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 2),
    ),
  );
}

  
Future<void> _editCatatan(int index) async {
  final catatanLama = daftarCatatan[index];

  final judulController = TextEditingController(
    text: catatanLama.judul,
  );

  final isiController = TextEditingController(
    text: catatanLama.isi,
  );

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Edit Catatan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul Catatan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: isiController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Isi Catatan',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final judul = judulController.text.trim();
              final isi = isiController.text.trim();

              if (judul.isEmpty || isi.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Judul dan isi catatan wajib diisi!',
                    ),
                  ),
                );
                return;
              }

              final catatanBaru = Catatan(
                judul: judul,
                isi: isi,
                tanggal: catatanLama.tanggal,
              );

              setState(() {
                daftarCatatan[index] = catatanBaru;
              });

              Navigator.pop(dialogContext);

              await _service.simpanCatatan(daftarCatatan);

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Catatan berhasil diperbarui!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Simpan Perubahan'),
          ),
        ],
      );
    },
  );

  judulController.dispose();
  isiController.dispose();
}


  // Menampilkan formulir tambah catatan
  void _bukaFormCatatan() {
    final judulController = TextEditingController();
    final isiController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Catatan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: judulController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Catatan',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: isiController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Isi Catatan',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final judul = judulController.text.trim();
                final isi = isiController.text.trim();

                if (judul.isEmpty || isi.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Judul dan isi catatan wajib diisi!',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext);

                await _tambahCatatan(judul, isi);

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Catatan berhasil disimpan!'),
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    ).then((_) {
      judulController.dispose();
      isiController.dispose();
    });
  }

  // Menampilkan detail catatan
  void _lihatDetail(Catatan catatan) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(catatan.judul),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  catatan.tanggal,
                  style: const TextStyle(
                    color: Colors.brown,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Text(catatan.isi),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catatan Harian',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF795548),
        foregroundColor: Colors.white,
      ),

      body: sedangMemuat
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : daftarCatatan.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book,
                        size: 75,
                        color: Colors.brown,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada catatan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tekan tombol + untuk membuat catatan.',
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: daftarCatatan.length,
                  itemBuilder: (context, index) {
                    final catatan = daftarCatatan[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFEADFD3),
                          child: Icon(
                            Icons.note_alt,
                            color: Colors.brown,
                          ),
                        ),
                        title: Text(
                          catatan.judul,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Text(
                              catatan.isi,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              catatan.tanggal,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.brown,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _lihatDetail(catatan),
                        
trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    // Tombol Edit
    IconButton(
      icon: const Icon(
        Icons.edit_outlined,
        color: Colors.blue,
      ),
      onPressed: () => _editCatatan(index),
    ),

    // Tombol Hapus
    IconButton(
      icon: const Icon(
        Icons.delete_outline,
        color: Colors.red,
      ),
      onPressed: () => _hapusCatatan(index),
    ),
  ],
),

                      ),
                    );
                  },
                ),

      floatingActionButton: FloatingActionButton(
        onPressed: _bukaFormCatatan,
        backgroundColor: const Color(0xFF795548),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/report_controller.dart';

class AddReportPage extends StatefulWidget {
  const AddReportPage({super.key});

  @override
  State<AddReportPage> createState() => _AddReportPageState();
}

class _AddReportPageState extends State<AddReportPage> {
  final _formKey = GlobalKey<FormState>();
  final title = TextEditingController();
  final desc = TextEditingController();
  final controller = Get.put(ReportController());
  final picker = ImagePicker();

  Uint8List? imageBytes;

  Future<void> pickImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (picked != null) {
      imageBytes = await picked.readAsBytes();
      setState(() {});
    }
  }

  @override
  void dispose() {
    title.dispose();
    desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (imageBytes == null) {
      Get.snackbar(
        'Error',
        'Gambar wajib diisi',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await controller.addReport(
        title.text.trim(),
        desc.text.trim(),
        imageBytes!,
      );
      
      if (!mounted) return;
      
      Get.snackbar(
        'Sukses',
        'Laporan tersimpan',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Tunggu snackbar selesai, baru navigasi
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Kembali ke home page menggunakan Navigator
      Navigator.of(context).pop();
      // Atau jika ingin hapus semua page di stack:
      // Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Error',
        'Gagal menyimpan laporan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12.0);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Laporan',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        backgroundColor: Colors.indigo.shade600,
      ),
      body: Container(
        color: Colors.grey.shade50,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: radius),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Buat Laporan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 43, 63, 190),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: title,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Judul',
                          labelStyle: const TextStyle(color: Color(0xFF424242)),
                          prefixIcon: const Icon(
                            Icons.title,
                            color: Color(0xFF616161),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Judul harus diisi'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: desc,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Deskripsi',
                          labelStyle: const TextStyle(color: Color(0xFF424242)),
                          prefixIcon: const Icon(
                            Icons.description_outlined,
                            color: Color(0xFF616161),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Deskripsi harus diisi'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      /// IMAGE PICKER PREVIEW
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[50],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: imageBytes == null
                                ? Container(
                                    color: Colors.grey[100],
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.image,
                                            size: 48,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            'Pilih gambar',
                                            style: TextStyle(
                                              color: Color(0xDE212121),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.memory(
                                        imageBytes!,
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: ClipOval(
                                          child: Material(
                                            color: Colors.black45,
                                            child: InkWell(
                                              onTap: pickImage,
                                              child: const Padding(
                                                padding: EdgeInsets.all(6),
                                                child: Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Obx(() {
                        return controller.loading.value
                            ? const Center(child: CircularProgressIndicator())
                            : Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(
                                        Icons.save,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Simpan Laporan',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigo.shade600,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      onPressed: _save,
                                    ),
                                  ),
                                ],
                              );
                      }),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF3F51B5),
                        ),
                        child: const Text('Batal'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

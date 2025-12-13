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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Laporan")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: title,
            decoration: const InputDecoration(labelText: "Judul"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: desc,
            decoration: const InputDecoration(labelText: "Deskripsi"),
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          /// PREVIEW GAMBAR (AMAN SEMUA PLATFORM)
          imageBytes == null
              ? OutlinedButton.icon(
                  onPressed: pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Pilih Gambar"),
                )
              : Column(
                  children: [
                    Image.memory(
                      imageBytes!,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                    TextButton(
                      onPressed: pickImage,
                      child: const Text("Ganti Gambar"),
                    ),
                  ],
                ),

          const SizedBox(height: 30),

          /// BUTTON SIMPAN
          Obx(() {
            return controller.loading.value
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text("Simpan Laporan"),
                    onPressed: () async {
                      if (imageBytes == null) {
                        Get.snackbar("Error", "Gambar wajib diisi");
                        return;
                      }

                      await controller.addReport(
                        title.text,
                        desc.text,
                        imageBytes!,
                      );

                      if (mounted) Navigator.pop(context);
                    },
                  );
          }),
        ],
      ),
    );
  }
}

import 'dart:io';
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
  File? image;
  final picker = ImagePicker();
  final controller = Get.put(ReportController());

  Future pickImage() async {
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) setState(() => image = File(file.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Laporan")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: "Judul"),
            ),
            TextField(
              controller: desc,
              decoration: const InputDecoration(labelText: "Deskripsi"),
            ),
            const SizedBox(height: 10),
            image == null
                ? TextButton(
                    onPressed: pickImage,
                    child: const Text("Ambil Foto"),
                  )
                : Image.file(image!, height: 150),
            const SizedBox(height: 20),
            Obx(() {
              return controller.loading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (image == null) return;
                        await controller.addReport(
                          title.text,
                          desc.text,
                          image!,
                        );
                        if (mounted) Navigator.pop(context);
                      },
                      child: const Text("Simpan"),
                    );
            }),
          ],
        ),
      ),
    );
  }
}

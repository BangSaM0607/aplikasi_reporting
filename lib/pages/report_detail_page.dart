import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/report_model.dart';
import '../controllers/report_controller.dart';

class ReportDetailPage extends StatelessWidget {
  final ReportModel report;
  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();

    return Scaffold(
      appBar: AppBar(title: Text(report.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Image.network(report.imageUrl),
          const SizedBox(height: 20),
          Text(
            report.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(report.description),
          const SizedBox(height: 20),
          Text("Tanggal: ${report.createdAt}"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteReport(report.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Hapus Laporan"),
          ),
        ],
      ),
    );
  }
}

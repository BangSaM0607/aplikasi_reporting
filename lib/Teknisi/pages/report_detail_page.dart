import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/report_model.dart';
import '../controllers/report_controller.dart';
import 'edit_report_page.dart'; // added import

class ReportDetailPage extends StatelessWidget {
  final ReportModel report;
  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(report.title),
        elevation: 0,
        actions: [ // added edit button
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => EditReportPage(report: report)),
              );
              if (updated == true) {
                controller.fetchReports();
                // optional: pop back to previous list if needed
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              report.imageUrl,
              fit: BoxFit.cover,
              height: 250,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            report.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            report.description,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Tanggal: ${report.createdAt}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _showDeleteDialog(context, controller),
            icon: const Icon(Icons.delete),
            label: const Text("Hapus Laporan"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ReportController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Hapus"),
          content: const Text("Apakah Anda yakin ingin menghapus laporan ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                await controller.deleteReport(report.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

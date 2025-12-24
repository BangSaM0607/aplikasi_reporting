import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/report_model.dart';
import '../controllers/report_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_report_page.dart'; // added import

class ReportDetailPage extends StatelessWidget {
  final ReportModel report;
  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(report.title, style: const TextStyle(color: Colors.white)),
        elevation: 0,
        backgroundColor: Colors.indigo.shade600,
        actions: [
          if (report.userId == Supabase.instance.client.auth.currentUser?.id)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () async {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditReportPage(report: report),
                  ),
                );
                if (updated == true) {
                  controller.fetchReports();
                }
              },
            ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade50,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        report.imageUrl,
                        fit: BoxFit.cover,
                        height: 250,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 250,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      report.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      report.description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Tanggal: ${report.createdAt}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (report.userId ==
                        Supabase.instance.client.auth.currentUser?.id)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showDeleteDialog(context, controller),
                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: const Text(
                            'Hapus Laporan',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
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

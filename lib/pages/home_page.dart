import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/report_controller.dart';
import 'add_report_page.dart';
import 'report_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportController());
    controller.fetchReports();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Saya"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchReports,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.reports.isEmpty) {
          return const Center(child: Text("Belum ada laporan"));
        }

        return ListView.builder(
          itemCount: controller.reports.length,
          itemBuilder: (context, index) {
            final r = controller.reports[index];
            return ListTile(
              leading: Image.network(
                r.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(r.title),
              subtitle: Text(r.createdAt),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ReportDetailPage(report: r)),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddReportPage()),
          );
        },
      ),
    );
  }
}

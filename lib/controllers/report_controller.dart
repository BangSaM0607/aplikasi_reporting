import 'dart:io';
import 'package:get/get.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportController extends GetxController {
  final ReportService service = ReportService();
  var reports = <ReportModel>[].obs;
  var loading = false.obs;

  Future<void> fetchReports() async {
    loading.value = true;
    reports.value = await service.getReports();
    loading.value = false;
  }

  Future<void> addReport(String title, String desc, File imageFile) async {
    loading.value = true;

    final imageUrl = await service.uploadImage(imageFile);

    await service.addReport(
      title: title,
      description: desc,
      imageUrl: imageUrl,
    );

    await fetchReports();
    loading.value = false;
  }

  Future<void> deleteReport(String id) async {
    await service.deleteReport(id);
    await fetchReports();
  }
}

import 'dart:typed_data';
import 'package:get/get.dart';
import '../services/report_service.dart';
import '../models/report_model.dart';

class ReportController extends GetxController {
  final service = ReportService();

  var reports = <ReportModel>[].obs;
  var loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReports();
  }

  Future<void> addReport(
    String title,
    String description,
    Uint8List imageBytes,
  ) async {
    try {
      loading.value = true;
      final imageUrl = await service.uploadImageBytes(imageBytes);

      await service.addReport(
        title: title,
        description: description,
        imageUrl: imageUrl,
      );

      await fetchReports();
      Get.snackbar('Sukses', 'Laporan berhasil ditambahkan');
    } catch (e) {
      print('Error adding report: $e');
      Get.snackbar('Error', 'Gagal menambahkan laporan');
    } finally {
      loading.value = false;
    }
  }

  Future<void> fetchReports() async {
    try {
      loading.value = true;
      final fetchedReports = await service.getReports();
      reports.value = fetchedReports;
    } catch (e) {
      print('Error fetching reports: $e');
      Get.snackbar('Error', 'Gagal memuat laporan');
    } finally {
      loading.value = false;
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      loading.value = true;
      await service.deleteReport(id);
      reports.removeWhere((report) => report.id == id);
      Get.snackbar('Sukses', 'Laporan berhasil dihapus');
    } catch (e) {
      print('Error deleting report: $e');
      Get.snackbar('Error', 'Gagal menghapus laporan');
    } finally {
      loading.value = false;
    }
  }
}

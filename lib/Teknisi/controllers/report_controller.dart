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
      
      // Tambah timeout untuk mencegah hang
      final imageUrl = await service.uploadImageBytes(imageBytes)
          .timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Upload gambar timeout');
      });

      await service.addReport(
        title: title,
        description: description,
        imageUrl: imageUrl,
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('Tambah laporan timeout');
      });

      // Refresh list
      final fetchedReports = await service.getReports();
      reports.value = fetchedReports;
    } catch (e) {
      print('Error adding report: $e');
      rethrow;
    } finally {
      loading.value = false;
    }
  }

  Future<void> fetchReports() async {
    try {
      loading.value = true;
      final fetchedReports = await service.getReports()
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('Memuat laporan timeout');
      });
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
      await service.deleteReport(id)
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('Hapus laporan timeout');
      });
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

import 'dart:typed_data';
import '../supabase_config.dart';
import '../models/report_model.dart';

class ReportService {
  final table = 'reports';
  final bucket = 'report_images';

  /// Upload image (WEB + MOBILE AMAN)
  Future<String> uploadImageBytes(Uint8List bytes) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage.from(bucket).uploadBinary(
        fileName,
        bytes,
      );

      return supabase.storage.from(bucket).getPublicUrl(fileName);
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Gagal upload gambar');
    }
  }

  Future<void> addReport({
    required String title,
    required String description,
    required String imageUrl,
  }) async {
    try {
      await supabase.from(table).insert({
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error adding report: $e');
      throw Exception('Gagal menambah laporan');
    }
  }

  Future<List<ReportModel>> getReports() async {
    try {
      final response = await supabase
          .from(table)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => ReportModel.fromJson(data))
          .toList();
    } catch (e) {
      print('Error fetching reports: $e');
      throw Exception('Gagal mengambil laporan');
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      await supabase.from(table).delete().eq('id', id);
    } catch (e) {
      print('Error deleting report: $e');
      throw Exception('Gagal menghapus laporan');
    }
  }
}

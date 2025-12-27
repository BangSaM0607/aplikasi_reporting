import 'dart:typed_data';
import '../../supabase_config.dart';
import '../models/report_model.dart';

class ReportService {
  final table = 'reports';
  final bucket = 'report_images';

  /// Upload image (WEB + MOBILE AMAN)
  Future<String> uploadImageBytes(Uint8List bytes) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage.from(bucket).uploadBinary(fileName, bytes);

      // getPublicUrl() adalah synchronous, tapi pastikan return value benar
      final imageUrl = supabase.storage.from(bucket).getPublicUrl(fileName);

      if (imageUrl.isEmpty) {
        throw Exception('Gagal mendapatkan URL gambar');
      }

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Gagal upload gambar: ${e.toString()}');
    }
  }

  Future<void> addReport({
    required String title,
    required String description,
    required String imageUrl,
  }) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await supabase.from(table).insert({
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
        'user_id': user.id,
      });
    } catch (e) {
      print('Error adding report: $e');
      throw Exception('Gagal menambah laporan: ${e.toString()}');
    }
  }

  Future<List<ReportModel>> getReports() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return [];

      final response = await supabase
          .from(table)
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return (response as List)
          .map((data) => ReportModel.fromJson(data))
          .toList();
    } catch (e) {
      print('Error fetching reports: $e');
      throw Exception('Gagal mengambil laporan: ${e.toString()}');
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await supabase.from(table).delete().eq('id', id).eq('user_id', user.id);
    } catch (e) {
      print('Error deleting report: $e');
      throw Exception('Gagal menghapus laporan: ${e.toString()}');
    }
  }
}

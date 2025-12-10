import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase_config.dart';
import '../models/report_model.dart';

class ReportService {
  final table = 'reports';
  final bucket = 'report_images';

  Future<List<ReportModel>> getReports() async {
    final data = await supabase
        .from(table)
        .select()
        .order('created_at', ascending: false);

    return data.map<ReportModel>((e) => ReportModel.fromJson(e)).toList();
  }

  Future<String> uploadImage(File file) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage
        .from(bucket)
        .upload(
          fileName,
          file,
          fileOptions: FileOptions(cacheControl: '3600', upsert: false),
        );

    return supabase.storage.from(bucket).getPublicUrl(fileName);
  }

  Future<void> addReport({
    required String title,
    required String description,
    required String imageUrl,
  }) async {
    await supabase.from(table).insert({
      'title': title,
      'description': description,
      'image_url': imageUrl,
    });
  }

  Future<void> deleteReport(String id) async {
    await supabase.from(table).delete().eq('id', id);
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';
import 'dashboard_teknisi.dart'; // added import

class EditReportPage extends StatefulWidget {
  final ReportModel report;
  const EditReportPage({super.key, required this.report});

  @override
  State<EditReportPage> createState() => _EditReportPageState();
}

class _EditReportPageState extends State<EditReportPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  bool _loading = false;

  Uint8List? _newImageBytes;

  final _picker = ImagePicker();
  final _reportService = ReportService();

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.report.title);
    _descCtrl = TextEditingController(text: widget.report.description);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _newImageBytes = bytes;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      String imageUrl = widget.report.imageUrl;
      if (_newImageBytes != null) {
        imageUrl = await _reportService.uploadImageBytes(_newImageBytes!);
      }

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await Supabase.instance.client
          .from('reports')
          .update({
            'title': _titleCtrl.text.trim(),
            'description': _descCtrl.text.trim(),
            'image_url': imageUrl,
          })
          .eq('id', widget.report.id)
          .eq('user_id', userId);

      if (mounted) {
        // arahkan ke HomePage setelah berhasil menyimpan dan kosongkan stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewWidget = _newImageBytes != null
        ? Image.memory(
            _newImageBytes!,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 180,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image),
            ),
          )
        : Image.network(
            widget.report.imageUrl,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 180,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image),
            ),
          );

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Laporan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Judul wajib' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 5,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Deskripsi wajib' : null,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Ganti Gambar'),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: previewWidget,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

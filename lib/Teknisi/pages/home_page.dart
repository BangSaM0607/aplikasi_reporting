import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/report_controller.dart';
import 'add_report_page.dart';
import 'report_detail_page.dart';
import '../../login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Color _statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'open':
      case 'baru':
        return Colors.orange;
      case 'in_progress':
      case 'proses':
        return Colors.blue;
      case 'done':
      case 'selesai':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportController());
    final search = ''.obs;
    final sortBy = 'Terbaru'.obs;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Saya"),
        elevation: 0,
        backgroundColor: Colors.indigo.shade600,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchReports,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await Supabase.instance.client.auth.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              } catch (e) {
                print('Error logout: $e');
              }
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: Obx(() {
          if (controller.loading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              controller.fetchReports();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (v) => search.value = v,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Cari judul atau deskripsi...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(
                        () => DropdownButton<String>(
                          value: sortBy.value,
                          underline: const SizedBox.shrink(),
                          items: const [
                            DropdownMenuItem(
                              value: 'Terbaru',
                              child: Text('Terbaru'),
                            ),
                            DropdownMenuItem(
                              value: 'Terlama',
                              child: Text('Terlama'),
                            ),
                            DropdownMenuItem(
                              value: 'Status A-Z',
                              child: Text('Status A-Z'),
                            ),
                            DropdownMenuItem(
                              value: 'Status Z-A',
                              child: Text('Status Z-A'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) sortBy.value = v;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    final q = search.value.toLowerCase();
                    final list = controller.reports.where((r) {
                      final t = (r.title ?? '').toLowerCase();
                      final d = (r.description ?? '').toLowerCase();
                      return q.isEmpty || t.contains(q) || d.contains(q);
                    }).toList();

                    list.sort((a, b) {
                      // parse createdAt safely; fallback to string compare
                      DateTime? da = DateTime.tryParse(a.createdAt ?? '');
                      DateTime? db = DateTime.tryParse(b.createdAt ?? '');
                      switch (sortBy.value) {
                        case 'Terbaru':
                          if (da != null && db != null) return db.compareTo(da);
                          return (b.createdAt ?? '').compareTo(
                            a.createdAt ?? '',
                          );
                        case 'Terlama':
                          if (da != null && db != null) return da.compareTo(db);
                          return (a.createdAt ?? '').compareTo(
                            b.createdAt ?? '',
                          );
                        case 'Status A-Z':
                          return (a.status ?? '').toLowerCase().compareTo(
                            (b.status ?? '').toLowerCase(),
                          );
                        case 'Status Z-A':
                          return (b.status ?? '').toLowerCase().compareTo(
                            (a.status ?? '').toLowerCase(),
                          );
                        default:
                          return 0;
                      }
                    });

                    if (list.isEmpty) {
                      return ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.inbox,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada laporan',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Keep a small outlined action for accessibility; main action moved to FAB
                                OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AddReportPage(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Buat Laporan'),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Atau tekan tombol + di pojok kanan bawah untuk membuat laporan baru',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final r = list[index];
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReportDetailPage(report: r),
                              ),
                            );
                            controller.fetchReports();
                          },
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      r.imageUrl,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 90,
                                        height: 90,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.broken_image),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                r.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            if (r.status != null &&
                                                r.status!.isNotEmpty)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _statusColor(
                                                    r.status,
                                                  ).withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  r.status!,
                                                  style: TextStyle(
                                                    color: _statusColor(
                                                      r.status,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          r.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          r.createdAt,
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey.shade400,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddReportPage()),
          );
        },
        label: const Text('Buat Laporan Baru'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

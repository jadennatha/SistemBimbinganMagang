import 'package:flutter/material.dart';
import '../../../app/app_colors.dart';

class LogbookEntrySheet extends StatefulWidget {
  const LogbookEntrySheet({super.key});

  @override
  State<LogbookEntrySheet> createState() => _LogbookEntrySheetState();
}

class _LogbookEntrySheetState extends State<LogbookEntrySheet> {
  final _formKey = GlobalKey<FormState>();
  final _judul = TextEditingController();
  final _ringkasan = TextEditingController();

  @override
  void dispose() {
    _judul.dispose();
    _ringkasan.dispose();
    super.dispose();
  }

  OutlineInputBorder _outline(Color c) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: 1),
    );
  }

  void _simpan() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // di tahap ini Kamu bisa panggil Firestore / API
    // untuk sekarang cukup tutup sheet dan kirim true
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomInset),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // handle kecil di atas
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Text(
                    'Catat logbook hari ini',
                    style: t.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tulis ringkasan singkat aktivitas magang Kamu.',
                    style: t.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // judul
                  TextFormField(
                    controller: _judul,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Judul kegiatan',
                      labelStyle: t.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                      hintText: 'Contoh: Observasi lapangan',
                      hintStyle: t.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.4),
                      ),
                      filled: true,
                      fillColor: AppColors.navy.withOpacity(0.4),
                      border: _outline(Colors.white.withOpacity(0.2)),
                      enabledBorder: _outline(Colors.white.withOpacity(0.2)),
                      focusedBorder: _outline(AppColors.blueBook),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Judul tidak boleh kosong';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // ringkasan
                  TextFormField(
                    controller: _ringkasan,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Ringkasan kegiatan',
                      labelStyle: t.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                      hintText: 'Tuliskan apa yang Kamu kerjakan hari ini.',
                      hintStyle: t.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.4),
                      ),
                      filled: true,
                      fillColor: AppColors.navy.withOpacity(0.4),
                      border: _outline(Colors.white.withOpacity(0.2)),
                      enabledBorder: _outline(Colors.white.withOpacity(0.2)),
                      focusedBorder: _outline(AppColors.blueBook),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Ringkasan tidak boleh kosong';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // tombol bawah
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Batal',
                            style: t.bodyMedium?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _simpan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blueBook,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Simpan',
                            style: t.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

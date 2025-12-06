import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_colors.dart';
import '../data/logbook_validation_models.dart';
import '../data/logbook_validation_service.dart';
import '../../auth/data/auth_provider.dart';

class LogbookValidationDetailScreen extends StatefulWidget {
  const LogbookValidationDetailScreen({super.key, required this.item});

  final LogbookValidationItem item;

  @override
  State<LogbookValidationDetailScreen> createState() =>
      _LogbookValidationDetailScreenState();
}

class _LogbookValidationDetailScreenState
    extends State<LogbookValidationDetailScreen> {
  final LogbookValidationService _validationService =
      LogbookValidationService();
  bool _isLoading = false;

  Color get _statusColor {
    if (widget.item.isApproved) return AppColors.greenArrow;
    if (widget.item.isRevision) return Colors.orange;
    return AppColors.blueBook;
  }

  String get _statusLabel => widget.item.statusLabel;

  Future<void> _handleApprove() async {
    final authProvider = context.read<AuthProvider>();
    final isMentor = authProvider.isMentor;

    setState(() => _isLoading = true);

    try {
      await _validationService.updateStatus(
        widget.item.id,
        'approved',
        '', // No comment for approval
        isMentor,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        await _showStatusDialog(
          context,
          title: 'Logbook disetujui',
          message: 'Status logbook mahasiswa sudah Kamu setujui.',
          color: AppColors.greenArrow,
        );
        if (mounted) {
          Navigator.of(context).pop(); // Return to history screen
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyetujui logbook: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRevision(String komentar) async {
    final authProvider = context.read<AuthProvider>();
    final isMentor = authProvider.isMentor;

    setState(() => _isLoading = true);

    try {
      await _validationService.updateStatus(
        widget.item.id,
        'rejected',
        komentar,
        isMentor,
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim revisi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header sederhana
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Detail logbook',
                    style: t.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // kartu info mahasiswa
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.blueBook.withOpacity(0.12),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppColors.blueBook,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.item.studentName,
                                  style: t.titleSmall?.copyWith(
                                    color: AppColors.navyDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      size: 14,
                                      color: AppColors.blueGrey.withOpacity(
                                        0.9,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.item.dateLabel,
                                      style: t.bodySmall?.copyWith(
                                        color: AppColors.blueGrey.withOpacity(
                                          0.9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _statusLabel,
                              style: t.labelSmall?.copyWith(
                                color: _statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // judul + isi aktivitas
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 12,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.title,
                            style: t.titleMedium?.copyWith(
                              color: AppColors.navyDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.item.description,
                            textAlign: TextAlign.justify,
                            style: t.bodyMedium?.copyWith(
                              color: AppColors.navy.withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // hanya tampil kalau masih menunggu (pending)
                    if (widget.item.isWaiting) ...[
                      Text(
                        'Tindakan',
                        style: t.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 46,
                              child: ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => _showRevisionSheet(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade600,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text('Minta revisi'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 46,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleApprove,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.greenArrow,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text('Setujui'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRevisionSheet(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final controller = TextEditingController();
    String? errorText;

    showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final bottom = MediaQuery.of(sheetContext).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
          child: StatefulBuilder(
            builder: (context, setStateSheet) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.blueGrey.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Text(
                    'Catatan revisi',
                    style: t.titleMedium?.copyWith(
                      color: AppColors.navyDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tulis catatan yang ingin Kamu sampaikan ke mahasiswa.',
                    style: t.bodySmall?.copyWith(
                      color: AppColors.navy.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    cursorColor: AppColors.navyDark,
                    onChanged: (_) {
                      if (errorText != null) {
                        setStateSheet(() {
                          errorText = null;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText:
                          'Contoh. Mohon jelaskan tujuan kegiatan hari ini.',
                      hintStyle: t.bodySmall?.copyWith(
                        color: AppColors.blueGrey,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      errorText: errorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.blueGrey.withOpacity(0.4),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.blueGrey.withOpacity(0.4),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide(
                          color: AppColors.blueBook,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(sheetContext).pop(false);
                          },
                          child: const Text('Batal'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final note = controller.text.trim();
                            if (note.isEmpty) {
                              setStateSheet(() {
                                errorText = 'Catatan revisi tidak boleh kosong';
                              });
                              return;
                            }
                            Navigator.of(sheetContext).pop(note);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Kirim revisi'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    ).then((result) async {
      if (result != null) {
        // Call Firebase update with comment
        await _handleRevision(result);

        if (mounted) {
          await _showStatusDialog(
            context,
            title: 'Revisi dikirim',
            message: 'Catatan revisi sudah terkirim ke mahasiswa.',
            color: Colors.orange.shade600,
          );
          if (mounted) {
            Navigator.of(context).pop(); // Return to history screen
          }
        }
      }
    });
  }

  Future<void> _showStatusDialog(
    BuildContext context, {
    required String title,
    required String message,
    required Color color,
  }) async {
    final t = Theme.of(context).textTheme;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          actionsPadding: const EdgeInsets.only(bottom: 8),
          actionsAlignment: MainAxisAlignment.center,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded, color: color, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: t.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: t.bodyMedium?.copyWith(
                  color: AppColors.navy.withOpacity(0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: color,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

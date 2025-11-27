import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../app/app_colors.dart';
import '../logbook/models/logbook_model.dart';
import '../logbook/services/logbook_service.dart';

class LogbookContent extends StatefulWidget {
  const LogbookContent({super.key});

  @override
  State<LogbookContent> createState() => _LogbookContentState();
}

class _LogbookContentState extends State<LogbookContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _btnController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _glowAnim;
  final LogbookService _logbookService = LogbookService();
  late String _studentId;
  late String _dosenId;
  late String _mentorId;
  bool _isUserInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _btnController, curve: Curves.easeInOut));

    _glowAnim = Tween<double>(
      begin: 0.16,
      end: 0.35,
    ).animate(CurvedAnimation(parent: _btnController, curve: Curves.easeInOut));
  }

  Future<void> _initializeUserData() async {
    try {
      final currentUserId = _logbookService.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('User tidak login');
      }

      _studentId = currentUserId;

      // Get user data from Firestore to get dosenId and mentorId
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        _dosenId = userData['dosenId'] ?? 'default_dose';
        _mentorId = userData['mentorId'] ?? 'default_mentor';
      } else {
        _dosenId = 'default_dose';
        _mentorId = 'default_mentor';
      }

      setState(() {
        _isUserInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _btnController.dispose();
    super.dispose();
  }

  Future<void> _showSuccessDialog() async {
    final textTheme = Theme.of(context).textTheme;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
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
                  color: AppColors.greenArrow.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.greenArrow,
                  size: 26,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Logbook tersimpan',
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontFamily: 'StackSansHeadline',
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Catatan logbook hari ini berhasil disimpan.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.navy.withOpacity(0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.greenArrow,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openLogbookDialog() async {
    if (!_isUserInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data masih dimuat...')),
      );
      return;
    }

    final bool? ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _LogbookEntryDialog(
        studentId: _studentId,
        dosenId: _dosenId,
        mentorId: _mentorId,
        logbookService: _logbookService,
      ),
    );

    if (ok == true && mounted) {
      await _showSuccessDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TodayStatusCard(),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FilterChipsRow(),
                  const SizedBox(height: 8),
                  Divider(
                    color: AppColors.navy.withOpacity(0.08),
                    height: 24,
                    thickness: 1,
                  ),
                  Text(
                    'Riwayat singkat',
                    style: t.titleMedium?.copyWith(
                      color: AppColors.navyDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _LogItem(
                    dayLabel: 'Hari ini',
                    title: 'Laporan harian',
                    status: 'Draft tersimpan',
                  ),
                  const SizedBox(height: 10),
                  const _LogItem(
                    dayLabel: 'Kemarin',
                    title: 'Observasi lapangan',
                    status: 'Sudah dikirim',
                  ),
                  const SizedBox(height: 10),
                  const _LogItem(
                    dayLabel: '2 hari lalu',
                    title: 'Diskusi dengan pembimbing',
                    status: 'Sudah dikirim',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _btnController,
              builder: (context, child) {
                final double scale = _scaleAnim.value;
                final double glowOpacity = _glowAnim.value;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blueBook.withOpacity(glowOpacity),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: child,
                  ),
                );
              },
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _openLogbookDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueBook,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    'Catat logbook hari ini',
                    style: t.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayStatusCard extends StatelessWidget {
  const _TodayStatusCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
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
              color: AppColors.blueBook.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.edit_calendar_rounded,
              color: AppColors.blueBook,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Logbook hari ini',
                  style: t.bodyMedium?.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Belum ada catatan. Tambah satu entri.',
                  style: t.bodySmall?.copyWith(
                    color: AppColors.navy.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: 0.0,
                    minHeight: 5,
                    backgroundColor: AppColors.blueGrey.withOpacity(0.25),
                    color: AppColors.greenArrow,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _FilterChip(label: 'Hari ini', selected: true),
        SizedBox(width: 8),
        _FilterChip(label: 'Minggu ini', selected: false),
        SizedBox(width: 8),
        _FilterChip(label: 'Semua', selected: false),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected ? Colors.white : Colors.white.withOpacity(0.25),
        ),
      ),
      child: Text(
        label,
        style: t.bodySmall?.copyWith(
          color: selected ? AppColors.navyDark : AppColors.navy,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _LogItem extends StatelessWidget {
  const _LogItem({
    required this.dayLabel,
    required this.title,
    required this.status,
  });

  final String dayLabel;
  final String title;
  final String status;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.blueBook.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.note_alt_outlined,
            size: 18,
            color: AppColors.blueBook,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayLabel,
                style: t.bodySmall?.copyWith(
                  color: AppColors.blueGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: t.bodyMedium?.copyWith(
                  color: AppColors.navyDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: t.bodySmall?.copyWith(
                  color: AppColors.navy.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LogbookEntryDialog extends StatefulWidget {
  final String studentId;
  final String dosenId;
  final String mentorId;
  final LogbookService logbookService;

  const _LogbookEntryDialog({
    required this.studentId,
    required this.dosenId,
    required this.mentorId,
    required this.logbookService,
  });

  @override
  State<_LogbookEntryDialog> createState() => _LogbookEntryDialogState();
}

class _LogbookEntryDialogState extends State<_LogbookEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _aktivitasController = TextEditingController();
  bool _isSaving = false;

  DateTime? _tanggal;

  @override
  void dispose() {
    _judulController.dispose();
    _tanggalController.dispose();
    _aktivitasController.dispose();
    super.dispose();
  }

  OutlineInputBorder _outline(Color c) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: c, width: 1),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      helpText: '',
      builder: (context, child) {
        final base = Theme.of(context);

        return Theme(
          data: base.copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.blueBook,
              onPrimary: Colors.white,
              surface: Colors.white, // background kalender putih
              onSurface: AppColors.navyDark, // teks tanggal lebih gelap
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.blueBook),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tanggal = picked;
        _tanggalController.text =
            '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  Future<void> _simpan() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_tanggal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal harus dipilih')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final logbook = LogbookModel(
        studentId: widget.studentId,
        date: _tanggal!,
        activity: _aktivitasController.text,
        judulKegiatan: _judulController.text,
        statusDosen: 'pending',
        statusMentor: 'pending',
        dosenId: widget.dosenId,
        mentorId: widget.mentorId,
      );

      await widget.logbookService.createLogbook(logbook);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AlertDialog(
      backgroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catat logbook hari ini',
                  style: t.titleMedium?.copyWith(
                    color: AppColors.navyDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Isi judul, tanggal, dan aktivitas kegiatan.',
                  style: t.bodySmall?.copyWith(
                    color: AppColors.navy.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _judulController,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: AppColors.navyDark),
                  cursorColor: AppColors.navyDark,
                  decoration: InputDecoration(
                    labelText: 'Judul kegiatan',
                    labelStyle: t.bodySmall?.copyWith(
                      color: AppColors.navy.withOpacity(0.8),
                    ),
                    hintText: 'Contoh: Observasi lapangan',
                    hintStyle: t.bodySmall?.copyWith(
                      color: AppColors.navy.withOpacity(0.4),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: _outline(AppColors.navy.withOpacity(0.2)),
                    enabledBorder: _outline(AppColors.navy.withOpacity(0.2)),
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
                TextFormField(
                  controller: _tanggalController,
                  readOnly: true,
                  onTap: _pickDate,
                  style: const TextStyle(color: AppColors.navyDark),
                  cursorColor: AppColors.navyDark,
                  decoration: InputDecoration(
                    labelText: 'Tanggal',
                    labelStyle: t.bodySmall?.copyWith(
                      color: AppColors.navy.withOpacity(0.8),
                    ),
                    hintText: 'Pilih tanggal',
                    hintStyle: t.bodySmall?.copyWith(
                      color: AppColors.navy.withOpacity(0.4),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: _outline(AppColors.navy.withOpacity(0.2)),
                    enabledBorder: _outline(AppColors.navy.withOpacity(0.2)),
                    focusedBorder: _outline(AppColors.blueBook),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    suffixIcon: const Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.blueBook,
                      size: 20,
                    ),
                  ),
                  validator: (_) {
                    if (_tanggal == null) {
                      return 'Tanggal belum dipilih';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _aktivitasController,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(color: AppColors.navyDark),
                  cursorColor: AppColors.navyDark,
                  decoration: InputDecoration(
                    labelText: 'Aktivitas kegiatan',
                    labelStyle: t.bodySmall?.copyWith(
                      color: AppColors.navy.withOpacity(0.8),
                    ),
                    hintText: 'Tuliskan aktivitas utama hari ini.',
                    hintStyle: t.bodySmall?.copyWith(
                      color: AppColors.navy.withOpacity(0.4),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: _outline(AppColors.navy.withOpacity(0.2)),
                    enabledBorder: _outline(AppColors.navy.withOpacity(0.2)),
                    focusedBorder: _outline(AppColors.blueBook),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Aktivitas tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.navy.withOpacity(0.4)),
                  foregroundColor: AppColors.navyDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Batal',
                  style: t.bodyMedium?.copyWith(color: AppColors.navyDark),
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
    );
  }
}

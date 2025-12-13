import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../app/app_colors.dart';
import '../../logbook/data/logbook_service.dart';
import '../../logbook/data/logbook_model.dart';

class CreateLogbookScreen extends StatefulWidget {
  final String studentId;
  final String dosenId;
  final String mentorId;

  const CreateLogbookScreen({
    super.key,
    required this.studentId,
    required this.dosenId,
    required this.mentorId,
  });

  @override
  State<CreateLogbookScreen> createState() => _CreateLogbookScreenState();
}

class _CreateLogbookScreenState extends State<CreateLogbookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _activityController = TextEditingController();
  final _dateController = TextEditingController();

  final LogbookService _logbookService = LogbookService();
  DateTime? _selectedDate;
  DateTime? _startDate; // Tanggal mulai magang
  bool _isLoading = false;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _loadStartDate();
      _isInit = false;
    }
  }

  Future<void> _loadStartDate() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.studentId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        final tgl = data?['tglMulai'];
        if (tgl != null) {
          if (tgl is Timestamp) {
            _startDate = tgl.toDate();
          } else if (tgl is String) {
            _startDate = DateTime.tryParse(tgl);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading start date: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _activityController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDate = _startDate ?? DateTime(now.year - 1);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: now,
      helpText: '', // Hide "Select date" text
      initialEntryMode: DatePickerEntryMode.calendarOnly, // Compact mode
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.blueBook,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.navyDark,
            ),
            datePickerTheme: DatePickerThemeData(
              headerHeadlineStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            '${picked.day} ${_getMonthName(picked.month)} ${picked.year}';
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon pilih tanggal kegiatan')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Validate Date Range
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final checkDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
      );

      if (checkDate.isAfter(today)) {
        throw Exception('Tanggal tidak boleh melebihi hari ini.');
      }

      if (_startDate != null) {
        final start = DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
        );
        if (checkDate.isBefore(start)) {
          throw Exception('Tanggal tidak boleh sebelum mulai magang.');
        }
      }

      // 2. Check Valid Duplicate
      final existingStream = _logbookService.getLogbooksByDateRange(
        widget.studentId,
        checkDate,
        checkDate,
      );

      final existingList = await existingStream.first;
      final conflict = existingList.where((log) {
        final logDate = DateTime(log.date.year, log.date.month, log.date.day);
        if (!logDate.isAtSameMomentAs(checkDate)) return false;
        final status = log.statusDosen.toLowerCase();
        return status == 'approved' || status == 'pending';
      });

      if (conflict.isNotEmpty) {
        throw Exception('Logbook tanggal ini sudah ada (Menunggu / Disetujui)');
      }

      // 3. Create
      final newLogbook = LogbookModel(
        studentId: widget.studentId,
        date: _selectedDate!,
        activity: _activityController.text,
        judulKegiatan: _titleController.text,
        statusDosen: 'pending',
        dosenId: widget.dosenId,
        mentorId: widget.mentorId,
        createdAt: DateTime.now(),
        // Optional fields default to empty string if model requires them
        komentar: '',
      );

      await _logbookService.createLogbook(newLogbook);

      if (mounted) {
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Container with gradient background
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade400,
                      Colors.deepOrange.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                'Perhatian',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.navyDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.navy.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blueBook,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Mengerti',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Catat Logbook',
          style: t.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildFormCard(t),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blueBook,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.blueBook.withOpacity(0.4),
                        ),
                        child: Text(
                          'Simpan Logbook',
                          style: t.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFormCard(TextTheme t) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Judul Kegiatan', t),
          const SizedBox(height: 8),
          TextFormField(
            controller: _titleController,
            style: const TextStyle(color: AppColors.navyDark),
            decoration: _inputDecoration('Contoh: Meeting Proyek'),
            validator: (val) =>
                val == null || val.isEmpty ? 'Judul wajib diisi' : null,
          ),
          const SizedBox(height: 20),
          _buildLabel('Tanggal', t),
          const SizedBox(height: 8),
          TextFormField(
            controller: _dateController,
            readOnly: true,
            onTap: _pickDate,
            style: const TextStyle(color: AppColors.navyDark),
            decoration: _inputDecoration('Pilih Tanggal').copyWith(
              suffixIcon: const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.blueBook,
              ),
            ),
            validator: (val) =>
                val == null || val.isEmpty ? 'Tanggal wajib diisi' : null,
          ),
          const SizedBox(height: 20),
          _buildLabel('Aktivitas', t),
          const SizedBox(height: 8),
          TextFormField(
            controller: _activityController,
            maxLines: 5,
            style: const TextStyle(color: AppColors.navyDark),
            decoration: _inputDecoration('Deskripsikan kegiatan hari ini...'),
            validator: (val) =>
                val == null || val.isEmpty ? 'Aktivitas wajib diisi' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, TextTheme t) {
    return Text(
      text,
      style: t.bodyMedium?.copyWith(
        color: AppColors.navyDark,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.navy.withOpacity(0.4)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.navy.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.navy.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.blueBook, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

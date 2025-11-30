import 'package:flutter/material.dart';
import '../models/logbook_model.dart';

class LogbookFormDialog extends StatefulWidget {
  final LogbookModel? initialLogbook;
  final String studentId;
  final String dosenId;
  final String mentorId;
  final Function(LogbookModel) onSave;

  const LogbookFormDialog({
    super.key,
    this.initialLogbook,
    required this.studentId,
    required this.dosenId,
    required this.mentorId,
    required this.onSave,
  });

  @override
  State<LogbookFormDialog> createState() => _LogbookFormDialogState();
}

class _LogbookFormDialogState extends State<LogbookFormDialog> {
  late TextEditingController _activityController;
  late DateTime _selectedDate;
  late TextEditingController _judulController;

  @override
  void initState() {
    super.initState();
    if (widget.initialLogbook != null) {
      _activityController = TextEditingController(
        text: widget.initialLogbook!.activity,
      );
      _selectedDate = widget.initialLogbook!.date;
      _judulController = TextEditingController(
        text: widget.initialLogbook!.judulKegiatan,
      );
    } else {
      _activityController = TextEditingController();
      _selectedDate = DateTime.now();
      _judulController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _activityController.dispose();
    _judulController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialLogbook == null ? 'Catat Hari Ini' : 'Edit Logbook',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date Picker
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tanggal: ${_selectedDate.toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const Icon(Icons.calendar_today, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Activity Input
            TextField(
              controller: _activityController,
              decoration: InputDecoration(
                labelText: 'Aktivitas',
                hintText: 'Masukkan deskripsi aktivitas',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            // Komentar Input (Optional)
            TextField(
              controller: _judulController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_activityController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Aktivitas tidak boleh kosong')),
              );
              return;
            }

            final logbook = LogbookModel(
              id: widget.initialLogbook?.id,
              studentId: widget.studentId,
              date: _selectedDate,
              activity: _activityController.text,
              judulKegiatan: _judulController.text,
              komentar: widget.initialLogbook?.komentar ?? 'pending',
              statusDosen: widget.initialLogbook?.statusDosen ?? 'pending',
              statusMentor: widget.initialLogbook?.statusMentor ?? 'pending',
              dosenId: widget.dosenId,
              mentorId: widget.mentorId,
            );

            widget.onSave(logbook);
            Navigator.pop(context);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

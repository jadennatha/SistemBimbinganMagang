import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/logbook_model.dart';
import '../data/logbook_service.dart';
import 'logbook_form_dialog.dart';

class LogbookContent extends StatefulWidget {
  const LogbookContent({super.key});

  @override
  State<LogbookContent> createState() => _LogbookContentState();
}

class _LogbookContentState extends State<LogbookContent> {
  final LogbookService _logbookService = LogbookService();
  late String _studentId;
  late String _dosenId;
  late String _mentorId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _showLogbookForm({LogbookModel? logbook}) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => LogbookFormDialog(
        initialLogbook: logbook,
        studentId: _studentId,
        dosenId: _dosenId,
        mentorId: _mentorId,
        onSave: (LogbookModel newLogbook) async {
          try {
            if (logbook == null) {
              // Create new logbook
              await _logbookService.createLogbook(newLogbook);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logbook berhasil ditambahkan')),
                );
              }
            } else {
              // Update existing logbook
              await _logbookService.updateLogbook(logbook.id!, newLogbook);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logbook berhasil diupdate')),
                );
              }
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          }
        },
      ),
    );
  }

  Future<void> _deleteLogbook(String logbookId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Hapus Logbook'),
        content: const Text('Apakah Anda yakin ingin menghapus logbook ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _logbookService.deleteLogbook(logbookId);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logbook berhasil dihapus')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Logbook'),
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: Colors.white,
            titleTextStyle: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showLogbookForm(),
                      icon: const Icon(Icons.add),
                      label: const Text('Catat Hari Ini'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    StreamBuilder<List<LogbookModel>>(
                      stream: _logbookService.getStudentLogbooks(_studentId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final logbooks = snapshot.data ?? [];

                        if (logbooks.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text(
                                'Belum ada logbook. Mulai dengan klik "Catat Hari Ini"',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: logbooks.length,
                          itemBuilder: (context, index) {
                            final logbook = logbooks[index];
                            return _buildLogbookCard(logbook);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildLogbookCard(LogbookModel logbook) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  logbook.date.toString().split(' ')[0],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showLogbookForm(logbook: logbook),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteLogbook(logbook.id!),
                      tooltip: 'Hapus',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(logbook.activity, style: const TextStyle(fontSize: 16)),
            if (logbook.komentar.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Komentar: ${logbook.komentar}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusChip('Dosen', logbook.statusDosen),
                _buildStatusChip('Mentor', logbook.statusMentor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String status) {
    Color statusColor = Colors.grey;
    if (status == 'approved') {
      statusColor = Colors.green;
    } else if (status == 'rejected') {
      statusColor = Colors.red;
    }

    return Chip(
      label: Text('$label: $status'),
      backgroundColor: statusColor.withOpacity(0.2),
      labelStyle: TextStyle(color: statusColor, fontSize: 12),
    );
  }
}

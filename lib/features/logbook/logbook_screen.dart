import 'package:flutter/material.dart';

class LogbookScreen extends StatelessWidget {
  const LogbookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logbook')),
      body: const Center(child: Text('Halaman Logbook (sementara)')),
    );
  }
}

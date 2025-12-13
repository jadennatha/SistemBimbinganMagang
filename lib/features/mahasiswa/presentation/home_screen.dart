import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../core/services/local_notification_service.dart';
import '../../notification/presentation/notification_screen.dart';
import 'dashboard_content.dart';
import 'logbook_content.dart';
import 'profile_content.dart';
import 'floating_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Start listening for notifications when home screen loads
    LocalNotificationService().startListening();
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildTabContent() {
    switch (_currentIndex) {
      case 0:
        return const DashboardContent();
      case 1:
        return const LogbookContent();
      case 2:
        return const NotificationScreen();
      case 3:
      default:
        return const ProfileContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildTabContent(),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: FloatingNavBar(
            currentIndex: _currentIndex,
            onChanged: _onTabChanged,
          ),
        ),
      ),
    );
  }
}

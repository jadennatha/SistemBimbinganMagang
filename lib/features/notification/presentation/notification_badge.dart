import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/notification_service.dart';

/// Widget untuk menampilkan badge notifikasi dengan jumlah unread
class NotificationBadge extends StatelessWidget {
  const NotificationBadge({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return child;
    }

    final notificationService = NotificationService();

    return StreamBuilder<int>(
      stream: notificationService.getUnreadCountStream(user.uid),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        if (unreadCount == 0) {
          return child;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Center(
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

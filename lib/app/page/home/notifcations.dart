import 'package:aida/core/theme_colors.dart';
import 'package:aida/models/notification_model.dart';
import 'package:aida/services/notification_service.dart';
import 'package:aida/services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // Marquer tout comme lu quand on ouvre la page
    Future.delayed(const Duration(seconds: 1), () {
      NotificationService.markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeColors.getSurfaceColor(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconlyLight.arrow_left_2,
              color: ThemeColors.getTextColor(context),
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: ThemeColors.getTextColor(context),
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: HiveService.notificationsBox.listenable(),
            builder: (context, box, _) {
              if (box.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => _confirmClearAll(),
                child: Text(
                  'Tout effacer',
                  style: TextStyle(
                    color: ThemeColors.getErrorColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: HiveService.notificationsBox.listenable(),
        builder: (context, Box<NotificationModel> box, _) {
          final notifications = NotificationService.getAllNotifications();

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(notification)
                .animate()
                .fadeIn(delay: (index * 50).ms)
                .slideX(begin: 0.1, end: 0);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: ThemeColors.getPrimaryColor(context).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              IconlyBold.notification,
              size: 64,
              color: ThemeColors.getPrimaryColor(context),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            'Tout est calme',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: ThemeColors.getTextColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tes notifications s\'afficheront ici\npour te garder motivée !',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: ThemeColors.getSecondaryTextColor(context),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final bool isUnread = !notification.isRead;
    final color = _getNotificationColor(notification.type);
    final icon = _getNotificationIcon(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => NotificationService.deleteNotification(notification.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: ThemeColors.getErrorColor(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(IconlyBold.delete, color: ThemeColors.getErrorColor(context)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread 
              ? ThemeColors.getPrimaryColor(context).withOpacity(0.05) 
              : ThemeColors.getCardColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnread 
                ? ThemeColors.getPrimaryColor(context).withOpacity(0.2) 
                : ThemeColors.getBorderColor(context),
            width: isUnread ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                            color: ThemeColors.getTextColor(context),
                          ),
                        ),
                      ),
                      Text(
                        _formatTime(notification.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: ThemeColors.getSecondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeColors.getSecondaryTextColor(context),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'reminder': return const Color(0xFFFF4D6D);
      case 'motivation': return const Color(0xFF9181F4);
      case 'system': return const Color(0xFF4ECDC4);
      default: return ThemeColors.getPrimaryColor(context);
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'reminder': return Icons.water_drop;
      case 'motivation': return Icons.auto_awesome;
      case 'system': return IconlyBold.notification;
      default: return IconlyBold.message;
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return DateFormat('HH:mm').format(date);
    }
    return DateFormat('dd MMM').format(date);
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tout effacer ?'),
        content: const Text('Toutes vos notifications seront supprimées définitivement.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              HiveService.notificationsBox.clear();
              NotificationService.unreadCount.value = 0;
              Navigator.pop(context);
              setState(() {});
            },
            child: Text(
              'Effacer',
              style: TextStyle(color: ThemeColors.getErrorColor(context)),
            ),
          ),
        ],
      ),
    );
  }
}

enum NotificationType {
  lowStock,
  saleConfirmation,
  dailySummary,
  welcome,
}

class AppNotification {
  final int id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime dateTime;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.dateTime,
    this.isRead = false,
  });

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String get icon {
    switch (type) {
      case NotificationType.lowStock:
        return '⚠️';
      case NotificationType.saleConfirmation:
        return '✅';
      case NotificationType.dailySummary:
        return '📊';
      case NotificationType.welcome:
        return '👋';
    }
  }
}

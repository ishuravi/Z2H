import 'package:flutter/material.dart';

class NotificationsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];

  List<Map<String, dynamic>> get notifications => _notifications;

  void setNotifications(List<Map<String, dynamic>> notifications) {
    _notifications = notifications;
    notifyListeners();
  }

  int get unreadCount => _notifications.where((n) => !n['isRead']).length;

  void markAsRead(int index) {
    _notifications[index]['isRead'] = true;
    notifyListeners();
  }

  void addNotification(Map<String, dynamic> notification) {
    _notifications.add(notification);
    notifyListeners();
  }
}

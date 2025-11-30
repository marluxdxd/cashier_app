import 'package:flutter/material.dart';

class SyncStatus with ChangeNotifier {
  bool _isSyncing = false;
  bool _isOnline = true;
  bool _hasPending = false;

  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  bool get hasPending => _hasPending;

  void startSync() {
    _isSyncing = true;
    notifyListeners();
  }

  void finishSync({bool success = true}) {
    _isSyncing = false;
    _hasPending = !success; // if failed, mark as pending
    notifyListeners();
  }

  void updateOnlineStatus(bool online) {
    _isOnline = online;
    notifyListeners();
  }

  void updatePendingStatus(bool pending) {
    _hasPending = pending;
    notifyListeners();
  }
}

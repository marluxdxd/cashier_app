import 'dart:async';
import 'dart:io';

class SyncQueue {
  SyncQueue._();
  static final SyncQueue instance = SyncQueue._();

  final List<Future Function()> _queue = [];
  bool _running = false;
  Timer? _retryTimer;

  /// Add a sync task to the queue
  void add(Future Function() action) {
    _queue.add(action);
    _run();
    _startAutoRetry();
  }

  /// Runs tasks one-by-one
  Future<void> _run() async {
    if (_running) return;
    _running = true;

    while (_queue.isNotEmpty) {
      final action = _queue.removeAt(0);
      try {
        // Only run if online
        if (await _isOnline()) {
          await action();
        } else {
          // If offline, re-add the action to the end of the queue
          _queue.add(action);
          print("⚠ Offline → will retry queued action later");
          break; // exit loop to avoid busy-waiting
        }
      } catch (e) {
        print("⚠ SyncQueue task failed: $e");
      }
    }

    _running = false;
  }

  /// Auto retry every 10 seconds
  void _startAutoRetry() {
    if (_retryTimer != null) return;

    _retryTimer = Timer.periodic(Duration(seconds: 10), (_) async {
      if (_queue.isNotEmpty && await _isOnline()) {
        print("🔄 Auto-retrying pending sync tasks...");
        _run();
      }
    });
  }

  /// Check internet connectivity
  Future<bool> _isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

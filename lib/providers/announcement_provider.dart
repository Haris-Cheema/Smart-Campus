import 'package:flutter/foundation.dart';
import 'package:smart_campus/models/announcement_model.dart';

class AnnouncementProvider extends ChangeNotifier {
  final List<AnnouncementModel> _announcements = [
    AnnouncementModel(
      id: '1',
      title: 'Library Hours Extended',
      description:
          'Library hours have been extended for finals week. Now open until 10 PM on weekdays.',
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AnnouncementModel(
      id: '2',
      title: 'Campus WiFi Maintenance',
      description:
          'WiFi will be down for maintenance on Saturday from 2 AM to 6 AM. Plan accordingly.',
      status: 'urgent',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AnnouncementModel(
      id: '3',
      title: 'Sports Week Registration',
      description:
          'Register for the annual NTU Sports Week! Events include cricket, football, badminton, and athletics. Last date to register is May 15.',
      status: 'active',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    AnnouncementModel(
      id: '4',
      title: 'Parking Lot B Closed',
      description:
          'Parking Lot B is closed for resurfacing until next Monday. Use the main parking area instead.',
      status: 'resolved',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  bool _isLoading = false;
  String? _error;

  List<AnnouncementModel> get announcements => List.unmodifiable(_announcements);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // CREATE
  Future<void> addAnnouncement({
    required String title,
    required String description,
    String status = 'active',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final announcement = AnnouncementModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        status: status,
        createdAt: DateTime.now(),
      );

      _announcements.insert(0, announcement);
      _error = null;
    } catch (e) {
      _error = 'Failed to add announcement: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // READ single
  AnnouncementModel? getById(String id) {
    try {
      return _announcements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // UPDATE
  Future<void> updateAnnouncement({
    required String id,
    String? title,
    String? description,
    String? status,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _announcements.indexWhere((a) => a.id == id);
      if (index != -1) {
        _announcements[index] = _announcements[index].copyWith(
          title: title,
          description: description,
          status: status,
          updatedAt: DateTime.now(),
        );
        _error = null;
      } else {
        _error = 'Announcement not found';
      }
    } catch (e) {
      _error = 'Failed to update announcement: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // DELETE
  Future<void> deleteAnnouncement(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _announcements.removeWhere((a) => a.id == id);
      _error = null;
    } catch (e) {
      _error = 'Failed to delete announcement: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

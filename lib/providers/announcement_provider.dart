import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_campus/models/announcement_model.dart';

class AnnouncementProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = false;
  String? _error;

  List<AnnouncementModel> get announcements => List.unmodifiable(_announcements);
  bool get isLoading => _isLoading;
  String? get error => _error;

  AnnouncementProvider() {
    _fetchAnnouncements();
  }

  // READ all
  Future<void> _fetchAnnouncements() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .get();

      _announcements = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // ensure ID from firestore is used
        return AnnouncementModel.fromJson(data);
      }).toList();
      _error = null;
    } catch (e) {
      debugPrint('Fetch announcements error: $e');
      // On permission denied or not found, just use empty list (free plan fallback)
      if (e.toString().contains('permission-denied') || e.toString().contains('unavailable')) {
        _announcements = [];
        _error = 'Could not load announcements from server. Showing local empty state.';
      } else {
        _error = 'Failed to load announcements: $e';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // CREATE
  Future<void> addAnnouncement({
    required String title,
    required String description,
    String status = 'active',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final docRef = _firestore.collection('announcements').doc();
      final announcement = AnnouncementModel(
        id: docRef.id,
        title: title,
        description: description,
        status: status,
        createdAt: DateTime.now(),
      );

      await docRef.set(announcement.toJson());
      _announcements.insert(0, announcement);
      _error = null;
    } catch (e) {
      debugPrint('Add announcement error: $e');
      _error = 'Failed to add announcement. Check your internet connection.';
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
      final index = _announcements.indexWhere((a) => a.id == id);
      if (index != -1) {
        final updatedAnnouncement = _announcements[index].copyWith(
          title: title,
          description: description,
          status: status,
          updatedAt: DateTime.now(),
        );

        await _firestore.collection('announcements').doc(id).update(updatedAnnouncement.toJson());
        
        _announcements[index] = updatedAnnouncement;
        _error = null;
      } else {
        _error = 'Announcement not found';
      }
    } catch (e) {
      debugPrint('Update announcement error: $e');
      _error = 'Failed to update announcement.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // DELETE
  Future<void> deleteAnnouncement(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.collection('announcements').doc(id).delete();
      _announcements.removeWhere((a) => a.id == id);
      _error = null;
    } catch (e) {
      debugPrint('Delete announcement error: $e');
      _error = 'Failed to delete announcement.';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

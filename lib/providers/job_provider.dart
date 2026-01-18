import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:next_one/data/models/applied_job_model.dart';

class JobProvider extends ChangeNotifier {
  static const String _storageKey = 'applied_jobs';
  List<AppliedJob> _appliedJobs = [];
  bool _isLoaded = false;

  List<AppliedJob> get appliedJobs => List.unmodifiable(_appliedJobs);
  bool get isLoaded => _isLoaded;

  Future<void> loadJobs() async {
    if (_isLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        _appliedJobs = AppliedJob.decodeJobs(jsonString);
      }
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading applied jobs: $e');
      _isLoaded = true; // Mark as loaded even if failed to avoid loops
    }
  }

  Future<void> _saveJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = AppliedJob.encodeJobs(_appliedJobs);
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Error saving applied jobs: $e');
    }
  }

  Future<void> addAppliedJob(AppliedJob job) async {
    _appliedJobs.insert(0, job); // Add to beginning of list (newest first)
    notifyListeners();
    await _saveJobs();
  }

  Future<void> updateJobStatus(String jobId, String newStatus) async {
    final index = _appliedJobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      final job = _appliedJobs[index];
      _appliedJobs[index] = AppliedJob(
        id: job.id,
        title: job.title,
        description: job.description,
        workingHours: job.workingHours,
        requiredMembers: job.requiredMembers,
        durationDays: job.durationDays,
        workDetails: job.workDetails,
        location: job.location,
        wage: job.wage,
        appliedDate: job.appliedDate,
        status: newStatus,
      );
      notifyListeners();
      await _saveJobs();
    }
  }

  Future<void> removeJob(String jobId) async {
    _appliedJobs.removeWhere((job) => job.id == jobId);
    notifyListeners();
    await _saveJobs();
  }

  Future<void> updateJob(AppliedJob updatedJob) async {
    final index = _appliedJobs.indexWhere((job) => job.id == updatedJob.id);
    if (index != -1) {
      _appliedJobs[index] = updatedJob;
      notifyListeners();
      await _saveJobs();
    }
  }
}

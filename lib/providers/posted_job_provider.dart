import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:next_one/data/models/posted_job_model.dart';

class PostedJobProvider extends ChangeNotifier {
  static const String _storageKey = 'posted_jobs';
  List<PostedJob> _postedJobs = [];
  bool _isLoaded = false;

  List<PostedJob> get allJobs => List.unmodifiable(_postedJobs);

  /// Get only active jobs (not completed)
  List<PostedJob> get activeJobs =>
      _postedJobs.where((job) => job.status == 'Active').toList();

  /// Get completed jobs (both parties confirmed)
  List<PostedJob> get completedJobs =>
      _postedJobs.where((job) => job.status == 'Completed').toList();

  bool get isLoaded => _isLoaded;

  /// Initialize and load jobs from storage
  Future<void> loadJobs() async {
    if (_isLoaded) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        _postedJobs = PostedJob.decodeJobs(jsonString);
      }
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading jobs: $e');
      _isLoaded = true;
    }
  }

  /// Save jobs to storage
  Future<void> _saveJobs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = PostedJob.encodeJobs(_postedJobs);
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugPrint('Error saving jobs: $e');
    }
  }

  /// Get a specific job by ID
  PostedJob? getJobById(String jobId) {
    try {
      return _postedJobs.firstWhere((job) => job.id == jobId);
    } catch (e) {
      return null;
    }
  }

  /// Get jobs filtered by category (only active)
  List<PostedJob> getJobsByCategory(String category) {
    return _postedJobs
        .where(
          (job) =>
              job.category.toLowerCase() == category.toLowerCase() &&
              job.status == 'Active',
        )
        .toList();
  }

  /// Add a new posted job (by Work Giver)
  Future<void> addPostedJob(PostedJob job) async {
    _postedJobs.insert(0, job); // Add newest first
    notifyListeners();
    await _saveJobs();
  }

  /// Remove a job (cancel by Work Giver)
  Future<void> removeJob(String jobId) async {
    _postedJobs.removeWhere((job) => job.id == jobId);
    notifyListeners();
    await _saveJobs();
  }

  /// Worker confirms job completion
  Future<void> workerConfirmComplete(String jobId) async {
    final index = _postedJobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      final job = _postedJobs[index];
      _postedJobs[index] = job.copyWith(workerConfirmedComplete: true);

      // Check if both confirmed - then mark as completed
      if (_postedJobs[index].isFullyCompleted) {
        _postedJobs[index] = _postedJobs[index].copyWith(status: 'Completed');
      }

      notifyListeners();
      await _saveJobs();
    }
  }

  /// Work Giver confirms job completion
  Future<void> seekerConfirmComplete(String jobId) async {
    final index = _postedJobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      final job = _postedJobs[index];
      _postedJobs[index] = job.copyWith(seekerConfirmedComplete: true);

      // Check if both confirmed - then mark as completed
      if (_postedJobs[index].isFullyCompleted) {
        _postedJobs[index] = _postedJobs[index].copyWith(status: 'Completed');
      }

      notifyListeners();
      await _saveJobs();
    }
  }

  /// Generate a 4-digit OTP for the job
  String generateOtpForJob(String jobId) {
    // Generate a random 4-digit OTP
    final otp = (1000 + (DateTime.now().millisecondsSinceEpoch % 9000))
        .toString(); // Simple "random" logic for demo

    final index = _postedJobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      final job = _postedJobs[index];
      _postedJobs[index] = job.copyWith(completionOtp: otp);
      _saveJobs(); // Save OTP to storage so it persists
      notifyListeners();
      return otp;
    }
    return '';
  }

  /// Verify OTP and confirm job completion
  bool verifyOtpAndComplete(String jobId, String inputOtp) {
    final index = _postedJobs.indexWhere((job) => job.id == jobId);
    if (index != -1) {
      final job = _postedJobs[index];
      if (job.completionOtp == inputOtp) {
        // OTP Matches - Mark as complete for BOTH parties
        // (Since Seeker gave the code, they explicitly confirmed)
        _postedJobs[index] = job.copyWith(
          workerConfirmedComplete: true,
          seekerConfirmedComplete: true,
          status: 'Completed',
        );
        _saveJobs();
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  /// Check if active jobs exist for a category
  bool hasJobsInCategory(String category) {
    return _postedJobs.any(
      (job) =>
          job.category.toLowerCase() == category.toLowerCase() &&
          job.status == 'Active',
    );
  }
}

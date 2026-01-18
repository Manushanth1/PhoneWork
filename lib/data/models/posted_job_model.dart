import 'dart:convert';

class PostedJob {
  final String id;
  final String category; // Job category like "Mason", "Plumber", etc.
  final String title;
  final String description;
  final String workingHours;
  final int requiredMembers;
  final int durationDays;
  final String workDetails;
  final String location;
  final String wage;
  final DateTime postedDate;
  final String postedBy; // Work Giver name/id
  final String contactNumber;
  final String status; // Active, Completed, Cancelled
  final bool workerConfirmedComplete; // Worker pressed complete
  final bool seekerConfirmedComplete; // Work Giver pressed complete
  final String completionOtp; // OTP for job completion verification

  PostedJob({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.workingHours,
    required this.requiredMembers,
    required this.durationDays,
    required this.workDetails,
    required this.location,
    required this.wage,
    required this.postedDate,
    this.postedBy = 'Anonymous',
    this.contactNumber = '',
    this.status = 'Active',
    this.workerConfirmedComplete = false,
    this.seekerConfirmedComplete = false,
    this.completionOtp = '',
  });

  // Check if job is fully completed (both confirmed)
  bool get isFullyCompleted =>
      workerConfirmedComplete && seekerConfirmedComplete;

  // Check if waiting for other party's confirmation
  bool get isWaitingForWorker =>
      seekerConfirmedComplete && !workerConfirmedComplete;
  bool get isWaitingForSeeker =>
      workerConfirmedComplete && !seekerConfirmedComplete;

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'workingHours': workingHours,
      'requiredMembers': requiredMembers,
      'durationDays': durationDays,
      'workDetails': workDetails,
      'location': location,
      'wage': wage,
      'postedDate': postedDate.toIso8601String(),
      'postedBy': postedBy,
      'contactNumber': contactNumber,
      'status': status,
      'workerConfirmedComplete': workerConfirmedComplete,
      'seekerConfirmedComplete': seekerConfirmedComplete,
      'completionOtp': completionOtp,
    };
  }

  // Create from JSON
  factory PostedJob.fromJson(Map<String, dynamic> json) {
    return PostedJob(
      id: json['id'] ?? '',
      category: json['category'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      workingHours: json['workingHours'] ?? 'Full Day',
      requiredMembers: json['requiredMembers'] ?? 1,
      durationDays: json['durationDays'] ?? 1,
      workDetails: json['workDetails'] ?? '',
      location: json['location'] ?? '',
      wage: json['wage'] ?? '',
      postedDate: DateTime.tryParse(json['postedDate'] ?? '') ?? DateTime.now(),
      postedBy: json['postedBy'] ?? 'Anonymous',
      contactNumber: json['contactNumber'] ?? '',
      status: json['status'] ?? 'Active',
      workerConfirmedComplete: json['workerConfirmedComplete'] ?? false,
      seekerConfirmedComplete: json['seekerConfirmedComplete'] ?? false,
      completionOtp: json['completionOtp'] ?? '',
    );
  }

  // Create a copy with modified fields
  PostedJob copyWith({
    String? id,
    String? category,
    String? title,
    String? description,
    String? workingHours,
    int? requiredMembers,
    int? durationDays,
    String? workDetails,
    String? location,
    String? wage,
    DateTime? postedDate,
    String? postedBy,
    String? contactNumber,
    String? status,
    bool? workerConfirmedComplete,
    bool? seekerConfirmedComplete,
    String? completionOtp,
  }) {
    return PostedJob(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      workingHours: workingHours ?? this.workingHours,
      requiredMembers: requiredMembers ?? this.requiredMembers,
      durationDays: durationDays ?? this.durationDays,
      workDetails: workDetails ?? this.workDetails,
      location: location ?? this.location,
      wage: wage ?? this.wage,
      postedDate: postedDate ?? this.postedDate,
      postedBy: postedBy ?? this.postedBy,
      contactNumber: contactNumber ?? this.contactNumber,
      status: status ?? this.status,
      workerConfirmedComplete:
          workerConfirmedComplete ?? this.workerConfirmedComplete,
      seekerConfirmedComplete:
          seekerConfirmedComplete ?? this.seekerConfirmedComplete,
      completionOtp: completionOtp ?? this.completionOtp,
    );
  }

  // Encode list of jobs to JSON string
  static String encodeJobs(List<PostedJob> jobs) {
    return jsonEncode(jobs.map((job) => job.toJson()).toList());
  }

  // Decode JSON string to list of jobs
  static List<PostedJob> decodeJobs(String jsonString) {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => PostedJob.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}

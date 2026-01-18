import 'dart:convert';

class AppliedJob {
  final String id;
  final String title;
  final String description;
  final String workingHours;
  final int requiredMembers;
  final int durationDays;
  final String workDetails;
  final String location;
  final String wage;
  final DateTime appliedDate;
  final String status; // Pending, Under Review, Accepted, Rejected

  AppliedJob({
    required this.id,
    required this.title,
    required this.description,
    required this.workingHours,
    required this.requiredMembers,
    required this.durationDays,
    required this.workDetails,
    required this.location,
    required this.wage,
    required this.appliedDate,
    this.status = 'Pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'workingHours': workingHours,
      'requiredMembers': requiredMembers,
      'durationDays': durationDays,
      'workDetails': workDetails,
      'location': location,
      'wage': wage,
      'appliedDate': appliedDate.toIso8601String(),
      'status': status,
    };
  }

  factory AppliedJob.fromMap(Map<String, dynamic> map) {
    return AppliedJob(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      workingHours: map['workingHours'],
      requiredMembers: map['requiredMembers'],
      durationDays: map['durationDays'],
      workDetails: map['workDetails'],
      location: map['location'],
      wage: map['wage'],
      appliedDate: DateTime.parse(map['appliedDate']),
      status: map['status'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AppliedJob.fromJson(String source) =>
      AppliedJob.fromMap(json.decode(source));

  static String encodeJobs(List<AppliedJob> jobs) =>
      json.encode(jobs.map((job) => job.toMap()).toList());

  static List<AppliedJob> decodeJobs(String jobs) =>
      (json.decode(jobs) as List<dynamic>)
          .map<AppliedJob>((item) => AppliedJob.fromMap(item))
          .toList();
}

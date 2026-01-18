import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:next_one/data/models/posted_job_model.dart';
import 'package:next_one/data/models/applied_job_model.dart';
import 'package:next_one/providers/job_provider.dart';
import 'package:next_one/providers/posted_job_provider.dart';
import 'package:intl/intl.dart';

class WorkerJobDetailsScreen extends StatefulWidget {
  final PostedJob job;

  const WorkerJobDetailsScreen({super.key, required this.job});

  @override
  State<WorkerJobDetailsScreen> createState() => _WorkerJobDetailsScreenState();
}

class _WorkerJobDetailsScreenState extends State<WorkerJobDetailsScreen> {
  bool _hasApplied = false;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy').format(widget.job.postedDate);

    // Get latest job status from provider
    return Consumer<PostedJobProvider>(
      builder: (context, postedJobProvider, child) {
        final currentJob =
            postedJobProvider.getJobById(widget.job.id) ?? widget.job;
        final workerConfirmed = currentJob.workerConfirmedComplete;
        final seekerConfirmed = currentJob.seekerConfirmedComplete;
        final isWaitingForSeeker = workerConfirmed && !seekerConfirmed;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Job Details'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[700]!, Colors.blue[500]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withAlpha(77),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 28,
                            child: Icon(
                              Icons.work,
                              color: Colors.blue,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentJob.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentJob.category,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withAlpha(204),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Posted on $dateStr',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Confirmation Status Banner
                if (workerConfirmed || seekerConfirmed) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isWaitingForSeeker
                          ? Colors.orange[50]
                          : Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isWaitingForSeeker
                            ? Colors.orange[200]!
                            : Colors.green[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isWaitingForSeeker
                              ? Icons.hourglass_top
                              : Icons.check_circle,
                          color: isWaitingForSeeker
                              ? Colors.orange[700]
                              : Colors.green[700],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isWaitingForSeeker
                                    ? 'Waiting for Work Giver'
                                    : 'Work Giver Confirmed',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isWaitingForSeeker
                                      ? Colors.orange[800]
                                      : Colors.green[800],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isWaitingForSeeker
                                    ? 'You have marked this job complete. Waiting for work giver to confirm.'
                                    : 'The work giver has confirmed. Please mark complete from your side.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Wage Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.currency_rupee,
                        color: Colors.green[700],
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wage / Pay',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            currentJob.wage,
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Job Details Section
                _buildSectionTitle('Job Details'),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.access_time,
                  'Working Hours',
                  currentJob.workingHours,
                ),
                _buildDetailRow(
                  Icons.people,
                  'Required Workers',
                  '${currentJob.requiredMembers} members',
                ),
                _buildDetailRow(
                  Icons.calendar_today,
                  'Duration',
                  '${currentJob.durationDays} days',
                ),
                _buildDetailRow(
                  Icons.location_on,
                  'Location',
                  currentJob.location,
                ),
                const SizedBox(height: 24),

                // Description Section
                _buildSectionTitle('Description'),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    currentJob.description,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                ),
                const SizedBox(height: 24),

                // Work Details Section
                _buildSectionTitle('Particular Work Details'),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    currentJob.workDetails,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Posted By Section
                if (currentJob.postedBy.isNotEmpty) ...[
                  _buildSectionTitle('Posted By'),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.orange[200],
                          child: Icon(Icons.person, color: Colors.orange[800]),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentJob.postedBy,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (currentJob.contactNumber.isNotEmpty)
                              Text(
                                currentJob.contactNumber,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 120), // Space for bottom buttons
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Apply Button (if not applied yet)
                if (!_hasApplied && !workerConfirmed)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _applyForJob(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Apply for this Job',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Mark Complete Button (if applied and not yet confirmed by worker)
                if (_hasApplied && !workerConfirmed) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          _showWorkerCompleteDialog(context, currentJob.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Mark Job Complete',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Already confirmed message
                if (workerConfirmed)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hourglass_bottom, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Waiting for Work Giver confirmation',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: Colors.grey[700]),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _applyForJob(BuildContext context) {
    // Create an AppliedJob from PostedJob
    final appliedJob = AppliedJob(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: widget.job.title,
      description: widget.job.description,
      workingHours: widget.job.workingHours,
      requiredMembers: widget.job.requiredMembers,
      durationDays: widget.job.durationDays,
      workDetails: widget.job.workDetails,
      location: widget.job.location,
      wage: widget.job.wage,
      appliedDate: DateTime.now(),
      status: 'Pending',
    );

    Provider.of<JobProvider>(context, listen: false).addAppliedJob(appliedJob);

    setState(() {
      _hasApplied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully applied for this job!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showWorkerCompleteDialog(BuildContext context, String jobId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _OtpCompletionDialog(jobId: jobId);
      },
    );
  }
}

class _OtpCompletionDialog extends StatefulWidget {
  final String jobId;

  const _OtpCompletionDialog({required this.jobId});

  @override
  State<_OtpCompletionDialog> createState() => _OtpCompletionDialogState();
}

class _OtpCompletionDialogState extends State<_OtpCompletionDialog> {
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  String? _errorText;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _requestOtp() {
    // Generate OTP via provider
    final otp = Provider.of<PostedJobProvider>(
      context,
      listen: false,
    ).generateOtpForJob(widget.jobId);

    // Simulate sending OTP to Work Giver (In real app, this would be SMS)
    // Here we show it in a SnackBar for demo purposes so the user knows what to enter
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP sent to Work Giver: $otp'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'COPY',
          textColor: Colors.white,
          onPressed: () {
            // Copy logic if needed
          },
        ),
      ),
    );

    setState(() {
      _otpSent = true;
    });
  }

  void _verifyOtp() {
    final success = Provider.of<PostedJobProvider>(
      context,
      listen: false,
    ).verifyOtpAndComplete(widget.jobId, _otpController.text);

    if (success) {
      Navigator.pop(context); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'OTP Verified! Job marked as complete. Waiting for work giver to confirm.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        _errorText = 'Invalid OTP. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Complete Job'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'To mark this job as complete, request an OTP from the Work Giver and enter it below.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          if (!_otpSent)
            ElevatedButton(
              onPressed: _requestOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text('Request OTP'),
            )
          else
            Column(
              children: [
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: InputDecoration(
                    labelText: 'Enter 4-digit OTP',
                    border: const OutlineInputBorder(),
                    errorText: _errorText,
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text('Verify & Complete'),
                ),
              ],
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:next_one/data/models/applied_job_model.dart';
import 'package:next_one/screens/job/edit_applied_job_screen.dart';
import 'package:next_one/providers/posted_job_provider.dart';
import 'package:next_one/providers/job_provider.dart';

class AppliedJobDetailsScreen extends StatelessWidget {
  final AppliedJob job;

  const AppliedJobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    // Calculate remaining days and progress
    final now = DateTime.now();
    final endDate = job.appliedDate.add(Duration(days: job.durationDays));
    final totalDays = job.durationDays;
    final daysPassed = now.difference(job.appliedDate).inDays;
    final remainingDays = endDate.difference(now).inDays;
    final progress = totalDays > 0
        ? (daysPassed / totalDays).clamp(0.0, 1.0)
        : 0.0;

    // Status colors
    Color statusColor;
    Color statusBgColor;
    switch (job.status) {
      case 'Accepted':
        statusColor = Colors.green[800]!;
        statusBgColor = Colors.green[100]!;
        break;
      case 'Pending':
        statusColor = Colors.orange[800]!;
        statusBgColor = Colors.orange[100]!;
        break;
      case 'Under Review':
        statusColor = Colors.blue[800]!;
        statusBgColor = Colors.blue[100]!;
        break;
      case 'Completed':
        statusColor = Colors.green[800]!;
        statusBgColor = Colors.green[100]!;
        break;
      default:
        statusColor = Colors.grey[800]!;
        statusBgColor = Colors.grey[100]!;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (job.status == 'Pending' || job.status == 'Under Review')
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditAppliedJobScreen(job: job),
                  ),
                );
              },
            ),
        ],
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
                    blurRadius: 12,
                    offset: const Offset(0, 6),
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
                        child: Icon(Icons.work, color: Colors.blue, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                job.status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Applied on ${DateFormat('dd MMM yyyy').format(job.appliedDate)}',
                    style: TextStyle(
                      color: Colors.white.withAlpha(204),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Progress Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(26),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Progress & Timeline',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Job Progress',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0 ? Colors.green : Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Days Info Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildDayCard(
                          'Days Passed',
                          '$daysPassed',
                          Icons.history,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDayCard(
                          'Remaining',
                          remainingDays >= 0 ? '$remainingDays' : '0',
                          Icons.hourglass_bottom,
                          remainingDays > 3 ? Colors.green : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDayCard(
                          'Total Days',
                          '$totalDays',
                          Icons.calendar_month,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Job Details Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(26),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Job Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.description,
                    'Description',
                    job.description,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.access_time,
                    'Working Hours',
                    job.workingHours,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.people,
                    'Required Members',
                    '${job.requiredMembers} member${job.requiredMembers > 1 ? 's' : ''}',
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                    Icons.work_history,
                    'Work Details',
                    job.workDetails,
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.location_on, 'Location', job.location),
                  const Divider(height: 24),
                  _buildInfoRow(Icons.currency_rupee, 'Wage / Pay', job.wage),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            if (job.status == 'Pending' || job.status == 'Under Review')
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showCompleteDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Mark Job Complete',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Job cancelled'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.red[300]!),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Cancel Application',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _OtpCompletionDialog(jobId: job.id);
      },
    );
  }

  Widget _buildDayCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey[500], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
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

    // Simulate sending OTP to Work Giver
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OTP sent to Work Giver: $otp'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'COPY',
          textColor: Colors.white,
          onPressed: () {},
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
      // Also update local job provider status
      Provider.of<JobProvider>(
        context,
        listen: false,
      ).updateJobStatus(widget.jobId, 'Waiting for Confirmation');

      Navigator.pop(context); // Close dialog
      Navigator.pop(context); // Close details screen (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'OTP Verified! Job marked as complete. Waiting for confirmation.',
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:next_one/providers/job_provider.dart';
import 'package:next_one/providers/posted_job_provider.dart';
import 'package:next_one/screens/job/applied_job_details_screen.dart';
import 'package:intl/intl.dart';

class ActivityScreen extends StatefulWidget {
  final bool isWorkerMode;

  const ActivityScreen({super.key, this.isWorkerMode = true});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          indicatorWeight: 3,
          tabs: widget.isWorkerMode
              ? const [Tab(text: 'History'), Tab(text: 'Applied')]
              : const [Tab(text: 'History'), Tab(text: 'Posted')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.isWorkerMode
            ? [_buildHistoryTab(), _buildAppliedJobsTab()]
            : [_buildHistoryTab(), _buildPostedJobsTab()],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<PostedJobProvider>(
      builder: (context, postedJobProvider, child) {
        // Get completed jobs from provider
        final completedJobs = postedJobProvider.allJobs
            .where((job) => job.status == 'Completed')
            .toList();

        if (completedJobs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history,
            title: 'No History Yet',
            subtitle: 'Your completed jobs will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completedJobs.length,
          itemBuilder: (context, index) {
            final job = completedJobs[index];
            final dateStr = DateFormat('dd MMM yyyy').format(job.postedDate);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green[50],
                          radius: 28,
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${job.workingHours} • ${job.durationDays} days',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Completed',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            job.location,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        Icon(
                          Icons.currency_rupee,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          job.wage,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Completed on $dateStr',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAppliedJobsTab() {
    return Consumer<JobProvider>(
      builder: (context, jobProvider, child) {
        final appliedJobs = jobProvider.appliedJobs;

        if (appliedJobs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.work_outline,
            title: 'No Applied Jobs',
            subtitle: 'Jobs you apply for will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appliedJobs.length,
          itemBuilder: (context, index) {
            final job = appliedJobs[index];
            final status = job.status;

            Color statusColor;
            Color statusBgColor;
            switch (status) {
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
              default:
                statusColor = Colors.grey[800]!;
                statusBgColor = Colors.grey[100]!;
            }

            final dateStr = DateFormat('dd MMM yyyy').format(job.appliedDate);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppliedJobDetailsScreen(job: job),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue[50],
                            radius: 24,
                            child: const Icon(
                              Icons.work,
                              color: Colors.blue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${job.workingHours} • ${job.durationDays} days • ${job.requiredMembers} members',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            job.location,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.currency_rupee,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            job.wage,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Applied on $dateStr',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPostedJobsTab() {
    return Consumer<PostedJobProvider>(
      builder: (context, postedJobProvider, child) {
        // Only show active jobs (not completed)
        final postedJobs = postedJobProvider.activeJobs;

        if (postedJobs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.post_add,
            title: 'No Posted Jobs',
            subtitle: 'Jobs you post for workers will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: postedJobs.length,
          itemBuilder: (context, index) {
            final job = postedJobs[index];
            final dateStr = DateFormat('dd MMM yyyy').format(job.postedDate);

            // Check confirmation status
            final seekerConfirmed = job.seekerConfirmedComplete;
            final workerConfirmed = job.workerConfirmedComplete;
            final waitingForWorker = seekerConfirmed && !workerConfirmed;

            // Status badge
            String statusText;
            Color statusBgColor;
            Color statusTextColor;

            if (waitingForWorker) {
              statusText = 'Waiting for Worker';
              statusBgColor = Colors.orange[100]!;
              statusTextColor = Colors.orange[800]!;
            } else if (workerConfirmed && !seekerConfirmed) {
              statusText = 'Worker Confirmed';
              statusBgColor = Colors.blue[100]!;
              statusTextColor = Colors.blue[800]!;
            } else {
              statusText = 'Active';
              statusBgColor = Colors.green[100]!;
              statusTextColor = Colors.green[800]!;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: workerConfirmed
                              ? Colors.blue[50]
                              : Colors.green[50],
                          radius: 24,
                          child: Icon(
                            workerConfirmed
                                ? Icons.hourglass_bottom
                                : Icons.work,
                            color: workerConfirmed
                                ? Colors.blue[700]
                                : Colors.green[700],
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${job.workingHours} • ${job.durationDays} days',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusTextColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            job.location,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        Icon(
                          Icons.currency_rupee,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          job.wage,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Posted on $dateStr',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    // Show confirmation status message
                    if (workerConfirmed && !seekerConfirmed) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Worker has marked this job complete. Please confirm.',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Buttons based on confirmation status
                    if (!seekerConfirmed) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _showSeekerCompleteDialog(context, job.id),
                              icon: const Icon(Icons.check_circle_outline),
                              label: Text(
                                workerConfirmed
                                    ? 'Confirm Complete'
                                    : 'Mark Complete',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: workerConfirmed
                                    ? Colors.blue[600]
                                    : Colors.green[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _showCancelDialog(context, job.id),
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: Colors.red,
                              ),
                              label: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.red),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Seeker already confirmed, waiting for worker
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.hourglass_top,
                              color: Colors.orange[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Waiting for worker to confirm completion.',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSeekerCompleteDialog(BuildContext context, String jobId) {
    // Get the job to check worker confirmation status
    final job = Provider.of<PostedJobProvider>(
      context,
      listen: false,
    ).getJobById(jobId);
    final workerConfirmed = job?.workerConfirmedComplete ?? false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            workerConfirmed ? 'Confirm Completion?' : 'Mark as Complete?',
          ),
          content: Text(
            workerConfirmed
                ? 'The worker has already confirmed. Once you confirm, the job will be marked as completed and moved to History.'
                : 'You are confirming the work is complete. The worker must also confirm for the job to be fully completed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Not Yet'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<PostedJobProvider>(
                  context,
                  listen: false,
                ).seekerConfirmComplete(jobId);
                Navigator.pop(context);

                // Check if job is now fully completed
                final updatedJob = Provider.of<PostedJobProvider>(
                  context,
                  listen: false,
                ).getJobById(jobId);
                final message = updatedJob?.isFullyCompleted ?? false
                    ? 'Job completed! Moved to History.'
                    : 'Your confirmation recorded. Waiting for worker to confirm.';

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: updatedJob?.isFullyCompleted ?? false
                        ? Colors.green
                        : Colors.blue,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: workerConfirmed ? Colors.blue : Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(workerConfirmed ? 'Confirm' : 'Mark Complete'),
            ),
          ],
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context, String jobId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Job?'),
          content: const Text(
            'Are you sure you want to cancel this job? Workers will no longer be able to see or apply for it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No, Keep It'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<PostedJobProvider>(
                  context,
                  listen: false,
                ).removeJob(jobId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Job cancelled successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

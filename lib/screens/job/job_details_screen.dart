import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:next_one/data/models/applied_job_model.dart';
import 'package:next_one/data/models/posted_job_model.dart';
import 'package:next_one/providers/job_provider.dart';
import 'package:next_one/providers/posted_job_provider.dart';
import 'package:next_one/providers/user_provider.dart';

class JobDetailsScreen extends StatefulWidget {
  final String jobTitle;
  final bool isWorkerMode;

  const JobDetailsScreen({
    super.key,
    required this.jobTitle,
    required this.isWorkerMode,
  });

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _membersController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _workDetailsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _wageController = TextEditingController();

  String _selectedHours = 'Full Day';
  final List<String> _hoursOptions = ['Full Day', 'Half Day', 'Hourly'];

  @override
  void dispose() {
    _descriptionController.dispose();
    _membersController.dispose();
    _daysController.dispose();
    _workDetailsController.dispose();
    _locationController.dispose();
    _wageController.dispose();
    super.dispose();
  }

  void _submitJob() {
    if (_formKey.currentState!.validate()) {
      if (widget.isWorkerMode) {
        // Worker mode: Add to applied jobs (worker applying for work)
        final appliedJob = AppliedJob(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: widget.jobTitle,
          description: _descriptionController.text,
          workingHours: _selectedHours,
          requiredMembers: int.tryParse(_membersController.text) ?? 1,
          durationDays: int.tryParse(_daysController.text) ?? 1,
          workDetails: _workDetailsController.text,
          location: _locationController.text,
          wage: _wageController.text,
          appliedDate: DateTime.now(),
          status: 'Pending',
        );

        Provider.of<JobProvider>(
          context,
          listen: false,
        ).addAppliedJob(appliedJob);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job applied successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Work Giver mode: Post job for workers to see
        final postedJob = PostedJob(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          category: widget.jobTitle,
          title: widget.jobTitle,
          description: _descriptionController.text,
          workingHours: _selectedHours,
          requiredMembers: int.tryParse(_membersController.text) ?? 1,
          durationDays: int.tryParse(_daysController.text) ?? 1,
          workDetails: _workDetailsController.text,
          location: _locationController.text,
          wage: _wageController.text,
          postedDate: DateTime.now(),
          postedBy:
              Provider.of<UserProvider>(
                context,
                listen: false,
              ).user?.fullName ??
              'Work Giver',
        );

        Provider.of<PostedJobProvider>(
          context,
          listen: false,
        ).addPostedJob(postedJob);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job posted successfully! Workers can now apply.'),
            backgroundColor: Colors.green,
          ),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = widget.isWorkerMode ? Colors.blue : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jobTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: themeColor.withAlpha(51)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: themeColor,
                      radius: 25,
                      child: Icon(
                        widget.isWorkerMode
                            ? Icons.engineering
                            : Icons.person_search,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.jobTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.isWorkerMode
                                ? 'Offering your skills'
                                : 'Hiring for this role',
                            style: TextStyle(
                              color: themeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Full Description
              const Text(
                'Full Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe the job in detail...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Working Hours
              const Text(
                'Working Hours',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedHours,
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedHours = newValue!;
                      });
                    },
                    items: _hoursOptions.map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Required Members and Duration Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Required Members',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _membersController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'e.g., 5',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            prefixIcon: const Icon(Icons.people),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Duration (Days)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _daysController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'e.g., 10',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Particular Work Details
              const Text(
                'What is the Particular Work?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _workDetailsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'Describe specific tasks, requirements, or skills needed...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter work details';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Location
              const Text(
                'Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Enter work location or area...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Wage/Pay
              const Text(
                'Wage / Pay',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _wageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g., ₹500 per day',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(Icons.currency_rupee),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter wage/pay';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitJob,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Post Job',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

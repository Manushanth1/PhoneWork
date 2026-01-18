import 'package:flutter/material.dart';
import 'package:next_one/screens/job/job_details_screen.dart';
import 'package:next_one/screens/profile/profile_screen.dart';
import 'package:next_one/screens/worker/worker_job_list_screen.dart';

// Professional color palette
const Color _primaryColor = Color(0xFF1A365D);
const Color _accentColor = Color(0xFF2B6CB0);
const Color _workerColor = Color(0xFF2563EB);
const Color _giverColor = Color(0xFF059669);
const Color _textDark = Color(0xFF1A202C);
const Color _textMuted = Color(0xFF718096);
const Color _borderColor = Color(0xFFE2E8F0);
const Color _bgColor = Color(0xFFF7FAFC);
const Color _lightAccent = Color(0xFFEBF4FF);

class CategoriesScreen extends StatefulWidget {
  final bool isWorkerMode;
  final Function(bool)? onModeChanged;

  const CategoriesScreen({
    super.key,
    this.isWorkerMode = true,
    this.onModeChanged,
  });

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  late bool _isWorkerMode;
  List<String> _searchResults = [];
  final List<String> _userAddedJobs = [];
  List<String> _allJobs = [];

  @override
  void initState() {
    super.initState();
    _isWorkerMode = widget.isWorkerMode;
    // Aggregate all jobs into one master list for searching
    _allJobs = [
      ..._constructionJobs,
      ..._skilledJobs,
      ..._factoryJobs,
      ..._drivingJobs,
      ..._deliveryJobs,
      ..._agricultureJobs,
      ..._serviceJobs,
      ..._securityJobs,
      ..._industryJobs,
      ..._dailyWageJobs,
    ];
  }

  @override
  void didUpdateWidget(CategoriesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isWorkerMode != widget.isWorkerMode) {
      setState(() {
        _isWorkerMode = widget.isWorkerMode;
      });
    }
  }

  void _toggleMode(bool isWorker) {
    setState(() {
      _isWorkerMode = isWorker;
    });
    widget.onModeChanged?.call(isWorker);
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _isSearching = true;
      _searchResults = _allJobs
          .where((job) => job.toLowerCase().contains(lowerQuery))
          .toList();
    });
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sort By',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption(context, Icons.sort_by_alpha, 'A to Z', 'az'),
            _buildSortOption(context, Icons.sort_by_alpha, 'Z to A', 'za'),
            _buildSortOption(
              context,
              Icons.category_rounded,
              'By Category',
              'category',
            ),
            _buildSortOption(
              context,
              Icons.near_me_rounded,
              'Nearest First',
              'nearest',
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _lightAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _accentColor, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, color: _textDark),
      ),
      onTap: () {
        Navigator.pop(context);
        // TODO: Implement sorting logic
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sorted by: $label'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Map Background with gradient overlay
        if (!_isSearching)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_bgColor, _primaryColor.withValues(alpha: 0.05)],
              ),
            ),
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 48,
                      color: _accentColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Find Jobs Near You",
                    style: TextStyle(
                      color: _textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 2. Main Content Overlay
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Worker / Work Giver Toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      // Worker Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _toggleMode(true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: _isWorkerMode
                                  ? const LinearGradient(
                                      colors: [Color(0xFF1E40AF), _workerColor],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: _isWorkerMode ? null : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: _isWorkerMode
                                  ? [
                                      BoxShadow(
                                        color: _workerColor.withValues(
                                          alpha: 0.35,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.engineering,
                                  color: _isWorkerMode
                                      ? Colors.white
                                      : Colors.grey[600],
                                  size: 28,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Worker",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _isWorkerMode
                                        ? Colors.white
                                        : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Offer Skills",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _isWorkerMode
                                        ? Colors.white.withValues(alpha: 0.9)
                                        : Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Work Giver Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _toggleMode(false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: !_isWorkerMode
                                  ? const LinearGradient(
                                      colors: [Color(0xFF047857), _giverColor],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: !_isWorkerMode ? null : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: !_isWorkerMode
                                  ? [
                                      BoxShadow(
                                        color: _giverColor.withValues(
                                          alpha: 0.35,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.person_search,
                                  color: !_isWorkerMode
                                      ? Colors.white
                                      : Colors.grey[600],
                                  size: 28,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Work Giver",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: !_isWorkerMode
                                        ? Colors.white
                                        : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Hire Workers",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: !_isWorkerMode
                                        ? Colors.white.withValues(alpha: 0.9)
                                        : Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _borderColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryColor.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, size: 24, color: _accentColor),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: const InputDecoration(
                            hintText: "Search jobs, skills, categories...",
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: _textMuted,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: const TextStyle(
                            color: _textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (_isSearching)
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                            FocusScope.of(context).unfocus();
                          },
                        )
                      else
                        GestureDetector(
                          onTap: () => _showSortOptions(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _lightAccent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _accentColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.sort_rounded,
                                  size: 18,
                                  color: _accentColor,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Sort",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _accentColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Content Area
              Expanded(
                child: _isSearching
                    ? _buildSearchResults()
                    : _buildCategoriesView(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Container(
        color: Colors.white,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              'No jobs found for "${_searchController.text}"',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to Profile Screen for feedback
                // Assuming ProfileScreen is accessible via a route or direct navigation
                // For now, we'll try to find the parent navigation controller or just print
                // Since we don't have the full routing setup, we'll use a basic Navigator push if possible,
                // or just show a snackbar saying "Redirecting to Feedback..." if we can't easily import ProfileScreen yet.
                // However, the plan says "Navigate to ProfileScreen".
                // I need to import ProfileScreen first.
                // I will add the import in a separate edit or assume it's available.
                // For this block, I'll implement the button.

                // Ideally: Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                // But I need to make sure ProfileScreen is imported.
                // I'll use a placeholder action for now and fix the import in the next step if needed.
                // Actually, I can try to use a named route if one exists, but I don't know the routes.
                // I'll use the class directly and add the import.

                // Wait, I can't add the import in this block easily without replacing the whole file or top.
                // I'll use a dynamic approach or just a snackbar for this specific step and then add the import.
                // OR, I can just write the navigation code and let the linter tell me to import it, then I fix it.
                // That's a valid workflow.

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(isWorkerMode: _isWorkerMode),
                  ),
                );
              },
              icon: const Icon(Icons.feedback),
              label: const Text('Request this Job / Feedback'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final job = _searchResults[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[100],
              child: Icon(_getJobIcon(job), color: Colors.black87),
            ),
            title: Text(
              job,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              if (_isWorkerMode) {
                // Worker mode: Show list of jobs posted by work givers
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkerJobListScreen(category: job),
                  ),
                );
              } else {
                // Work Giver mode: Go to form to post a job
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailsScreen(
                      jobTitle: job,
                      isWorkerMode: _isWorkerMode,
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoriesView() {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 14),
                // Handle bar
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: _borderColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Scrollable Content for Job Categories
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        // 0. User Added Jobs (if any)
                        if (_userAddedJobs.isNotEmpty) ...[
                          _buildJobCategorySection(
                            "Added by You",
                            _userAddedJobs,
                            Colors.teal[50]!,
                          ),
                          const SizedBox(height: 20),
                        ],

                        // 1. Construction & Civil Jobs
                        _buildJobCategorySection(
                          "Construction & Civil",
                          _constructionJobs,
                          Colors.orange[50]!,
                        ),
                        const SizedBox(height: 20),

                        // 2. Skilled Technicians Jobs
                        _buildJobCategorySection(
                          "Skilled Technicians",
                          _skilledJobs,
                          Colors.blue[50]!,
                        ),
                        const SizedBox(height: 20),

                        // 3. Factory & Warehouse Jobs
                        _buildJobCategorySection(
                          "Factory & Warehouse",
                          _factoryJobs,
                          Colors.green[50]!,
                        ),
                        const SizedBox(height: 20),

                        // 4. Driving & Vehicle Jobs
                        _buildJobCategorySection(
                          "Driving & Vehicle",
                          _drivingJobs,
                          Colors.red[50]!,
                        ),
                        const SizedBox(height: 20),

                        // 5. Delivery & Outdoor Field Work Jobs
                        _buildJobCategorySection(
                          "Delivery & Field Work",
                          _deliveryJobs,
                          Colors.purple[50]!,
                        ),
                        const SizedBox(height: 20),

                        // 6. Agriculture & Rural Farm Jobs
                        _buildJobCategorySection(
                          "Agriculture & Farm",
                          _agricultureJobs,
                          Colors.lightGreen[50]!,
                        ),
                        const SizedBox(height: 20),

                        // 7. Market, Shop, Hotel, and Public Services
                        _buildJobCategorySection(
                          "Market, Shop & Hotel",
                          _serviceJobs,
                          Colors.amber[50]!,
                        ),
                        const SizedBox(height: 20),

                        // 8. Security, Cleaning, Public Work
                        _buildJobCategorySection(
                          "Security & Public Work",
                          _securityJobs,
                          Colors.grey[50]!,
                        ),
                        const SizedBox(height: 20),

                        // 9. Heavy Industry, Mining, and Machinery
                        _buildJobCategorySection(
                          "Heavy Industry & Mining",
                          _industryJobs,
                          Colors.blueGrey[50]!,
                        ),
                        const SizedBox(height: 20),

                        // 10. Miscellaneous Hard-Work Daily-Wage Jobs
                        _buildJobCategorySection(
                          "Daily Wage & Miscellaneous",
                          _dailyWageJobs,
                          Colors.brown[50]!,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJobCategorySection(
    String title,
    List<String> jobs,
    Color cardColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_primaryColor, _accentColor],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: _textMuted,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: _buildServiceItem(
                  icon: _getJobIcon(jobs[index]),
                  label: jobs[index],
                  color: cardColor,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getJobIcon(String jobTitle) {
    final lowerJob = jobTitle.toLowerCase();

    // --- 1. Construction & Civil ---
    if (lowerJob.contains('mason') || lowerJob.contains('brick')) {
      return Icons.foundation;
    }
    if (lowerJob.contains('cement') ||
        lowerJob.contains('concrete') ||
        lowerJob.contains('rmc')) {
      return Icons.architecture;
    }
    if (lowerJob.contains('painter') ||
        lowerJob.contains('paint') ||
        lowerJob.contains('putty')) {
      return Icons.format_paint;
    }
    if (lowerJob.contains('carpenter') ||
        lowerJob.contains('wood') ||
        lowerJob.contains('furniture')) {
      return Icons.handyman;
    }
    if (lowerJob.contains('plumber') ||
        lowerJob.contains('pipe') ||
        lowerJob.contains('sanitary')) {
      return Icons.plumbing;
    }
    if (lowerJob.contains('welder') ||
        lowerJob.contains('weld') ||
        lowerJob.contains('fabricat')) {
      return Icons.local_fire_department;
    }
    if (lowerJob.contains('glass') || lowerJob.contains('glaz')) {
      return Icons.window;
    }
    if (lowerJob.contains('roof') || lowerJob.contains('ceiling')) {
      return Icons.roofing;
    }
    if (lowerJob.contains('tile') ||
        lowerJob.contains('marble') ||
        lowerJob.contains('granite')) {
      return Icons.grid_view;
    }
    if (lowerJob.contains('survey')) return Icons.straighten;
    if (lowerJob.contains('crane') ||
        lowerJob.contains('lift') ||
        lowerJob.contains('hoist')) {
      return Icons.construction;
    }
    if (lowerJob.contains('road') ||
        lowerJob.contains('highway') ||
        lowerJob.contains('paver')) {
      return Icons.add_road;
    }
    if (lowerJob.contains('excavat') ||
        lowerJob.contains('jcb') ||
        lowerJob.contains('dozer') ||
        lowerJob.contains('earth')) {
      return Icons.landscape;
    }
    if (lowerJob.contains('borewell')) return Icons.water_damage;
    if (lowerJob.contains('demolition')) return Icons.delete_forever;
    if (lowerJob.contains('bar bender') || lowerJob.contains('steel')) {
      return Icons.linear_scale;
    }
    if (lowerJob.contains('scaffold')) return Icons.stairs;

    // --- 2. Skilled Technicians ---
    if (lowerJob.contains('electric') ||
        lowerJob.contains('wire') ||
        lowerJob.contains('switch')) {
      return Icons.electrical_services;
    }
    if (lowerJob.contains('mechanic') ||
        lowerJob.contains('repair') ||
        lowerJob.contains('technician')) {
      return Icons.build;
    }
    if (lowerJob.contains('ac ') ||
        lowerJob.contains('fridge') ||
        lowerJob.contains('cooling') ||
        lowerJob.contains('geyser')) {
      return Icons.ac_unit;
    }
    if (lowerJob.contains('tv') ||
        lowerJob.contains('cable') ||
        lowerJob.contains('dish') ||
        lowerJob.contains('dth')) {
      return Icons.tv;
    }
    if (lowerJob.contains('cctv') || lowerJob.contains('camera')) {
      return Icons.videocam;
    }
    if (lowerJob.contains('mobile') || lowerJob.contains('phone')) {
      return Icons.smartphone;
    }
    if (lowerJob.contains('laptop') ||
        lowerJob.contains('computer') ||
        lowerJob.contains('hardware')) {
      return Icons.computer;
    }
    if (lowerJob.contains('solar')) return Icons.solar_power;
    if (lowerJob.contains('lift') ||
        lowerJob.contains('elevator') ||
        lowerJob.contains('escalator')) {
      return Icons.elevator;
    }
    if (lowerJob.contains('lock') || lowerJob.contains('key')) {
      return Icons.lock;
    }
    if (lowerJob.contains('shoe') || lowerJob.contains('cobbler')) {
      return Icons.hiking;
    }
    if (lowerJob.contains('tailor') ||
        lowerJob.contains('stitch') ||
        lowerJob.contains('embroid')) {
      return Icons.cut;
    }
    if (lowerJob.contains('sound') ||
        lowerJob.contains('dj') ||
        lowerJob.contains('speaker')) {
      return Icons.speaker;
    }
    if (lowerJob.contains('generator') ||
        lowerJob.contains('motor') ||
        lowerJob.contains('pump')) {
      return Icons.settings_power;
    }

    // --- 3. Factory & Warehouse ---
    if (lowerJob.contains('factory') ||
        lowerJob.contains('industry') ||
        lowerJob.contains('plant')) {
      return Icons.factory;
    }
    if (lowerJob.contains('machine') ||
        lowerJob.contains('operator') ||
        lowerJob.contains('cnc') ||
        lowerJob.contains('lathe')) {
      return Icons.precision_manufacturing;
    }
    if (lowerJob.contains('warehouse') ||
        lowerJob.contains('store') ||
        lowerJob.contains('stock') ||
        lowerJob.contains('godown')) {
      return Icons.warehouse;
    }
    if (lowerJob.contains('pack') ||
        lowerJob.contains('box') ||
        lowerJob.contains('carton')) {
      return Icons.inventory_2;
    }
    if (lowerJob.contains('forklift') ||
        lowerJob.contains('loader') ||
        lowerJob.contains('stacker')) {
      return Icons.local_shipping;
    }
    if (lowerJob.contains('textile') ||
        lowerJob.contains('cloth') ||
        lowerJob.contains('garment') ||
        lowerJob.contains('loom')) {
      return Icons.checkroom;
    }
    if (lowerJob.contains('print') ||
        lowerJob.contains('press') ||
        lowerJob.contains('offset')) {
      return Icons.print;
    }
    if (lowerJob.contains('chemical') ||
        lowerJob.contains('acid') ||
        lowerJob.contains('paint mix')) {
      return Icons.science;
    }
    if (lowerJob.contains('food') ||
        lowerJob.contains('biscuit') ||
        lowerJob.contains('bakery') ||
        lowerJob.contains('snack')) {
      return Icons.cookie;
    }
    if (lowerJob.contains('plastic') || lowerJob.contains('mould')) {
      return Icons.category;
    }
    if (lowerJob.contains('sort') || lowerJob.contains('check')) {
      return Icons.fact_check;
    }

    // --- 4. Driving & Vehicle ---
    if (lowerJob.contains('driver') || lowerJob.contains('driving')) {
      return Icons.drive_eta;
    }
    if (lowerJob.contains('bus')) return Icons.directions_bus;
    if (lowerJob.contains('truck') ||
        lowerJob.contains('lorry') ||
        lowerJob.contains('tanker') ||
        lowerJob.contains('container')) {
      return Icons.local_shipping;
    }
    if (lowerJob.contains('bike') ||
        lowerJob.contains('scooter') ||
        lowerJob.contains('rider')) {
      return Icons.two_wheeler;
    }
    if (lowerJob.contains('auto') || lowerJob.contains('rickshaw')) {
      return Icons.electric_rickshaw;
    }
    if (lowerJob.contains('taxi') || lowerJob.contains('cab')) {
      return Icons.local_taxi;
    }
    if (lowerJob.contains('train') ||
        lowerJob.contains('metro') ||
        lowerJob.contains('rail') ||
        lowerJob.contains('loco')) {
      return Icons.train;
    }
    if (lowerJob.contains('flight') ||
        lowerJob.contains('airport') ||
        lowerJob.contains('runway')) {
      return Icons.flight;
    }
    if (lowerJob.contains('boat') || lowerJob.contains('ship')) {
      return Icons.directions_boat;
    }
    if (lowerJob.contains('ambulance')) return Icons.medical_services;
    if (lowerJob.contains('fire')) return Icons.local_fire_department;
    if (lowerJob.contains('parking') || lowerJob.contains('valet')) {
      return Icons.local_parking;
    }
    if (lowerJob.contains('wash') && lowerJob.contains('car')) {
      return Icons.local_car_wash;
    }

    // --- 5. Delivery & Field Work ---
    if (lowerJob.contains('delivery') ||
        lowerJob.contains('courier') ||
        lowerJob.contains('runner') ||
        lowerJob.contains('boy')) {
      return Icons.delivery_dining;
    }
    if (lowerJob.contains('sales') ||
        lowerJob.contains('marketing') ||
        lowerJob.contains('promoter')) {
      return Icons.campaign;
    }
    if (lowerJob.contains('agent') ||
        lowerJob.contains('representative') ||
        lowerJob.contains('executive')) {
      return Icons.badge;
    }
    if (lowerJob.contains('meter') || lowerJob.contains('reading')) {
      return Icons.speed;
    }
    if (lowerJob.contains('survey') ||
        lowerJob.contains('census') ||
        lowerJob.contains('data')) {
      return Icons.assignment;
    }
    if (lowerJob.contains('collection') || lowerJob.contains('recovery')) {
      return Icons.attach_money;
    }
    if (lowerJob.contains('post') || lowerJob.contains('mail')) {
      return Icons.markunread_mailbox;
    }
    if (lowerJob.contains('gas') && lowerJob.contains('cylinder')) {
      return Icons.gas_meter;
    }

    // --- 6. Agriculture ---
    if (lowerJob.contains('farm') ||
        lowerJob.contains('agriculture') ||
        lowerJob.contains('crop')) {
      return Icons.agriculture;
    }
    if (lowerJob.contains('garden') ||
        lowerJob.contains('plant') ||
        lowerJob.contains('nursery')) {
      return Icons.yard;
    }
    if (lowerJob.contains('flower') || lowerJob.contains('florist')) {
      return Icons.local_florist;
    }
    if (lowerJob.contains('fruit') ||
        lowerJob.contains('vegetable') ||
        lowerJob.contains('mango') ||
        lowerJob.contains('coconut')) {
      return Icons.local_grocery_store;
    }
    if (lowerJob.contains('milk') ||
        lowerJob.contains('dairy') ||
        lowerJob.contains('cow') ||
        lowerJob.contains('cattle')) {
      return Icons.water_drop;
    }
    if (lowerJob.contains('fish') ||
        lowerJob.contains('prawn') ||
        lowerJob.contains('aqua')) {
      return Icons.set_meal;
    }
    if (lowerJob.contains('tractor') || lowerJob.contains('tiller')) {
      return Icons.agriculture;
    }
    if (lowerJob.contains('poultry') ||
        lowerJob.contains('chicken') ||
        lowerJob.contains('egg')) {
      return Icons.egg;
    }
    if (lowerJob.contains('honey') || lowerJob.contains('bee')) {
      return Icons.hive;
    }
    if (lowerJob.contains('forest') || lowerJob.contains('wood')) {
      return Icons.forest;
    }

    // --- 7. Service & Shop ---
    if (lowerJob.contains('cook') ||
        lowerJob.contains('chef') ||
        lowerJob.contains('kitchen') ||
        lowerJob.contains('food')) {
      return Icons.restaurant_menu;
    }
    if (lowerJob.contains('waiter') ||
        lowerJob.contains('server') ||
        lowerJob.contains('steward')) {
      return Icons.room_service;
    }
    if (lowerJob.contains('clean') ||
        lowerJob.contains('sweep') ||
        lowerJob.contains('wash') ||
        lowerJob.contains('housekeeping')) {
      return Icons.cleaning_services;
    }
    if (lowerJob.contains('shop') ||
        lowerJob.contains('store') ||
        lowerJob.contains('stall') ||
        lowerJob.contains('mart')) {
      return Icons.store;
    }
    if (lowerJob.contains('barber') ||
        lowerJob.contains('hair') ||
        lowerJob.contains('saloon') ||
        lowerJob.contains('spa')) {
      return Icons.content_cut;
    }
    if (lowerJob.contains('laundry') ||
        lowerJob.contains('iron') ||
        lowerJob.contains('dry clean')) {
      return Icons.iron;
    }
    if (lowerJob.contains('security') ||
        lowerJob.contains('guard') ||
        lowerJob.contains('watchman') ||
        lowerJob.contains('patrol')) {
      return Icons.security;
    }
    if (lowerJob.contains('hotel') ||
        lowerJob.contains('lodge') ||
        lowerJob.contains('resort')) {
      return Icons.hotel;
    }
    if (lowerJob.contains('hospital') ||
        lowerJob.contains('clinic') ||
        lowerJob.contains('nurse') ||
        lowerJob.contains('ward') ||
        lowerJob.contains('medical')) {
      return Icons.local_hospital;
    }
    if (lowerJob.contains('school') ||
        lowerJob.contains('college') ||
        lowerJob.contains('teacher') ||
        lowerJob.contains('tutor')) {
      return Icons.school;
    }
    if (lowerJob.contains('temple') ||
        lowerJob.contains('priest') ||
        lowerJob.contains('church') ||
        lowerJob.contains('mosque')) {
      return Icons.temple_hindu;
    }
    if (lowerJob.contains('gym') ||
        lowerJob.contains('yoga') ||
        lowerJob.contains('fitness')) {
      return Icons.fitness_center;
    }
    if (lowerJob.contains('movie') ||
        lowerJob.contains('cinema') ||
        lowerJob.contains('theatre')) {
      return Icons.movie;
    }
    if (lowerJob.contains('pet') || lowerJob.contains('dog')) return Icons.pets;

    // --- 8. Security & Public Work ---
    if (lowerJob.contains('police') || lowerJob.contains('traffic')) {
      return Icons.local_police;
    }
    if (lowerJob.contains('garbage') ||
        lowerJob.contains('waste') ||
        lowerJob.contains('dustbin')) {
      return Icons.delete;
    }
    if (lowerJob.contains('drain') ||
        lowerJob.contains('sewage') ||
        lowerJob.contains('gutter')) {
      return Icons.water_damage;
    }
    if (lowerJob.contains('street light') || lowerJob.contains('lamp')) {
      return Icons.lightbulb;
    }
    if (lowerJob.contains('park') && !lowerJob.contains('parking')) {
      return Icons.park;
    }
    if (lowerJob.contains('library')) return Icons.local_library;
    if (lowerJob.contains('museum')) return Icons.museum;

    // --- 9. Industry & Mining ---
    if (lowerJob.contains('mine') ||
        lowerJob.contains('mining') ||
        lowerJob.contains('quarry') ||
        lowerJob.contains('coal')) {
      return Icons.terrain;
    }
    if (lowerJob.contains('boiler') ||
        lowerJob.contains('furnace') ||
        lowerJob.contains('kiln')) {
      return Icons.fireplace;
    }
    if (lowerJob.contains('oil') ||
        lowerJob.contains('petrol') ||
        lowerJob.contains('refinery')) {
      return Icons.oil_barrel;
    }
    if (lowerJob.contains('power') ||
        lowerJob.contains('energy') ||
        lowerJob.contains('turbine')) {
      return Icons.bolt;
    }

    // --- 10. Misc ---
    if (lowerJob.contains('helper') ||
        lowerJob.contains('labour') ||
        lowerJob.contains('worker')) {
      return Icons.engineering;
    }
    if (lowerJob.contains('manager') || lowerJob.contains('supervisor')) {
      return Icons.manage_accounts;
    }
    if (lowerJob.contains('engineer')) return Icons.engineering;
    if (lowerJob.contains('maid') || lowerJob.contains('servant')) {
      return Icons.cleaning_services;
    }
    if (lowerJob.contains('baby') || lowerJob.contains('child')) {
      return Icons.child_care;
    }
    if (lowerJob.contains('elder') || lowerJob.contains('patient')) {
      return Icons.elderly;
    }
    if (lowerJob.contains('atm') || lowerJob.contains('cash')) return Icons.atm;

    // Default
    return Icons.work;
  }

  Widget _buildServiceItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        if (_isWorkerMode) {
          // Worker mode: Show list of jobs posted by work givers
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkerJobListScreen(category: label),
            ),
          );
        } else {
          // Work Giver mode: Go to form to post a job
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailsScreen(
                jobTitle: label,
                isWorkerMode: _isWorkerMode,
              ),
            ),
          );
        }
      },
      child: Container(
        width: 105,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: _primaryColor.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, size: 28, color: _primaryColor),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data Lists

// 1. Construction & Civil Jobs
const List<String> _constructionJobs = [
  "Mason",
  "Mason Helper",
  "Cement Worker",
  "Concrete Mixer Operator",
  "Concrete Pump Helper",
  "Labour (Construction)",
  "Shuttering Carpenter",
  "Scaffolding Worker",
  "Site Cleaning Labour",
  "Bar Bender",
  "Plaster Worker",
  "Tile Layer",
  "Tile Cutting Helper",
  "Marble Cutter",
  "Granite Cutter",
  "RMC Worker",
  "Road Construction Labour",
  "Highway Line Marker",
  "Bitumen Worker",
  "Roller Operator",
  "Excavator Helper",
  "JCB Helper",
  "Survey Helper",
  "Borewell Helper",
  "Plinth Level Worker",
  "Pillar Steel Worker",
  "Concrete Vibrator Operator",
  "Waterproofing Worker",
  "Roofing Worker",
  "False Ceiling Installer",
  "POP Worker",
  "Putty Worker",
  "Wall Painter",
  "Texture Painter",
  "Spray Painter",
  "Polish Worker (Wood)",
  "Polish Worker (Floor)",
  "Glass Cutter",
  "Glazier (Glass Fitter)",
  "Window Installer",
  "Door Installer",
  "Grill Welder",
  "Gate Fabricator",
  "Shutter Installer",
  "Fencing Worker",
  "Stone Mason",
  "Brick Layer",
  "Block Layer",
  "Paver Block Layer",
  "Kerb Stone Layer",
  "Drainage Pipe Layer",
  "Sewer Line Worker",
  "Manhole Cleaner",
  "Septic Tank Cleaner",
  "Water Tank Cleaner",
  "Plumber",
  "Plumber Helper",
  "Sanitary Fitter",
  "Pipe Fitter",
  "Gas Pipeline Fitter",
  "Welder (Arc)",
  "Welder (Gas)",
  "Welder (TIG/MIG)",
  "Fabricator",
  "Blacksmith",
  "Iron Worker",
  "Sheet Metal Worker",
  "Ducting Worker",
  "Insulation Worker",
  "Soundproofing Worker",
  "Demolition Worker",
  "Drilling Worker",
  "Core Cutting Worker",
  "Rebar Cutter",
  "Centering Worker",
  "Formwork Carpenter",
  "Furniture Carpenter",
  "Wood Carver",
  "Laminate Paster",
  "Modular Kitchen Fitter",
  "Aluminium Fabricator",
  "UPVC Window Fitter",
  "Interior Decorator Helper",
  "Sign Board Fitter",
  "Hoarding Installer",
  "Flex Banner Paster",
  "Neon Sign Fixer",
  "Crane Signalman",
  "Rigger",
  "Chain Pulley Operator",
  "Lift Installer",
  "Escalator Installer",
  "Fire Fighting System Fitter",
  "Solar Panel Installer",
  "Rainwater Harvesting Worker",
  "Garden Landscaper",
  "Fountain Installer",
  "Swimming Pool Cleaner",
  "Tennis Court Marker",
];

// 2. Skilled Technicians Jobs
const List<String> _skilledJobs = [
  "Electrician",
  "Electrician Helper",
  "House Wiring Technician",
  "Panel Board Fitter",
  "Inverter Repairer",
  "Battery Service Technician",
  "Generator Mechanic",
  "Motor Winder",
  "Pump Mechanic",
  "Submersible Pump Repairer",
  "AC Mechanic",
  "AC Installation Technician",
  "Fridge Repairer",
  "Washing Machine Mechanic",
  "Microwave Repairer",
  "Geyser Repairer",
  "Water Purifier (RO) Technician",
  "Chimney Service Technician",
  "TV Repairer (LED/LCD)",
  "Dish TV Installer",
  "Cable Operator",
  "CCTV Camera Installer",
  "Biometric System Installer",
  "Intercom Technician",
  "Computer Hardware Technician",
  "Laptop Repairer",
  "Printer Repairer",
  "Cartridge Refiller",
  "Mobile Phone Repairer",
  "Tablet Repairer",
  "Watch Repairer",
  "Clock Repairer",
  "Calculator Repairer",
  "Weighing Scale Repairer",
  "Sewing Machine Repairer",
  "Embroidery Machine Mechanic",
  "Overlock Machine Mechanic",
  "Bicycle Mechanic",
  "Tyre Puncture Repairer",
  "Wheel Alignment Technician",
  "Car Mechanic",
  "Car Electrician",
  "Car AC Mechanic",
  "Car Denter",
  "Car Painter",
  "Bike Mechanic",
  "Scooter Mechanic",
  "Auto Rickshaw Mechanic",
  "Truck Mechanic",
  "Bus Mechanic",
  "Tractor Mechanic",
  "JCB Mechanic",
  "Hydraulic Mechanic",
  "Diesel Engine Mechanic",
  "Radiator Repairer",
  "Silencer Repairer",
  "Seat Cover Maker",
  "Rexine Worker",
  "Sofa Repairer",
  "Curtain Fitter",
  "Blind Installer",
  "Mattress Maker",
  "Quilt Maker (Razai)",
  "Pillow Maker",
  "Bag Repairer",
  "Suitcase Repairer",
  "Shoe Maker (Cobbler)",
  "Shoe Polisher",
  "Chappal Maker",
  "Key Maker",
  "Lock Repairer",
  "Knife Sharpener",
  "Scissor Sharpener",
  "Tool Grinder",
  "Glass Blower",
  "Potter (Clay)",
  "Idol Maker",
  "Kite Maker",
  "Manjha Maker",
  "Book Binder",
  "Xerox Machine Operator",
  "Lamination Operator",
  "Spiral Binding Operator",
  "Rubber Stamp Maker",
  "Number Plate Maker",
  "Sticker Cutter",
  "Raduim Worker",
  "Screen Printer",
  "Offset Printer",
  "DTP Operator",
  "Flex Printer Operator",
  "Photo Framer",
  "Album Maker",
  "Sound System Operator",
  "DJ Operator",
  "Light Decoration Worker",
  "Stage Decorator",
  "Balloon Decorator",
  "Flower Decorator",
];

// 3. Factory & Warehouse Jobs
const List<String> _factoryJobs = [
  "Factory Helper",
  "Machine Operator",
  "CNC Operator",
  "VMC Operator",
  "Lathe Machine Operator",
  "Milling Machine Operator",
  "Grinding Machine Operator",
  "Drill Machine Operator",
  "Press Machine Operator",
  "Moulding Machine Operator",
  "Injection Moulding Operator",
  "Extruder Operator",
  "Casting Worker",
  "Forging Worker",
  "Furnace Operator",
  "Boiler Attendant",
  "Plant Operator",
  "Production Helper",
  "Assembly Line Worker",
  "Packaging Helper",
  "Packing Machine Operator",
  "Labeling Machine Operator",
  "Filling Machine Operator",
  "Sealing Machine Operator",
  "Bottling Plant Worker",
  "Quality Checker",
  "Quality Assurance Helper",
  "Supervisor (Production)",
  "Foreman",
  "Shift In-charge",
  "Store Keeper",
  "Store Helper",
  "Warehouse Manager",
  "Warehouse Picker",
  "Warehouse Packer",
  "Loader / Unloader",
  "Stacker",
  "Forklift Operator",
  "Pallet Truck Operator",
  "Crane Operator (Overhead)",
  "Inventory Clerk",
  "Dispatch Clerk",
  "Gatekeeper (Factory)",
  "Timekeeper",
  "Weighbridge Operator",
  "Scrap Sorter",
  "Recycling Worker",
  "Textile Mill Worker",
  "Spinning Mill Worker",
  "Weaving Loom Operator",
  "Dyeing Master",
  "Dyeing Helper",
  "Bleaching Worker",
  "Printing Master (Textile)",
  "Garment Cutter",
  "Garment Stitcher",
  "Button Hole Machine Operator",
  "Kaj Button Worker",
  "Thread Cutter",
  "Finishing Helper",
  "Ironing Worker (Factory)",
  "Folding Worker",
  "Bale Packer",
  "Yarn Winder",
  "Jute Mill Worker",
  "Paper Mill Worker",
  "Pulp Mill Worker",
  "Corrugated Box Maker",
  "Carton Pasting Worker",
  "Paper Cup Maker",
  "Paper Plate Maker",
  "Tissue Paper Maker",
  "Plastic Bag Maker",
  "Plastic Granules Worker",
  "Rubber Mill Worker",
  "Tyre Factory Worker",
  "Footwear Factory Worker",
  "Sole Pasting Worker",
  "Leather Tanner",
  "Leather Cutter",
  "Bag Stitcher",
  "Belt Maker",
  "Wallet Maker",
  "Chemical Plant Operator",
  "Acid Handling Worker",
  "Paint Mixing Worker",
  "Soap Maker",
  "Detergent Maker",
  "Agarbatti Maker",
  "Candle Maker",
  "Matchstick Maker",
  "Firecracker Maker",
  "Biscuit Factory Worker",
  "Bread Factory Worker",
  "Namkeen Maker",
  "Sweet Maker (Bulk)",
  "Dairy Plant Worker",
  "Ice Cream Factory Worker",
  "Ice Factory Worker",
  "Cold Storage Worker",
];

// 4. Driving & Vehicle Jobs
const List<String> _drivingJobs = [
  "Car Driver (Private)",
  "Taxi Driver",
  "Cab Driver (App based)",
  "Auto Rickshaw Driver",
  "E-Rickshaw Driver",
  "Tempo Driver",
  "Chota Hathi Driver",
  "Pickup Truck Driver",
  "Van Driver",
  "School Bus Driver",
  "Staff Bus Driver",
  "Luxury Bus Driver",
  "Truck Driver (Heavy)",
  "Lorry Driver",
  "Tanker Driver (Water)",
  "Tanker Driver (Oil/Gas)",
  "Container Truck Driver",
  "Trailer Driver",
  "Dumper Truck Driver",
  "Tipper Driver",
  "Transit Mixer Driver",
  "Fire Truck Driver",
  "Ambulance Driver",
  "Hearse Van Driver",
  "Police Jeep Driver",
  "Government Vehicle Driver",
  "Valet Parking Driver",
  "Test Driver",
  "Driving Instructor",
  "Tractor Driver",
  "Harvester Driver",
  "Road Roller Driver",
  "Bulldozer Driver",
  "Crane Driver (Mobile)",
  "Forklift Driver",
  "JCB Operator/Driver",
  "Bobcat Operator",
  "Locomotive Driver (Train)",
  "Metro Train Operator",
  "Tram Operator",
  "Pilot (Private Jet)",
  "Pilot (Commercial)",
  "Helicopter Pilot",
  "Drone Pilot",
  "Boatman",
  "Ferry Operator",
  "Ship Captain",
  "Deckhand",
  "Stevedore",
  "Bike Rider (Taxi)",
  "Delivery Van Driver",
  "Cash Van Driver",
  "Garbage Truck Driver",
  "Sewage Tanker Driver",
  "Water Sprinkler Driver",
  "Sweeping Machine Driver",
  "Recovery Van Driver",
  "Tow Truck Operator",
  "Car Washer",
  "Bike Washer",
  "Bus Washer",
  "Truck Washer",
  "Vehicle Polisher",
  "Detailing Technician",
  "Tyre Fitter",
  "Wheel Balancer",
  "Nitrogen Filling Boy",
  "Petrol Pump Attendant",
  "CNG Filler",
  "EV Charging Station Attendant",
  "Toll Plaza Collector",
  "Parking Attendant",
  "Traffic Marshal",
  "Bus Conductor",
  "Ticket Checker (Bus)",
  "Ticket Collector (Train)",
  "Station Master",
  "Signalman (Rail)",
  "Pointsman",
  "Gangman (Rail)",
  "Trackman",
  "Airport Ground Staff",
  "Baggage Handler",
  "Trolley Retriever",
  "Aircraft Cleaner",
  "Refueling Operator (Airport)",
  "Pushback Tractor Operator",
  "Aerobridge Operator",
  "Check-in Agent",
  "Boarding Gate Agent",
  "Flight Attendant",
  "Cabin Crew",
  "Cruise Ship Staff",
  "Life Guard (Boat)",
  "Marine Engineer",
  "Oiler (Ship)",
];

// 5. Delivery & Outdoor Field Work Jobs
const List<String> _deliveryJobs = [
  "Food Delivery Boy",
  "Grocery Delivery Boy",
  "Medicine Delivery Boy",
  "Courier Delivery Boy",
  "Parcel Delivery Boy",
  "E-commerce Delivery Associate",
  "Document Runner",
  "Office Boy",
  "Peon",
  "Messenger",
  "Postman",
  "Mail Carrier",
  "Newspaper Hawker",
  "Milk Delivery Man",
  "Water Jar Delivery Boy",
  "LPG Cylinder Delivery Man",
  "Laundry Pickup Boy",
  "Tiffin Delivery Boy (Dabbawala)",
  "Flower Delivery Boy",
  "Gift Delivery Boy",
  "Cake Delivery Boy",
  "Field Sales Executive",
  "Door-to-Door Salesman",
  "Marketing Executive",
  "Medical Representative (MR)",
  "Insurance Agent",
  "Real Estate Agent",
  "Property Dealer",
  "Loan Recovery Agent",
  "Credit Card Sales Agent",
  "Sim Card Seller",
  "Broadband Sales Agent",
  "Cable TV Collection Agent",
  "Bill Collector",
  "Donation Collector",
  "Surveyor (Field)",
  "Census Enumerator",
  "Data Collector",
  "Meter Reader (Electricity)",
  "Meter Reader (Water)",
  "Meter Reader (Gas)",
  "Pamphlet Distributor",
  "Poster Paster",
  "Banner Hanger",
  "Sample Distributor",
  "Mystery Shopper",
  "Field Technician (Telecom)",
  "Tower Climber",
  "Line Man (Electricity)",
  "Line Man (Telephone)",
  "Cable Jointer",
  "Pipeline Inspector",
  "Drainage Inspector",
  "Health Inspector",
  "Food Inspector",
  "Safety Inspector",
  "Building Inspector",
  "Crop Surveyor",
  "Soil Tester",
  "Water Tester",
  "Geologist Helper",
  "Archaeologist Helper",
  "Forest Guard",
  "Park Ranger",
  "Wildlife Tracker",
  "Zoo Keeper",
  "Animal Catcher",
  "Dog Catcher",
  "Pest Control Technician",
  "Fumigation Worker",
  "Sanitization Worker",
  "Mosquito Fogging Worker",
  "Street Sweeper",
  "Rag Picker",
  "Scrap Collector",
  "Garbage Collector",
  "Compost Worker",
  "Gardener (Mali)",
  "Horticulturist",
  "Tree Trimmer",
  "Grass Cutter",
  "Golf Caddy",
  "Stadium Groundsman",
  "Pitch Curator",
  "Swimming Pool Maintenance",
  "Lifeguard (Pool)",
  "Beach Lifeguard",
  "Tour Guide",
  "Travel Guide",
  "Trekking Guide",
  "Safari Driver",
  "Camp Instructor",
  "Adventure Sports Instructor",
  "Paragliding Pilot",
  "Scuba Diving Instructor",
  "River Rafting Guide",
  "Ski Instructor",
  "Event Coordinator (Field)",
  "Wedding Planner Helper",
  "Catering Supervisor",
  "Tent House Worker",
];

// 6. Agriculture & Rural Farm Jobs
const List<String> _agricultureJobs = [
  "Farmer",
  "Farm Labourer",
  "Ploughman",
  "Sower",
  "Weeder",
  "Harvester",
  "Thresher Operator",
  "Grain Cleaner",
  "Grain Sorter",
  "Bagging Worker",
  "Mandi Labourer",
  "Cotton Picker",
  "Sugarcane Cutter",
  "Tea Plucker",
  "Coffee Berry Picker",
  "Rubber Tapper",
  "Coconut Plucker",
  "Arecanut Plucker",
  "Toddy Tapper",
  "Fruit Picker",
  "Vegetable Picker",
  "Flower Plucker",
  "Nursery Worker",
  "Grafting Worker",
  "Seed Processing Worker",
  "Fertilizer Sprayer",
  "Pesticide Sprayer",
  "Irrigation Worker",
  "Tube Well Operator",
  "Canal Guard",
  "Dam Guard",
  "Sluice Gate Operator",
  "Hydroponics Worker",
  "Greenhouse Worker",
  "Mushroom Farmer",
  "Beekeeper",
  "Honey Extractor",
  "Sericulture Worker",
  "Silk Worm Rearer",
  "Lac Cultivator",
  "Dairy Farmer",
  "Milker (Gwala)",
  "Cattle Grazer (Shepherd)",
  "Goat Herder",
  "Sheep Shearer",
  "Camel Herder",
  "Horse Groomer",
  "Stable Hand",
  "Poultry Farmer",
  "Chicken Feeder",
  "Egg Collector",
  "Hatchery Worker",
  "Piggery Worker",
  "Fisherman",
  "Fish Farmer",
  "Prawn Farmer",
  "Crab Catcher",
  "Pearl Farmer",
  "Net Weaver",
  "Boat Builder (Traditional)",
  "Salt Pan Worker",
  "Charcoal Maker",
  "Brick Kiln Worker",
  "Pottery Worker",
  "Basket Weaver",
  "Mat Weaver",
  "Broom Maker",
  "Rope Maker",
  "Coir Worker",
  "Bidi Roller",
  "Tendu Leaf Collector",
  "Mahua Collector",
  "Gum Collector",
  "Resin Tapper",
  "Bamboo Cutter",
  "Wood Cutter",
  "Sawmill Worker",
  "Timber Merchant Helper",
  "Veterinary Helper",
  "Artificial Inseminator",
  "Animal Vaccinator",
  "Krishi Mitra",
  "Gram Sevak",
  "Panchayat Sahayak",
  "Anganwadi Worker",
  "Anganwadi Helper",
  "ASHA Worker",
  "Midwife (Dai)",
  "Village Guard (Chowkidar)",
  "Well Digger",
  "Pond Digger",
  "Fence Maker",
  "Scarecrow Maker",
  "Tractor Mechanic (Village)",
  "Pump Set Mechanic",
  "Chaff Cutter Operator",
  "Flour Mill Operator (Atta Chakki)",
  "Oil Mill Operator (Ghani)",
  "Spice Grinder",
  "Jaggery Maker",
];

// 7. Market, Shop, Hotel, and Public Services
const List<String> _serviceJobs = [
  "Shopkeeper",
  "Shop Assistant",
  "Salesman (Counter)",
  "Cashier",
  "Billing Clerk",
  "Inventory Manager",
  "Showroom Manager",
  "Floor Manager",
  "Visual Merchandiser",
  "Mannequin Dresser",
  "Vegetable Vendor",
  "Fruit Vendor",
  "Flower Vendor",
  "Fish Monger",
  "Butcher",
  "Chicken Shop Worker",
  "Tea Stall Owner",
  "Tea Maker",
  "Juice Stall Owner",
  "Pan Shop Owner",
  "Street Food Vendor",
  "Chat Wala",
  "Ice Cream Vendor",
  "Popcorn Seller",
  "Balloon Seller",
  "Toy Seller",
  "Newspaper Seller",
  "Book Seller",
  "Stationery Shop Keeper",
  "Medical Store Helper",
  "Pharmacist",
  "Optician",
  "Lens Grinder",
  "Jewellery Appraiser",
  "Goldsmith",
  "Silversmith",
  "Gem Cutter",
  "Pawn Broker",
  "Money Lender",
  "Currency Exchanger",
  "Ticket Booking Agent",
  "Travel Agent",
  "Hotel Manager",
  "Receptionist",
  "Concierge",
  "Bell Boy",
  "Room Boy",
  "Housekeeping Staff",
  "Chambermaid",
  "Laundryman (Dhobi)",
  "Ironing Man (Istriwala)",
  "Dry Cleaner",
  "Chef",
  "Sous Chef",
  "Commi Chef",
  "Cook",
  "Assistant Cook",
  "Roti Maker",
  "Tandoor Cook",
  "Halwai",
  "Fast Food Cook",
  "Pizza Maker",
  "Burger Maker",
  "Barista",
  "Bartender",
  "Sommelier",
  "Waiter",
  "Waitress",
  "Steward",
  "Captain (Restaurant)",
  "Busboy",
  "Dishwasher",
  "Kitchen Helper",
  "Cleaner (Restaurant)",
  "Bouncer",
  "Club Manager",
  "Casino Dealer",
  "Croupier",
  "Spa Manager",
  "Masseur",
  "Masseuse",
  "Therapist",
  "Beautician",
  "Hairdresser",
  "Barber",
  "Makeup Artist",
  "Nail Artist",
  "Mehendi Artist",
  "Tattoo Artist",
  "Piercing Artist",
  "Gym Trainer",
  "Yoga Instructor",
  "Zumba Instructor",
  "Aerobics Instructor",
  "Personal Trainer",
  "Dietician",
  "Nutritionist",
  "Physiotherapist",
  "Chiropractor",
  "Acupuncturist",
  "Teacher",
  "Tutor",
  "Professor",
  "Lecturer",
  "Principal",
  "Librarian",
  "Lab Assistant",
  "Peon (School)",
  "School Bus Attendant",
  "Priest (Pandit)",
  "Imam",
  "Pastor",
  "Granthi",
  "Astrologer",
  "Palmist",
  "Vastu Consultant",
  "Funeral Director",
  "Undertaker",
  "Grave Digger",
  "Crematorium Worker",
];

// 8. Security, Cleaning, Public Work
const List<String> _securityJobs = [
  "Security Guard",
  "Security Supervisor",
  "Gunman",
  "Bouncer",
  "Bodyguard",
  "Watchman",
  "Caretaker",
  "Gatekeeper",
  "Liftman",
  "Concierge (Residential)",
  "Society Manager",
  "Parking Guard",
  "ATM Guard",
  "Bank Guard",
  "Museum Guard",
  "Traffic Police",
  "Police Constable",
  "Home Guard",
  "Prison Guard",
  "Detective",
  "Private Investigator",
  "Spy",
  "Intelligence Officer",
  "Cyber Security Analyst",
  "Ethical Hacker",
  "Forensic Expert",
  "Firefighter",
  "Fire Safety Officer",
  "Disaster Management Worker",
  "Rescue Worker",
  "Paramedic",
  "Emergency Medical Technician",
  "Ambulance Attendant",
  "Nurse",
  "Ward Boy",
  "Aya (Hospital)",
  "Operation Theatre Technician",
  "X-Ray Technician",
  "Pathology Lab Technician",
  "Phlebotomist",
  "Sample Collector",
  "Hospital Cleaner",
  "Mortuary Attendant",
  "Sweeper",
  "Cleaner",
  "Janitor",
  "Housekeeper",
  "Maid",
  "Nanny",
  "Babysitter",
  "Cook (Domestic)",
  "Gardener (Domestic)",
  "Driver (Domestic)",
  "Butler",
  "Valet",
  "Personal Assistant",
  "Secretary",
  "Clerk",
  "Typist",
  "Stenographer",
  "Data Entry Operator",
  "Receptionist (Office)",
  "Telephone Operator",
  "Call Center Executive",
  "Customer Care Executive",
  "Telecaller",
  "Help Desk Executive",
  "Front Office Executive",
  "Admin Executive",
  "HR Executive",
  "Accountant",
  "Auditor",
  "Tax Consultant",
  "Lawyer",
  "Advocate",
  "Notary",
  "Judge",
  "Magistrate",
  "Court Clerk",
  "Stamp Vendor",
  "Deed Writer",
  "Journalist",
  "Reporter",
  "News Anchor",
  "Cameraman",
  "Editor",
  "Photographer",
  "Videographer",
  "Writer",
  "Author",
  "Poet",
  "Translator",
  "Interpreter",
  "Social Worker",
  "NGO Worker",
  "Activist",
  "Politician",
  "Political Party Worker",
  "Union Leader",
];

// 9. Heavy Industry, Mining, and Machinery
const List<String> _industryJobs = [
  "Miner",
  "Coal Miner",
  "Gold Miner",
  "Diamond Miner",
  "Iron Ore Miner",
  "Stone Quarry Worker",
  "Sand Miner",
  "Salt Miner",
  "Oil Rig Worker",
  "Driller (Oil)",
  "Roughneck",
  "Roustabout",
  "Derrickman",
  "Mud Logger",
  "Geophysicist",
  "Petroleum Engineer",
  "Refinery Operator",
  "Pipeline Welder",
  "Pipeline Fitter",
  "Gas Plant Operator",
  "Power Plant Operator",
  "Nuclear Plant Operator",
  "Hydro Plant Operator",
  "Thermal Plant Operator",
  "Wind Turbine Technician",
  "Solar Farm Technician",
  "Grid Operator",
  "Substation Operator",
  "Lineman (High Voltage)",
  "Transformer Repairer",
  "Switchgear Technician",
  "Turbine Mechanic",
  "Boiler Operator (High Pressure)",
  "Cooling Tower Technician",
  "Water Treatment Plant Operator",
  "Sewage Treatment Plant Operator",
  "Desalination Plant Operator",
  "Incinerator Operator",
  "Biogas Plant Operator",
  "Ethanol Plant Operator",
  "Sugar Mill Worker",
  "Cement Factory Worker",
  "Steel Plant Worker",
  "Blast Furnace Operator",
  "Rolling Mill Operator",
  "Foundry Worker",
  "Pattern Maker",
  "Moulder",
  "Caster",
  "Heat Treatment Worker",
  "Electroplater",
  "Galvanizer",
  "Anodizer",
  "Powder Coater",
  "Sandblaster",
  "Shot Blaster",
  "Industrial Painter",
  "Industrial Cleaner",
  "Tank Cleaner",
  "Chimney Sweep (Industrial)",
  "Hazardous Waste Handler",
  "Radiation Safety Officer",
  "Industrial Safety Officer",
  "Environment Officer",
  "Maintenance Engineer",
  "Plant Engineer",
  "Instrumentation Engineer",
  "Automation Engineer",
  "Robotics Engineer",
  "Mechatronics Engineer",
  "Design Engineer",
  "Draftsman",
  "CAD Operator",
  "CAM Operator",
  "Tool and Die Maker",
  "Jig and Fixture Maker",
  "Machinist",
  "Turner",
  "Fitter",
  "Millwright",
  "Rigger (Heavy)",
  "Crane Operator (Tower)",
  "Crane Operator (Gantry)",
  "Crane Operator (Crawler)",
  "Earthmover Mechanic",
  "Heavy Vehicle Mechanic",
  "Locomotive Mechanic",
  "Ship Mechanic",
  "Aircraft Mechanic",
  "Avionics Technician",
  "Aerospace Engineer",
  "Marine Biologist",
  "Oceanographer",
  "Diver (Commercial)",
  "Underwater Welder",
];

// 10. Miscellaneous Hard-Work Daily-Wage Jobs
const List<String> _dailyWageJobs = [
  "Daily Wage Labourer",
  "Construction Labourer",
  "Agricultural Labourer",
  "Loading Unloading Labour",
  "Market Porter (Coolie)",
  "Railway Porter",
  "Head Load Worker",
  "Handcart Puller",
  "Rickshaw Puller",
  "Cycle Rickshaw Puller",
  "Bullock Cart Driver",
  "Camel Cart Driver",
  "Donkey Handler",
  "Mule Handler",
  "Elephant Mahout",
  "Snake Charmer",
  "Monkey Trainer",
  "Bear Trainer",
  "Street Performer",
  "Magician",
  "Juggler",
  "Acrobat",
  "Circus Artist",
  "Clown",
  "Puppeteer",
  "Storyteller",
  "Singer (Street)",
  "Musician (Street)",
  "Artist (Street)",
  "Caricature Artist",
  "Face Painter",
  "Statue Performer",
  "Beggar",
  "Rag Picker",
  "Scrap Dealer",
  "Kabadiwala",
  "Old Newspaper Buyer",
  "Bottle Buyer",
  "E-waste Collector",
  "Human Hair Collector",
  "Bone Collector",
  "Dung Collector",
  "Leaf Collector",
  "Firewood Collector",
  "Water Carrier",
  "Dhobi (Ghat)",
  "Grave Digger",
  "Cremation Worker",
  "Dom (Funeral Worker)",
  "Sewer Cleaner (Manual)",
  "Septic Tank Emptier",
  "Drain Cleaner",
  "Gutter Cleaner",
  "Road Sweeper",
  "Toilet Cleaner",
  "Shoe Shiner",
  "Ear Cleaner",
  "Masseur (Street)",
  "Barber (Street)",
  "Cobbler (Street)",
  "Key Maker (Street)",
  "Knife Sharpener (Street)",
  "Fortune Teller",
  "Parrot Astrologer",
  "Healer (Traditional)",
  "Bone Setter",
  "Hakim",
  "Vaidya",
  "Witch Doctor",
  "Exorcist",
  "Ghost Hunter",
  "Treasure Hunter",
  "Gold Panner",
  "Metal Detectorist",
  "Lottery Seller",
  "Gambler",
  "Bookie",
  "Pimp",
  "Prostitute",
  "Gigolo",
  "Escort",
  "Bar Dancer",
  "Stripper",
  "Model (Nude)",
  "Body Double",
  "Stuntman",
  "Extra (Film)",
  "Spot Boy",
  "Light Man",
  "Set Carpenter",
  "Set Painter",
  "Costume Assistant",
  "Makeup Assistant",
  "Production Assistant",
  "Runner (Film)",
  "Clapper Boy",
];

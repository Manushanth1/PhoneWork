import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:next_one/providers/posted_job_provider.dart';
import 'package:next_one/data/models/posted_job_model.dart';
import 'package:next_one/screens/worker/worker_job_details_screen.dart';
import 'package:next_one/services/ai_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final PhoneWorkAIService _aiService = PhoneWorkAIService();

  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          "Hello! I am **PhoneWork AI**, your intelligent support assistant.\n\nI can help you with:\n• Finding Jobs & Posting Jobs\n• Understanding Earnings & Commissions\n• KYC & Verification\n• Payment & Safety Issues\n\nTo start, please tell me: Are you a **Worker** or a **Work-Giver**?",
      isUser: false,
    ),
  ];

  // Conversation Context
  String? _userRole; // 'worker' or 'seeker'
  String? _interestedCategory;
  bool _isLoading = false;

  void _sendMessage() {
    if (_controller.text.trim().isEmpty || _isLoading) return;

    final userText = _controller.text.trim();
    setState(() {
      _messages.add(ChatMessage(text: userText, isUser: true));
      _controller.clear();
      _isLoading = true;
    });

    _scrollToBottom();
    _processAIResponse(userText);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 🧠 AI-POWERED RESPONSE SYSTEM
  /// 1. Client-side safety filters (immediate)
  /// 2. Role detection for context
  /// 3. Job search handling (local)
  /// 4. AI response for everything else
  Future<void> _processAIResponse(String input) async {
    final lowerInput = input.toLowerCase();

    // --- STEP 1: ROLE DETECTION (for context) ---
    if (_userRole == null) {
      if (lowerInput.contains('worker') ||
          lowerInput.contains('job seeker') ||
          lowerInput.contains('looking for job') ||
          lowerInput.contains('find work')) {
        _userRole = 'worker';
      } else if (lowerInput.contains('giver') ||
          lowerInput.contains('hir') ||
          lowerInput.contains('poster') ||
          lowerInput.contains('employer') ||
          lowerInput.contains('post job')) {
        _userRole = 'seeker';
      } else if (lowerInput.contains('plumber') ||
          lowerInput.contains('driver') ||
          lowerInput.contains('mason') ||
          lowerInput.contains('cleaner') ||
          lowerInput.contains('electrician')) {
        _userRole = 'worker';
        _interestedCategory = _extractCategory(lowerInput);
      }
    }

    // --- STEP 2: CLIENT-SIDE SAFETY FILTERS (Critical - Always Check) ---
    // These are handled client-side for immediate response on sensitive topics
    if (_containsSensitiveKeywords(lowerInput)) {
      _addSecurityWarning(lowerInput);
      return;
    }

    // --- STEP 3: JOB SEARCH (Local Data) ---
    if (_userRole == 'worker' &&
        (lowerInput.contains('show job') ||
            lowerInput.contains('find job') ||
            lowerInput.contains('list job') ||
            lowerInput.contains('available job'))) {
      await _searchAndListJobs(lowerInput);
      return;
    }

    // --- STEP 4: AI-POWERED RESPONSE ---
    try {
      final response = await _aiService.sendMessage(input, userRole: _userRole);
      _addMessage(response, false);
    } catch (e) {
      // Fallback to rule-based if AI fails
      _handleFallbackResponse(lowerInput);
    }
  }

  bool _containsSensitiveKeywords(String input) {
    final sensitivePatterns = [
      RegExp(r'share.*otp', caseSensitive: false),
      RegExp(r'give.*otp', caseSensitive: false),
      RegExp(r'tell.*otp', caseSensitive: false),
      RegExp(r'bank.*detail', caseSensitive: false),
      RegExp(r'password', caseSensitive: false),
      RegExp(r'upi.*pin', caseSensitive: false),
      RegExp(r'card.*number', caseSensitive: false),
    ];

    return sensitivePatterns.any((pattern) => pattern.hasMatch(input));
  }

  void _addSecurityWarning(String input) {
    String warning;
    if (input.contains('otp')) {
      warning =
          "⚠️ **SECURITY WARNING**\n\n**NEVER share your OTP with anyone.**\n\n**Process Guidance:**\n• **Work-Giver**: Only share the completion OTP with the worker AFTER the work is fully done to your satisfaction.\n• **Worker**: Ask the Work-Giver for the OTP only when you have physically finished the job.";
    } else {
      warning =
          "⚠️ **SECURITY WARNING**\n\nFor your safety, **do not enter bank details, passwords, or UPI pins here**.\n\nPlease enter payment details only in the secure 'Account' section of the app.";
    }
    _addMessage(warning, false);
  }

  void _handleFallbackResponse(String input) {
    String response;

    if (input.contains('earn') ||
        input.contains('commission') ||
        input.contains('fee')) {
      if (_userRole == 'worker') {
        response =
            "**Earnings Explanation**\n\nThe platform charges a standard **5% commission** on the job wage.\n\n**Example:**\n• Job Wage: ₹1000\n• Platform Fee (5%): ₹50\n• **You Receive: ₹950**";
      } else {
        response =
            "**Platform Fees**\n\nWe charge a small 5% fee from the worker's wage. As a Work-Giver, you pay the exact amount listed in the job post. No hidden charges!";
      }
    } else if (input.contains('kyc') || input.contains('verify')) {
      response =
          "**KYC Guidance**\n\nRequired Documents:\n• Government ID (Aadhaar/Driving License)\n• Clear Selfie\n\nVerification takes 2-4 hours. Your data is encrypted and secure.";
    } else {
      response =
          "I'm having trouble connecting right now. Please try again in a moment, or ask about:\n• **Earnings** & Commissions\n• **Jobs** & Applications\n• **KYC** Verification\n• **Safety** Guidelines";
    }

    _addMessage(response, false);
  }

  String? _extractCategory(String input) {
    if (input.contains('plumber')) return 'Plumber';
    if (input.contains('electrician')) return 'Electrician';
    if (input.contains('mason')) return 'Mason';
    if (input.contains('driver')) return 'Driver';
    if (input.contains('cleaner')) return 'Cleaner';
    if (input.contains('painter')) return 'Painter';
    if (input.contains('carpenter')) return 'Carpenter';
    return null;
  }

  Future<void> _searchAndListJobs(String input) async {
    final provider = Provider.of<PostedJobProvider>(context, listen: false);

    String category = _interestedCategory ?? _extractCategory(input) ?? '';

    // If no category detected yet, ask for it
    if (category.isEmpty) {
      _addMessage(
        "What type of job are you looking for? (e.g., Plumber, Driver, Painter, Electrician)",
        false,
      );
      return;
    }

    // Update context
    _interestedCategory = category;

    final jobs = provider.activeJobs
        .where((j) => j.category.toLowerCase().contains(category.toLowerCase()))
        .toList();

    if (jobs.isEmpty) {
      _addMessage(
        "**Job Search Result**\n\nI currently don't see any active jobs for **$category**.\n\n**Tips:**\n• Check back in a few hours\n• Ensure your KYC is approved\n• Try expanding your search to nearby areas",
        false,
      );
    } else {
      _addMessage(
        "**Job Search Result**\n\nI found **${jobs.length}** open **$category** job(s). Review the wage and location carefully before applying:",
        false,
      );

      for (var job in jobs.take(3)) {
        setState(() {
          _messages.add(ChatMessage(text: "", isUser: false, jobData: job));
        });
      }
      _scrollToBottom();
    }
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: isUser));
      _isLoading = false;
    });
    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[900]!, Colors.grey[800]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.deepPurple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PhoneWork AI',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Powered by Gemini • Always here to help',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Chat Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator
                if (_isLoading && index == _messages.length) {
                  return _buildTypingIndicator();
                }

                final msg = _messages[index];

                if (msg.jobData != null) {
                  return _buildJobCard(msg.jobData!);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: msg.isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!msg.isUser) ...[
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.deepPurple, Colors.purple],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: msg.isUser
                                ? Colors.blue[600]
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(16).copyWith(
                              topLeft: msg.isUser
                                  ? const Radius.circular(16)
                                  : Radius.zero,
                              topRight: !msg.isUser
                                  ? const Radius.circular(16)
                                  : Radius.zero,
                            ),
                          ),
                          child: _buildFormattedText(
                            msg.text,
                            msg.isUser ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Input Area
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      hintText: _isLoading
                          ? 'AI is thinking...'
                          : 'Ask me anything...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isLoading
                          ? [Colors.grey, Colors.grey]
                          : [Colors.deepPurple, Colors.purple],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.deepPurple, Colors.purple],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(
                16,
              ).copyWith(topLeft: Radius.zero),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[400],
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  /// Build text with basic markdown support (**bold**)
  Widget _buildFormattedText(String text, Color color) {
    final List<InlineSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.+?)\*\*');

    int lastEnd = 0;
    for (final match in boldPattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: TextStyle(color: color, fontSize: 15, height: 1.5),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            color: color,
            fontSize: 15,
            height: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastEnd),
          style: TextStyle(color: color, fontSize: 15, height: 1.5),
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildJobCard(PostedJob job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 40, right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkerJobDetailsScreen(job: job),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Text(
                        job.wage,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "5% platform fee applies • Tap to view details",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "VIEW DETAILS",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.deepPurple[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.deepPurple[700],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final PostedJob? jobData;

  ChatMessage({required this.text, required this.isUser, this.jobData});
}

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// PhoneWork AI Service powered by Google Gemini
class PhoneWorkAIService {
  static const String _apiKey = 'AIzaSyBuaKB4Ez1Wkjw2w9LePLQi3iYFJXNhHLw';

  GenerativeModel? _model;
  ChatSession? _chat;
  bool _isInitialized = false;

  static const String _systemPrompt = '''
You are PhoneWork AI, a brilliant and professional support assistant for the PhoneWork platform - a local labour hiring app connecting Workers with Work-Givers in India.

CORE PLATFORM KNOWLEDGE:
• Platform charges 5% commission on job wages from workers only
• Job completion requires OTP verification: Work-Giver shares OTP with Worker ONLY after work is complete
• KYC requires Government ID (Aadhaar/Driving License) + Clear Selfie, verified in 2-4 hours
• Workers can browse and apply to jobs in their category (Plumber, Electrician, Driver, Mason, Cleaner, etc.)
• Work-Givers post jobs with title, description, wage, and location

EARNINGS CALCULATION:
Example: If job wage is ₹1000
• Platform Fee (5%): ₹50
• Worker receives: ₹950
• Work-Giver pays exactly the posted amount (₹1000)

SAFETY RULES (CRITICAL - Always emphasize these):
1. NEVER share OTP with anyone except during legitimate job completion
2. NEVER enter bank details, passwords, or UPI pins in chat
3. Report any harassment or suspicious behavior immediately
4. Verify work is complete before sharing completion OTP

RESPONSE STYLE:
• Be concise but thorough and helpful
• Use **bold** for important terms and emphasis
• Use numbered lists for step-by-step guidance
• Be warm and professional - you're helping real workers find livelihoods
• If asked something outside PhoneWork scope, politely redirect to platform-related help
• Always acknowledge the user's role (Worker or Work-Giver) when known

EXAMPLE TOPICS YOU CAN HELP WITH:
• How to find jobs / post jobs
• Understanding wages and commissions
• KYC verification process
• Job completion and OTP process
• Payment issues and disputes
• Safety and platform rules
• Tips for workers to get more jobs
• Tips for work-givers to attract good workers
''';

  PhoneWorkAIService() {
    _initialize();
  }

  void _initialize() {
    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
        systemInstruction: Content.text(_systemPrompt),
      );
      _chat = _model!.startChat();
      _isInitialized = true;
      debugPrint('PhoneWork AI initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize PhoneWork AI: $e');
      _isInitialized = false;
    }
  }

  /// Send a message and get AI response
  Future<String> sendMessage(String userMessage, {String? userRole}) async {
    if (!_isInitialized || _chat == null) {
      debugPrint('AI not initialized, attempting to reinitialize...');
      _initialize();
      if (!_isInitialized) {
        throw AIServiceException('AI service not initialized');
      }
    }

    try {
      // Add context about user role if known
      String contextualMessage = userMessage;
      if (userRole != null) {
        contextualMessage = '[User is a $userRole] $userMessage';
      }

      debugPrint('Sending message to Gemini: $contextualMessage');

      final response = await _chat!.sendMessage(
        Content.text(contextualMessage),
      );

      final responseText = response.text;
      debugPrint(
        'Received response: ${responseText?.substring(0, responseText.length > 100 ? 100 : responseText.length)}...',
      );

      return responseText ??
          'I apologize, I could not generate a response. Please try again.';
    } catch (e) {
      debugPrint('Gemini API Error: $e');
      // Return error message for fallback handling
      throw AIServiceException('Failed to get AI response: $e');
    }
  }

  /// Reset conversation context
  void resetConversation() {
    if (_model != null) {
      _chat = _model!.startChat();
    }
  }

  /// Check if service is ready
  bool get isReady => _isInitialized && _chat != null;
}

class AIServiceException implements Exception {
  final String message;
  AIServiceException(this.message);

  @override
  String toString() => message;
}

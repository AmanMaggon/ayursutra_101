import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../services/openai_client.dart';
import '../../services/openai_service.dart';
import './widgets/chat_message_widget.dart';
import './widgets/floating_chat_bubble_widget.dart';
import './widgets/typing_indicator_widget.dart';
import './widgets/voice_input_widget.dart';

class AiDrishyaAssistantChatInterface extends StatefulWidget {
  const AiDrishyaAssistantChatInterface({super.key});

  @override
  State<AiDrishyaAssistantChatInterface> createState() =>
      _AiDrishyaAssistantChatInterfaceState();
}

class _AiDrishyaAssistantChatInterfaceState
    extends State<AiDrishyaAssistantChatInterface>
    with TickerProviderStateMixin {
  bool _isChatExpanded = false;
  bool _isTyping = false;
  bool _isLoading = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late final OpenAIClient _openAIClient;
  late final AnimationController _bubbleController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _openAIClient = OpenAIClient(OpenAIService().dio);
    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.easeInOut),
    );
    _bubbleController.repeat(reverse: true);

    // Add welcome message
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      content:
          "नमस्ते! मैं AI दृश्य हूँ, आपकी आयुर्वेदिक स्वास्थ्य सहायक। पंचकर्म थेरेपी, अपॉइंटमेंट शेड्यूलिंग, और स्वास्थ्य संबंधी सवालों में मैं आपकी सहायता कर सकती हूँ। आप मुझसे हिंदी, अंग्रेजी या अपनी क्षेत्रीय भाषा में बात कर सकते हैं।\n\nHello! I'm AI Drishya, your Ayurvedic health assistant. I can help you with Panchakarma therapy guidance, appointment scheduling, and health-related questions. How can I assist you today?",
      isUser: false,
      timestamp: DateTime.now(),
      hasQuickActions: true,
    );
    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  void _toggleChat() {
    setState(() {
      _isChatExpanded = !_isChatExpanded;
    });
  }

  void _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
      _isLoading = true;
    });

    _scrollToBottom();
    _messageController.clear();

    try {
      // Create AI context for healthcare assistant
      final contextualPrompt = """
You are AI Drishya, an expert Ayurvedic healthcare assistant for the AyurSutra Panchakarma Management System. 

**Your Role:**
- Provide accurate Panchakarma therapy guidance
- Help with appointment scheduling and session preparation
- Answer questions about Ayurvedic treatments, diet, and lifestyle
- Assist with pre/post-treatment care instructions
- Support in multiple languages (Hindi, English, regional languages)

**Guidelines:**
- Always maintain a professional, caring tone
- Include Sanskrit terms with translations when relevant
- Provide medical disclaimers for serious health concerns
- Suggest consulting doctors for complex medical issues
- Keep responses helpful and concise

**User's message:** $message

**Context:** This is within the AyurSutra healthcare management app, so users may ask about:
- Panchakarma procedures (Abhyanga, Shirodhara, Swedana, etc.)
- Appointment booking and scheduling
- Therapy preparation and aftercare
- Dietary recommendations
- General Ayurvedic wellness guidance

Please respond appropriately to their query with empathy and expertise.
""";

      final messages = [
        Message(
          role: 'user',
          content: contextualPrompt,
        ),
      ];

      // Use streaming for better UX
      StringBuffer responseBuffer = StringBuffer();
      await for (final chunk in _openAIClient.streamContentOnly(
        messages: messages,
        model: 'gpt-5-mini',
        reasoningEffort: 'minimal',
        options: {'max_completion_tokens': 500},
      )) {
        responseBuffer.write(chunk);

        // Update the typing message in real-time
        setState(() {
          if (_messages.isNotEmpty && !_messages.last.isUser) {
            _messages.removeLast();
          }
          _messages.add(ChatMessage(
            content: responseBuffer.toString(),
            isUser: false,
            timestamp: DateTime.now(),
            isStreaming: true,
          ));
        });
        _scrollToBottom();
      }

      // Mark streaming as complete and add quick actions if appropriate
      setState(() {
        if (_messages.isNotEmpty && !_messages.last.isUser) {
          _messages.removeLast();
        }
        _messages.add(ChatMessage(
          content: responseBuffer.toString(),
          isUser: false,
          timestamp: DateTime.now(),
          isStreaming: false,
          hasQuickActions: _shouldShowQuickActions(responseBuffer.toString()),
        ));
        _isTyping = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          content:
              "माफ़ करें, मुझे एक तकनीकी समस्या का सामना कर रहा है। कृपया थोड़ी देर बाद पुनः प्रयास करें।\n\nSorry, I'm experiencing a technical issue. Please try again in a moment.",
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ));
        _isTyping = false;
        _isLoading = false;
      });
    }
  }

  bool _shouldShowQuickActions(String response) {
    // Show quick actions if response mentions scheduling, booking, or general queries
    return response.toLowerCase().contains('appointment') ||
        response.toLowerCase().contains('booking') ||
        response.toLowerCase().contains('schedule') ||
        response.toLowerCase().contains('अपॉइंटमेंट');
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleQuickAction(String action) {
    String quickMessage = '';
    switch (action) {
      case 'book_appointment':
        quickMessage = 'I want to book an appointment for Panchakarma therapy';
        break;
      case 'view_sessions':
        quickMessage = 'Show me my upcoming therapy sessions';
        break;
      case 'notifications':
        quickMessage = 'Check my recent notifications';
        break;
      case 'diet_guidelines':
        quickMessage = 'Provide diet guidelines for my current therapy';
        break;
      case 'emergency':
        quickMessage = 'I need emergency assistance';
        break;
      default:
        return;
    }
    _sendMessage(quickMessage);
  }

  void _handleVoiceInput(String text) {
    _messageController.text = text;
    _sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Chat Modal Overlay
          if (_isChatExpanded)
            GestureDetector(
              onTap: _toggleChat,
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: GestureDetector(
                    onTap: () {}, // Prevent closing when tapping on modal
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                // AyurSutra Logo
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      'assets/images/Ayursutra_Logo_1_-1759156879861.png',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.healing,
                                          color: Colors.white,
                                          size: 20,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'AI Drishya',
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Powered by AyurSutra AI • Always here to help',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Online indicator
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.greenAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: _toggleChat,
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Chat Area
                          Container(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Column(
                              children: [
                                // Messages
                                Expanded(
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.all(16),
                                    itemCount: _messages.length,
                                    itemBuilder: (context, index) {
                                      final message = _messages[index];
                                      return ChatMessageWidget(
                                        message: message,
                                        onQuickAction: message.hasQuickActions
                                            ? _handleQuickAction
                                            : null,
                                      );
                                    },
                                  ),
                                ),
                                // Typing indicator
                                if (_isTyping)
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: TypingIndicatorWidget(),
                                  ),
                                // Input Area
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    border: Border(
                                      top: BorderSide(
                                        color: Theme.of(context).dividerColor,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Voice Input Button
                                      VoiceInputWidget(
                                        onVoiceResult: _handleVoiceInput,
                                        isEnabled: !_isLoading,
                                      ),
                                      const SizedBox(width: 12),
                                      // Text Input
                                      Expanded(
                                        child: TextField(
                                          controller: _messageController,
                                          enabled: !_isLoading,
                                          decoration: InputDecoration(
                                            hintText:
                                                'आपका प्रश्न टाइप करें... / Type your question...',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              borderSide: BorderSide.none,
                                            ),
                                            filled: true,
                                            fillColor: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            hintStyle: GoogleFonts.inter(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              fontSize: 14,
                                            ),
                                          ),
                                          style:
                                              GoogleFonts.inter(fontSize: 14),
                                          maxLines: null,
                                          textInputAction: TextInputAction.send,
                                          onSubmitted: _sendMessage,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Send Button
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        child: IconButton(
                                          onPressed: _isLoading
                                              ? null
                                              : () => _sendMessage(
                                                  _messageController.text),
                                          icon: _isLoading
                                              ? SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.send_rounded,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                          style: IconButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer
                                                .withValues(alpha: 0.3),
                                            shape: const CircleBorder(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Floating Chat Bubble
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingChatBubbleWidget(
              isExpanded: _isChatExpanded,
              onTap: _toggleChat,
              pulseAnimation: _pulseAnimation,
            ),
          ),
        ],
      ),
    );
  }
}
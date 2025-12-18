import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';
import '../../../../services/ai/ai_service.dart';
import '../../../../app/theme.dart';

class AIChatScreen extends StatefulWidget {
  final String? lessonContext;
  final String? initialQuestion;
  const AIChatScreen({super.key, this.lessonContext, this.initialQuestion});
  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> with TickerProviderStateMixin {
  final AIService _aiService = AIService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final List<ChatMessage> _messages = [];
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool _isLoading = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _speechAvailable = false;
  String _selectedModel = AIService.modelClaudeHaiku;
  String? _speakingId;
  late AnimationController _typingController;
  late AnimationController _micController;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
    _micController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    _initTts();
    _initSpeech();
    _loadChatHistory();
  }

  Future<void> _initTts() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setLanguage('en-US');
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() { _isSpeaking = false; _speakingId = null; });
    });
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else if (_speechAvailable) {
      await _speech.listen(
        onResult: (result) {
          setState(() => _controller.text = result.recognizedWords);
          if (result.finalResult && _controller.text.isNotEmpty) _sendMessage();
        },
        listenFor: const Duration(seconds: 30),
      );
      setState(() => _isListening = true);
    }
  }

  Future<void> _speak(String text, String id) async {
    if (_isSpeaking && _speakingId == id) {
      await _flutterTts.stop();
      setState(() { _isSpeaking = false; _speakingId = null; });
    } else {
      if (_isSpeaking) await _flutterTts.stop();
      setState(() { _isSpeaking = true; _speakingId = id; });
      // Remove markdown formatting for speech
      final cleanText = text.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
      await _flutterTts.speak(cleanText);
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('ai_chat_history');
      if (json != null) {
        setState(() => _messages.addAll((jsonDecode(json) as List).map((m) => ChatMessage.fromJson(m))));
      }
      if (_messages.isEmpty) _addWelcome();
    } catch (_) {
      _addWelcome();
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_chat_history', jsonEncode(_messages.map((m) => m.toJson()).toList()));
  }

  void _addWelcome() {
    _messages.add(ChatMessage(
      id: '0',
      text: 'Hello! I\'m your AI English tutor. 👋\n\n🎤 Tap mic to speak\n🔊 Tap speaker to hear responses\n\nHow can I help you today?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _sendMessage([String? text]) async {
    final msg = (text ?? _controller.text).trim();
    if (msg.isEmpty || _isLoading) return;
    setState(() {
      _messages.add(ChatMessage(id: DateTime.now().millisecondsSinceEpoch.toString(), text: msg, isUser: true, timestamp: DateTime.now()));
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();
    await _saveHistory();

    try {
      _aiService.setModel(_selectedModel);
      final history = _messages.take(10).map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text}).toList();
      final response = widget.lessonContext != null
          ? await _aiService.answerQuestion(question: msg, lessonContext: widget.lessonContext!)
          : await _aiService.chat(message: msg, history: history);
      setState(() => _messages.add(ChatMessage(id: DateTime.now().millisecondsSinceEpoch.toString(), text: response, isUser: false, timestamp: DateTime.now())));
      await _saveHistory();
    } catch (_) {
      setState(() => _messages.add(ChatMessage(id: DateTime.now().millisecondsSinceEpoch.toString(), text: 'Error occurred. Please try again.', isUser: false, timestamp: DateTime.now(), isError: true)));
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _clearChat() async {
    setState(() { _messages.clear(); _addWelcome(); });
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ai_chat_history');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.smart_toy, size: 20)),
          const SizedBox(width: 12),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI English Tutor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Always here to help', style: TextStyle(fontSize: 11)),
          ]),
        ]),
        actions: [IconButton(icon: const Icon(Icons.delete_outline), onPressed: _clearChat)],
      ),
      body: Column(children: [
        Expanded(child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: _messages.length + (_isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _messages.length) return _buildTyping();
            return _buildBubble(_messages[index]);
          },
        )),
        _buildInput(),
      ]),
    );
  }

  Widget _buildTyping() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(children: [
        const CircleAvatar(radius: 16, backgroundColor: AppTheme.primaryColor, child: Icon(Icons.smart_toy, size: 18, color: Colors.white)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) => AnimatedBuilder(
            animation: _typingController,
            builder: (_, __) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8, height: 8,
              decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.3 + ((_typingController.value + i * 0.2) % 1.0) * 0.7), shape: BoxShape.circle),
            ),
          ))),
        ),
      ]),
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    final speaking = _isSpeaking && _speakingId == msg.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(radius: 16, backgroundColor: msg.isError ? Colors.red.shade100 : AppTheme.primaryColor, child: Icon(msg.isError ? Icons.error : Icons.smart_toy, size: 18, color: msg.isError ? Colors.red : Colors.white)),
            const SizedBox(width: 8),
          ],
          Flexible(child: Column(crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser ? const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]) : null,
                color: isUser ? null : (msg.isError ? Colors.red.shade50 : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20), topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4), bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
              ),
              child: _formatText(msg.text, isUser, msg.isError),
            ),
            if (!isUser && !msg.isError) Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _actionBtn(speaking ? Icons.stop : Icons.volume_up, speaking ? Colors.orange : Colors.grey, () => _speak(msg.text, msg.id)),
                const SizedBox(width: 8),
                _actionBtn(Icons.copy, Colors.grey, () { Clipboard.setData(ClipboardData(text: msg.text)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!'), duration: Duration(seconds: 1))); }),
              ]),
            ),
          ])),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 18, color: color)));
  }

  /// Format text with bold support (converts *text* to bold)
  Widget _formatText(String text, bool isUser, bool isError) {
    final baseColor = isUser ? Colors.white : (isError ? Colors.red.shade700 : Colors.black87);
    final boldColor = isUser ? Colors.white : AppTheme.primaryColor;
    
    final List<InlineSpan> spans = [];
    final regex = RegExp(r'\*([^*]+)\*');
    int lastEnd = 0;
    
    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start), style: TextStyle(fontSize: 15, height: 1.5, color: baseColor)));
      }
      spans.add(TextSpan(text: match.group(1), style: TextStyle(fontSize: 15, height: 1.5, color: boldColor, fontWeight: FontWeight.bold)));
      lastEnd = match.end;
    }
    
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd), style: TextStyle(fontSize: 15, height: 1.5, color: baseColor)));
    }
    
    if (spans.isEmpty) {
      return SelectableText(text, style: TextStyle(fontSize: 15, height: 1.5, color: baseColor));
    }
    return SelectableText.rich(TextSpan(children: spans));
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: SafeArea(child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        // Mic button
        AnimatedBuilder(animation: _micController, builder: (_, __) => Container(
          decoration: BoxDecoration(shape: BoxShape.circle, color: _isListening ? Colors.red.withOpacity(0.1 + _micController.value * 0.2) : Colors.grey.withOpacity(0.1)),
          child: IconButton(icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Colors.grey[600]), onPressed: _toggleListening),
        )),
        const SizedBox(width: 8),
        // Text field
        Expanded(child: Container(
          decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(24)),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(hintText: _isListening ? 'Listening...' : 'Type message...', hintStyle: TextStyle(color: _isListening ? Colors.red : Colors.grey), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
            maxLines: 4, minLines: 1,
            onSubmitted: (_) => _sendMessage(),
          ),
        )),
        const SizedBox(width: 8),
        // Send button
        Container(
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]), shape: BoxShape.circle),
          child: IconButton(
            icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send, color: Colors.white),
            onPressed: _isLoading ? null : () => _sendMessage(),
          ),
        ),
      ])),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingController.dispose();
    _micController.dispose();
    _flutterTts.stop();
    _speech.stop();
    super.dispose();
  }
}

class ChatMessage {
  final String id, text;
  final bool isUser, isError;
  final DateTime timestamp;
  ChatMessage({required this.id, required this.text, required this.isUser, required this.timestamp, this.isError = false});
  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'isUser': isUser, 'timestamp': timestamp.toIso8601String(), 'isError': isError};
  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(id: j['id'] ?? '0', text: j['text'] ?? '', isUser: j['isUser'] ?? false, timestamp: DateTime.tryParse(j['timestamp'] ?? '') ?? DateTime.now(), isError: j['isError'] ?? false);
}

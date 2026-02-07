import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/api_providers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class MiraChatScreen extends ConsumerStatefulWidget {
  const MiraChatScreen({super.key});

  @override
  ConsumerState<MiraChatScreen> createState() => _MiraChatScreenState();
}

class _MiraChatScreenState extends ConsumerState<MiraChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  
  // Voice variables
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      await _speech.initialize(
        onStatus: (status) => debugPrint('Voice status: $status'),
        onError: (error) => debugPrint('Voice error: $error'),
      );
    } catch (e) {
      debugPrint('Speech init error: $e');
    }
  }

  Future<void> _listen() async {
    if (!_isListening) {
      var status = await Permission.microphone.request();
      if (status.isDenied) return;

      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _messageController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final chatRepo = ref.read(chatRepositoryProvider);
      final history = await chatRepo.getHistory();
      if (!mounted) return;
      setState(() {
        _messages.clear();
        if (history.isEmpty) {
          _messages.add(
            ChatMessage(
              text:
                  'Mira ! 👋 Je suis ton assistant IA.\n\nJe peux t\'aider à :\n• Vérifier des informations\n• Reformuler tes messages\n• T\'entraîner à débattre\n\nComment puis-je t\'aider ?',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        } else {
          for (final msg in history) {
            _messages.add(
              ChatMessage(
                text: msg.text,
                isUser: msg.isUser,
                timestamp: msg.createdAt,
              ),
            );
          }
        }
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      _messages.add(
        ChatMessage(
          text:
              'Mira ! 👋 Je suis ton assistant IA.\n\nJe peux t\'aider à :\n• Vérifier des informations\n• Reformuler tes messages\n• T\'entraîner à débattre\n\nComment puis-je t\'aider ?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      final chatRepo = ref.read(chatRepositoryProvider);
      final result = await chatRepo.sendMessage(text);
      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(
            text: result['miraResponse']!.text,
            isUser: false,
            timestamp: result['miraResponse']!.createdAt,
          ),
        );
        _isTyping = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Désolé, une erreur est survenue. Réessaie ! 🙏',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isTyping = false;
      });
    }

    _scrollToBottom();
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



  Future<void> _clearChatHistory() async {
    try {
      final chatRepo = ref.read(chatRepositoryProvider);
      await chatRepo.clearHistory();
      if (!mounted) return;
      setState(() {
        _messages.clear();
        _messages.add(
          ChatMessage(
            text: 'Mira ! 👋 Ton historique a été effacé.\n\nComment puis-je t\'aider à nouveau ?',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Historique supprimé')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Image(
                  image: AssetImage('assets/images/image_agent.png'),
                  width: 28,
                  height: 28,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mira',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkGray),
                ),
                Text(
                  'En ligne • Assistant IA',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.accentRed),
            onPressed: () {
              _showClearConfirmDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.mediumGray),
            onPressed: () {
              _showInfoDialog();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),


          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Voice button - Premium
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          AppColors.lightGray.withValues(alpha: 0.5),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.8),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _listen,
                        borderRadius: BorderRadius.circular(26),
                        child: Center(
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            size: 24,
                            color: _isListening ? AppColors.accentRed : AppColors.primaryPurple,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Text field - Premium input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            AppColors.lightGray.withValues(alpha: 0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryPurple.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Écris ton message...',
                          hintStyle: TextStyle(
                            color: AppColors.mediumGray,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Send button with premium design
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _sendMessage(_messageController.text),
                        borderRadius: BorderRadius.circular(28),
                        child: const Center(
                          child: Icon(
                            Icons.send_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Image(
                image: AssetImage('assets/images/image_agent.png'),
                width: 90,
                height: 90,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Mira est prête à t\'aider ! ✨',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.darkGray,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Choisis une suggestion ou écris-moi\nn\'importe quoi pour commencer.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.mediumGray, height: 1.5),
          ),
          const SizedBox(height: 48),
          
          // Suggestion Grid
          _buildSuggestionGroup('Populaire', [
            '🔍 Vérifier une rumeur',
            '✨ Reformuler en bienveillant',
          ]),
          const SizedBox(height: 16),
          _buildSuggestionGroup('Apprentissage', [
            '🎯 M\'entraîner au débat',
            '💡 Conseils anti-haine',
            '🛡️ Gérer un cyberharceleur',
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSuggestionGroup(String title, List<String> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.mediumGray, letterSpacing: 0.5),
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: suggestions.map((s) => _buildAdvancedSuggestionChip(s)).toList(),
        ),
      ],
    );
  }

  Widget _buildAdvancedSuggestionChip(String text) {
    return InkWell(
      onTap: () {
        // Enlève l'emoji au début pour l'envoi
        String cleanText = text.replaceFirst(RegExp(r'^[^ ]+ '), '');
        _messageController.text = cleanText;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryPurple.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
      ),
    );
  }

  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vider le chat ?'),
        content: const Text('Toute la conversation sera définitivement supprimée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearChatHistory();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.accentRed),
            child: const Text('Oui, vider'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPurple.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Image(
                  image: AssetImage('assets/images/image_agent.png'),
                  width: 30,
                  height: 30,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: message.isUser
                    ? AppColors.primaryGradient
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          AppColors.lightGray.withValues(alpha: 0.5),
                        ],
                      ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(message.isUser ? 24 : 6),
                  bottomRight: Radius.circular(message.isUser ? 6 : 24),
                ),
                border: Border.all(
                  color: message.isUser
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.8),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: message.isUser
                        ? AppColors.primaryPurple.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: message.isUser ? 16 : 12,
                    offset: const Offset(0, 4),
                  ),
                  if (!message.isUser)
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.6),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: message.isUser ? Colors.white : AppColors.darkGray,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Consumer(
              builder: (context, ref, child) {
                final userAsync = ref.watch(currentUserProvider);
                return userAsync.when(
                  data: (user) => Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.accentYellow,
                      shape: BoxShape.circle,
                      image: user.avatar != null && user.avatar!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(user.avatar!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: user.avatar == null || user.avatar!.isEmpty
                        ? Center(
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : '👤',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGray,
                              ),
                            ),
                          )
                        : null,
                  ),
                  loading: () => Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.lightGray,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  error: (_, __) => Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.accentYellow,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('👤', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image(
                image: AssetImage('assets/images/image_agent.png'),
                width: 24,
                height: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(20),
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
      duration: Duration(milliseconds: 600 + (index * 100)),
      builder: (context, value, child) {
        return Opacity(
          opacity: 0.3 + (value * 0.7),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.mediumGray,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }



  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos de Mira'),
        content: const Text(
          'Mira est ton assistant IA personnel qui t\'aide à :\n\n'
          '• Vérifier les informations\n'
          '• Reformuler tes messages\n'
          '• T\'entraîner au débat constructif\n\n'
          'Toutes les conversations sont privées et sécurisées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

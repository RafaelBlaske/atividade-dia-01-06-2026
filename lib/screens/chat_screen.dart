import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/message_model.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import 'settings_screen.dart';
import 'history_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: _buildAppBar(context),
      body: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          if (provider.isTyping || provider.hasMessages) {
            _scrollToBottom();
          }

          return Column(
            children: [
              if (!provider.hasApiKey) _buildApiKeyBanner(context),
              Expanded(
                child: provider.hasMessages
                    ? _buildMessageList(provider)
                    : _buildWelcomeScreen(context, provider),
              ),
              ChatInput(
                onSend: (text) => provider.sendMessage(text),
                isLoading: provider.isTyping,
              ),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final model = GroqModel.available.firstWhere(
      (m) => m.id == provider.selectedModel,
      orElse: () => GroqModel.available.first,
    );

    return AppBar(
      backgroundColor: AppTheme.surface,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: provider.hasApiKey ? AppTheme.primary : AppTheme.error,
                  shape: BoxShape.circle,
                ),
              ),
              const Text('ChatGroq'),
            ],
          ),
          Text(
            model.name,
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        // Botão de histórico
        IconButton(
          icon: const Icon(Icons.history_rounded),
          tooltip: 'Histórico',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          ),
        ),
        // Novo chat
        if (provider.hasMessages)
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'Nova conversa',
            onPressed: () => _confirmNewChat(context, provider),
          ),
        // Configurações
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          tooltip: 'Configurações',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildApiKeyBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: AppTheme.error.withOpacity(0.15),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppTheme.error, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'API Key não configurada. Toque para configurar.',
                style: GoogleFonts.inter(
                  color: AppTheme.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.error, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(ChatProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: provider.messages.length + (provider.isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.messages.length) {
          return const TypingIndicator();
        }
        return MessageBubble(message: provider.messages[index]);
      },
    );
  }

  Widget _buildWelcomeScreen(BuildContext context, ChatProvider provider) {
    final suggestions = [
      'Explique o que é inteligência artificial',
      'Me ajude a criar um plano de estudos',
      'Escreva um e-mail profissional',
      'Dê 5 dicas de produtividade',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: AppTheme.primary, size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            'ChatGroq',
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'IA de alta velocidade com modelos Llama',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 36),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sugestões',
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...suggestions.map((s) => _SuggestionChip(
                label: s,
                onTap: provider.hasApiKey
                    ? () => provider.sendMessage(s)
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SettingsScreen()),
                        ),
              )),
        ],
      ),
    );
  }

  Future<void> _confirmNewChat(
      BuildContext context, ChatProvider provider) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Nova conversa?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'A conversa atual será salva no histórico.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Nova conversa'),
          ),
        ],
      ),
    );
    if (ok == true) await provider.startNewChat();
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline_rounded,
                color: AppTheme.primary, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppTheme.textSecondary, size: 12),
          ],
        ),
      ),
    );
  }
}

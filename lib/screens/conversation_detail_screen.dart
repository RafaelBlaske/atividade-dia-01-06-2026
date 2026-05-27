import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/message_bubble.dart';

class ConversationDetailScreen extends StatelessWidget {
  final ConversationModel conversation;

  const ConversationDetailScreen({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    final modelName = GroqModel.available
        .where((m) => m.id == conversation.modelId)
        .map((m) => m.name)
        .firstOrNull ?? conversation.modelId;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              conversation.title.isNotEmpty
                  ? conversation.title
                  : 'Conversa',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            Text(
              '${DateFormat('dd/MM/yy HH:mm').format(conversation.createdAt)} · $modelName',
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Mensagens ────────────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              physics: const BouncingScrollPhysics(),
              itemCount: conversation.messages.length,
              itemBuilder: (context, index) =>
                  MessageBubble(message: conversation.messages[index]),
            ),
          ),

          // ── Botão continuar conversa ─────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _continueConversation(context),
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text('Continuar essa conversa'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _continueConversation(BuildContext context) async {
    final provider = context.read<ChatProvider>();

    // Carrega a conversa no provider principal
    await provider.loadConversation(conversation);

    if (!context.mounted) return;

    // Volta para a chat screen (pop até a raiz)
    Navigator.of(context).popUntil((route) => route.isFirst);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppTheme.primary, size: 18),
            const SizedBox(width: 10),
            const Text('Conversa carregada!'),
          ],
        ),
        backgroundColor: AppTheme.card,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

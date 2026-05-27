import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/message_model.dart';
import '../theme/app_theme.dart';

class MessageBubble extends StatefulWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _copied = false;

  bool get _isUser => widget.message.role == MessageRole.user;

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.message.content));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment:
            _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!_isUser) _buildAvatar(),
          if (!_isUser) const SizedBox(width: 8),
          Flexible(child: _buildBubble()),
          if (_isUser) const SizedBox(width: 8),
          if (_isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: widget.message.isError
            ? AppTheme.error.withOpacity(0.2)
            : AppTheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.message.isError
              ? AppTheme.error.withOpacity(0.4)
              : AppTheme.primary.withOpacity(0.3),
        ),
      ),
      child: Icon(
        widget.message.isError
            ? Icons.error_outline_rounded
            : Icons.auto_awesome_rounded,
        size: 16,
        color: widget.message.isError ? AppTheme.error : AppTheme.primary,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: const Icon(Icons.person_rounded, size: 16, color: AppTheme.accent),
    );
  }

  Widget _buildBubble() {
    return Column(
      crossAxisAlignment:
          _isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _isUser ? AppTheme.userBubble : AppTheme.aiBubble,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(_isUser ? 16 : 4),
              bottomRight: Radius.circular(_isUser ? 4 : 16),
            ),
            border: Border.all(
              color: _isUser
                  ? AppTheme.accent.withOpacity(0.2)
                  : widget.message.isError
                      ? AppTheme.error.withOpacity(0.3)
                      : AppTheme.primary.withOpacity(0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.message.content,
                style: GoogleFonts.inter(
                  color: widget.message.isError
                      ? AppTheme.error
                      : AppTheme.textPrimary,
                  fontSize: 14.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(widget.message.createdAt),
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        // Botão de copiar — só aparece nas mensagens da IA
        if (!_isUser && !widget.message.isError) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: _copyToClipboard,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _copied
                    ? AppTheme.primary.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _copied
                      ? AppTheme.primary.withOpacity(0.4)
                      : AppTheme.divider,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _copied
                        ? Icons.check_rounded
                        : Icons.copy_rounded,
                    size: 13,
                    color:
                        _copied ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _copied ? 'Copiado!' : 'Copiar',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _copied
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Widget para o indicador "digitando..."
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                size: 16, color: AppTheme.primary),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.aiBubble,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) {
                    final delay = i * 0.33;
                    final t = (_ctrl.value + delay) % 1.0;
                    final opacity =
                        (0.3 + 0.7 * (t < 0.5 ? t * 2 : (1 - t) * 2))
                            .clamp(0.3, 1.0);
                    return Container(
                      margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(opacity),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

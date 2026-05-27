import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSend;
  final bool isLoading;

  const ChatInput({super.key, required this.onSend, required this.isLoading});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _hasText = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    if (!_hasText || widget.isLoading) return;
    final text = _controller.text.trim();
    _controller.clear();
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.divider),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 5,
                minLines: 1,
                enabled: !widget.isLoading,
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Escreva uma mensagem...',
                  hintStyle: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _send(),
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Botão enviar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: (_hasText && !widget.isLoading)
                  ? AppTheme.primary
                  : AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: (_hasText && !widget.isLoading)
                    ? AppTheme.primary
                    : AppTheme.divider,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: (_hasText && !widget.isLoading) ? _send : null,
              icon: widget.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      size: 20,
                      color: _hasText ? Colors.black : AppTheme.textSecondary,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

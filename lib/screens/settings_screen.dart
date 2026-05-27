import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/message_model.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _keyController;
  bool _obscure = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ChatProvider>();
    _keyController = TextEditingController(text: provider.apiKey);
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_keyController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await context.read<ChatProvider>().saveApiKey(_keyController.text);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 18),
            SizedBox(width: 10),
            Text('API Key salva com sucesso!'),
          ],
        ),
        backgroundColor: AppTheme.card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: AppTheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── API Key ────────────────────────────────────────────────────────
          _SectionTitle('Groq API Key'),
          const SizedBox(height: 10),
          // Como obter a chave
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppTheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Como obter sua chave:',
                      style: GoogleFonts.inter(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Acesse console.groq.com\n'
                  '2. Faça login (gratuito)\n'
                  '3. Vá em "API Keys" → "Create API Key"\n'
                  '4. Copie e cole abaixo',
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Campo da chave
          TextField(
            controller: _keyController,
            obscureText: _obscure,
            style: GoogleFonts.robotoMono(
              color: AppTheme.textPrimary,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              labelText: 'API Key',
              hintText: 'gsk_...',
              prefixIcon: const Icon(Icons.vpn_key_rounded, color: AppTheme.primary),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.black, strokeWidth: 2),
                    )
                  : const Text('Salvar API Key'),
            ),
          ),
          if (provider.hasApiKey) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () async {
                await provider.clearApiKey();
                _keyController.clear();
              },
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppTheme.error, size: 18),
              label: const Text(
                'Remover API Key',
                style: TextStyle(color: AppTheme.error),
              ),
            ),
          ],

          const SizedBox(height: 28),
          const Divider(color: AppTheme.divider),
          const SizedBox(height: 20),

          // ── Modelo ─────────────────────────────────────────────────────────
          _SectionTitle('Modelo de IA'),
          const SizedBox(height: 12),
          ...GroqModel.available.map((model) {
            final selected = provider.selectedModel == model.id;
            return GestureDetector(
              onTap: () => provider.setModel(model.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primary.withOpacity(0.1)
                      : AppTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppTheme.primary : AppTheme.divider,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model.name,
                            style: GoogleFonts.inter(
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            model.description,
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected)
                      const Icon(Icons.check_circle_rounded,
                          color: AppTheme.primary, size: 20),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 28),
          const Divider(color: AppTheme.divider),
          const SizedBox(height: 20),

          // ── Temperatura ────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionTitle('Temperatura'),
              Text(
                provider.temperature.toStringAsFixed(1),
                style: GoogleFonts.robotoMono(
                  color: AppTheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            'Controla a criatividade das respostas (0 = preciso, 1 = criativo)',
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          Slider(
            value: provider.temperature,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            activeColor: AppTheme.primary,
            inactiveColor: AppTheme.divider,
            onChanged: provider.setTemperature,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
    );
  }
}

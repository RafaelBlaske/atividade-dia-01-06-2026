import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../providers/chat_provider.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import 'conversation_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  List<ConversationModel> _allHistory = [];
  List<ConversationModel> _filteredHistory = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _showFavoritesOnly = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await HistoryService().loadHistory();
    setState(() {
      _allHistory = history;
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    _filteredHistory = _allHistory.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFavorite = !_showFavoritesOnly || item.isFavorite;
      return matchesSearch && matchesFavorite;
    }).toList();
  }

  Future<void> _deleteItem(String id) async {
    await HistoryService().deleteConversation(id);
    await _loadHistory();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Conversa removida do histórico'),
          backgroundColor: AppTheme.card,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _toggleFavorite(String id) async {
    await HistoryService().toggleFavorite(id);
    await _loadHistory();
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Limpar Histórico',
          style: GoogleFonts.inter(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Tem certeza que deseja apagar todo o histórico? Esta ação não pode ser desfeita.',
          style: GoogleFonts.inter(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Apagar Tudo',
                style: GoogleFonts.inter(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HistoryService().clearHistory();
      await _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Histórico',
          style: GoogleFonts.inter(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_allHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded,
                  color: AppTheme.error),
              tooltip: 'Limpar tudo',
              onPressed: _clearHistory,
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle:
              GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          onTap: (index) {
            setState(() {
              _showFavoritesOnly = index == 1;
              _applyFilters();
            });
          },
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Favoritas'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Barra de busca ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (v) {
                setState(() {
                  _searchQuery = v;
                  _applyFilters();
                });
              },
              style: GoogleFonts.inter(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar nas conversas...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppTheme.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: AppTheme.textSecondary, size: 18),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _applyFilters();
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),

          // ── Contador ────────────────────────────────────────────────────────
          if (!_isLoading && _allHistory.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${_filteredHistory.length} conversa${_filteredHistory.length != 1 ? 's' : ''}',
                    style: GoogleFonts.inter(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),

          // ── Lista ────────────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppTheme.primary))
                : _filteredHistory.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: _filteredHistory.length,
                        itemBuilder: (context, index) =>
                            _buildConversationCard(_filteredHistory[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(ConversationModel conv) {
    final modelName = GroqModel.available
        .where((m) => m.id == conv.modelId)
        .map((m) => m.name)
        .firstOrNull ?? conv.modelId;

    final dateStr = _formatDate(conv.createdAt);
    final msgCount = conv.exchangeCount;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConversationDetailScreen(conversation: conv),
        ),
      ).then((_) => _loadHistory()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: conv.isFavorite
                ? AppTheme.primary.withOpacity(0.4)
                : AppTheme.divider,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícone
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded,
                  color: AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 12),

            // Conteúdo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conv.title.isNotEmpty ? conv.title : 'Conversa sem título',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _Tag(
                        label: modelName,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 6),
                      _Tag(
                        label: '$msgCount msg${msgCount != 1 ? 's' : ''}',
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: GoogleFonts.inter(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Ações
            Column(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    conv.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: conv.isFavorite
                        ? Colors.amber
                        : AppTheme.textSecondary,
                    size: 22,
                  ),
                  onPressed: () => _toggleFavorite(conv.id),
                ),
                const SizedBox(height: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppTheme.textSecondary, size: 20),
                  onPressed: () => _confirmDelete(conv),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(ConversationModel conv) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remover conversa?',
            style: GoogleFonts.inter(color: AppTheme.textPrimary)),
        content: Text(
          '"${conv.title}" será removida do histórico.',
          style: GoogleFonts.inter(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancelar',
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Remover',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok == true) await _deleteItem(conv.id);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _showFavoritesOnly
                  ? Icons.star_border_rounded
                  : Icons.history_rounded,
              color: AppTheme.textSecondary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _showFavoritesOnly ? 'Nenhum favorito ainda' : 'Histórico vazio',
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _showFavoritesOnly
                ? 'Marque conversas como favoritas\npara acessá-las rapidamente'
                : 'Suas conversas aparecerão\nautomaticamente aqui',
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Agora mesmo';
    if (diff.inHours < 1) return 'Há ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Hoje, ${DateFormat('HH:mm').format(dt)}';
    if (diff.inDays == 1) return 'Ontem, ${DateFormat('HH:mm').format(dt)}';
    if (diff.inDays < 7) return DateFormat("EEE, HH:mm", 'pt_BR').format(dt);
    return DateFormat('dd/MM/yy HH:mm').format(dt);
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

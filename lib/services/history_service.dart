import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversation_model.dart';

class HistoryService {
  static const String _historyKey = 'chatgroq_history';
  static const int _maxItems = 100;

  // Singleton
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  // ─── Salvar / atualizar conversa ────────────────────────────────────────────
  Future<void> saveConversation(ConversationModel conv) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadHistory();

    // Preserva o isFavorite de uma versão anterior
    final existing = history.where((c) => c.id == conv.id).isNotEmpty
        ? history.firstWhere((c) => c.id == conv.id)
        : null;
    if (existing != null) conv.isFavorite = existing.isFavorite;

    history.removeWhere((c) => c.id == conv.id);
    history.insert(0, conv);

    if (history.length > _maxItems) history.removeRange(_maxItems, history.length);

    await prefs.setString(
      _historyKey,
      jsonEncode(history.map((c) => c.toJson()).toList()),
    );
  }

  // ─── Carregar histórico ──────────────────────────────────────────────────────
  Future<List<ConversationModel>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    if (jsonString == null) return [];

    try {
      final list = jsonDecode(jsonString) as List;
      return list
          .map((j) => ConversationModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ─── Deletar conversa ────────────────────────────────────────────────────────
  Future<void> deleteConversation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadHistory();
    history.removeWhere((c) => c.id == id);
    await prefs.setString(
      _historyKey,
      jsonEncode(history.map((c) => c.toJson()).toList()),
    );
  }

  // ─── Favoritar / desfavoritar ────────────────────────────────────────────────
  Future<void> toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadHistory();
    final idx = history.indexWhere((c) => c.id == id);
    if (idx != -1) {
      history[idx].isFavorite = !history[idx].isFavorite;
      await prefs.setString(
        _historyKey,
        jsonEncode(history.map((c) => c.toJson()).toList()),
      );
    }
  }

  // ─── Limpar tudo ─────────────────────────────────────────────────────────────
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}

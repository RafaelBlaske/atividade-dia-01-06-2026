import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message_model.dart';
import '../models/conversation_model.dart';
import '../services/groq_service.dart';
import '../services/history_service.dart';
import '../config/app_config.dart'; // ← chave padrão embutida

class ChatProvider extends ChangeNotifier {
  final GroqService _groqService;

  ChatProvider({GroqService? groqService})
      : _groqService = groqService ?? GroqService();

  // ─── State ───────────────────────────────────────────────────────────────────
  List<Message> _messages = [];
  bool _isTyping = false;
  String _errorMessage = '';
  // Usa a chave embutida como valor inicial — nunca fica vazia
  String _apiKey = AppConfig.defaultApiKey;
  String _selectedModel = GroqModel.available[0].id;
  double _temperature = 0.7;

  // Controle de conversa atual
  String _currentConversationId = _newId();
  DateTime _conversationStartedAt = DateTime.now();

  static String _newId() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  // ─── Getters ─────────────────────────────────────────────────────────────────
  List<Message> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  String get errorMessage => _errorMessage;
  String get apiKey => _apiKey;
  String get selectedModel => _selectedModel;
  double get temperature => _temperature;
  bool get hasApiKey => _apiKey.trim().isNotEmpty;
  bool get hasMessages => _messages.isNotEmpty;

  // ─── Carregar preferências salvas ────────────────────────────────────────────
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Se o usuário salvou uma chave personalizada, usa ela.
    // Caso contrário, mantém a chave padrão embutida no AppConfig.
    final saved = prefs.getString('groq_api_key');
    if (saved != null && saved.trim().isNotEmpty) {
      _apiKey = saved.trim();
    }
    // Se não há nada salvo, _apiKey já está com AppConfig.defaultApiKey

    _selectedModel = prefs.getString('groq_model') ?? GroqModel.available[0].id;
    _temperature = prefs.getDouble('groq_temperature') ?? 0.7;
    notifyListeners();
  }

  // ─── Salvar API Key ──────────────────────────────────────────────────────────
  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('groq_api_key', key.trim());
    _apiKey = key.trim();
    _errorMessage = '';
    notifyListeners();
  }

  // ─── Salvar modelo selecionado ───────────────────────────────────────────────
  Future<void> setModel(String modelId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('groq_model', modelId);
    _selectedModel = modelId;
    notifyListeners();
  }

  // ─── Salvar temperatura ───────────────────────────────────────────────────────
  Future<void> setTemperature(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('groq_temperature', value);
    _temperature = value;
    notifyListeners();
  }

  // ─── Enviar mensagem ─────────────────────────────────────────────────────────
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    if (_isTyping) return;

    _errorMessage = '';

    final userMsg = Message.user(content.trim());
    _messages.add(userMsg);
    _isTyping = true;
    notifyListeners();

    try {
      final reply = await _groqService.sendMessage(
        apiKey: _apiKey,
        model: _selectedModel,
        messages: _messages,
        temperature: _temperature,
      );
      _messages.add(Message.assistant(reply));
    } catch (e) {
      final errMsg = e is GroqException ? e.message : 'Erro desconhecido.';
      _errorMessage = errMsg;
      _messages.add(Message.assistant(errMsg, isError: true));
    } finally {
      _isTyping = false;
      notifyListeners();
    }

    // Auto-salva após cada troca completa
    await _autoSave();
  }

  // ─── Auto-salvar a conversa atual no histórico ───────────────────────────────
  Future<void> _autoSave() async {
    final userMsgs = _messages.where((m) => m.role == MessageRole.user);
    if (userMsgs.isEmpty) return;

    final title = userMsgs.first.content;
    final conv = ConversationModel(
      id: _currentConversationId,
      title: title.length > 65 ? '${title.substring(0, 65)}…' : title,
      messages: List.from(_messages),
      createdAt: _conversationStartedAt,
      modelId: _selectedModel,
    );
    await HistoryService().saveConversation(conv);
  }

  // ─── Iniciar nova conversa ───────────────────────────────────────────────────
  Future<void> startNewChat() async {
    _messages = [];
    _errorMessage = '';
    _currentConversationId = _newId();
    _conversationStartedAt = DateTime.now();
    notifyListeners();
  }

  // ─── Carregar conversa do histórico ─────────────────────────────────────────
  Future<void> loadConversation(ConversationModel conv) async {
    _messages = List.from(conv.messages);
    _currentConversationId = conv.id;
    _conversationStartedAt = conv.createdAt;
    final modelExists =
        GroqModel.available.any((m) => m.id == conv.modelId);
    if (modelExists) _selectedModel = conv.modelId;
    _errorMessage = '';
    notifyListeners();
  }

  // ─── Remover API key (volta para a chave padrão embutida) ────────────────────
  Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('groq_api_key');
    _apiKey = AppConfig.defaultApiKey; // ← volta para o padrão embutido
    notifyListeners();
  }

  // ─── Limpar mensagens ────────────────────────────────────────────────────────
  void clearMessages() {
    _messages = [];
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _groqService.dispose();
    super.dispose();
  }
}

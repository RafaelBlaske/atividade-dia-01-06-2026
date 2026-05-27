import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';

class GroqException implements Exception {
  final String message;
  final int? statusCode;

  GroqException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class GroqService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  static const Duration _timeout = Duration(seconds: 30);

  final http.Client _client;

  GroqService({http.Client? client}) : _client = client ?? http.Client();

  // ─── POST: Enviar mensagens e receber resposta da IA ────────────────────────
  Future<String> sendMessage({
    required String apiKey,
    required String model,
    required List<Message> messages,
    double temperature = 0.7,
    int maxTokens = 1024,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw GroqException('API Key não configurada. Vá em Configurações.');
    }

    try {
      final uri = Uri.parse('$_baseUrl/chat/completions');

      // Monta o histórico de mensagens no formato da API
      final List<Map<String, dynamic>> apiMessages = [
        // System prompt inicial
        {
          'role': 'system',
          'content':
              'Você é um assistente inteligente e prestativo. Responda sempre em português do Brasil de forma clara e objetiva.',
        },
        // Histórico da conversa
        ...messages.map((m) => m.toApiJson()),
      ];

      final body = json.encode({
        'model': model,
        'messages': apiMessages,
        'temperature': temperature,
        'max_tokens': maxTokens,
        'stream': false,
      });

      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey', // <-- sua chave vai aqui
            },
            body: body,
          )
          .timeout(_timeout);

      _validateResponse(response);

      final data = json.decode(response.body);
      final content = data['choices'][0]['message']['content'] as String;
      return content.trim();
    } on SocketException {
      throw GroqException('Sem conexão com a internet.');
    } on GroqException {
      rethrow;
    } catch (e) {
      throw GroqException('Erro inesperado: $e');
    }
  }

  // ─── GET: Listar modelos disponíveis (leitura de dados) ─────────────────────
  Future<List<String>> fetchAvailableModels(String apiKey) async {
    if (apiKey.trim().isEmpty) throw GroqException('API Key não configurada.');

    try {
      final uri = Uri.parse('$_baseUrl/models');
      final response = await _client.get(
        uri,
        headers: {'Authorization': 'Bearer $apiKey'},
      ).timeout(_timeout);

      _validateResponse(response);

      final data = json.decode(response.body);
      final models = (data['data'] as List)
          .map((m) => m['id'] as String)
          .toList();
      return models;
    } on SocketException {
      throw GroqException('Sem conexão com a internet.');
    } on GroqException {
      rethrow;
    } catch (e) {
      throw GroqException('Erro ao buscar modelos: $e');
    }
  }

  void _validateResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) return;

    String msg;
    try {
      final data = json.decode(response.body);
      msg = data['error']?['message'] ?? response.reasonPhrase ?? 'Erro';
    } catch (_) {
      msg = response.reasonPhrase ?? 'Erro ${response.statusCode}';
    }

    switch (response.statusCode) {
      case 401:
        throw GroqException('API Key inválida. Verifique em Configurações.',
            statusCode: 401);
      case 429:
        throw GroqException('Limite de requisições atingido. Aguarde um momento.',
            statusCode: 429);
      case 503:
        throw GroqException('Serviço Groq indisponível. Tente novamente.',
            statusCode: 503);
      default:
        throw GroqException(msg, statusCode: response.statusCode);
    }
  }

  void dispose() => _client.close();
}

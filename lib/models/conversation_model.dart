import 'message_model.dart';

class ConversationModel {
  final String id;
  final String title;      // Primeira mensagem do usuário (truncada)
  final List<Message> messages;
  final DateTime createdAt;
  final String modelId;
  bool isFavorite;

  ConversationModel({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.modelId,
    this.isFavorite = false,
  });

  int get messageCount => messages.length;

  /// Quantas trocas completas (usuário + IA)
  int get exchangeCount =>
      messages.where((m) => m.role == MessageRole.user).length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'messages': messages.map((m) => m.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'modelId': modelId,
    'isFavorite': isFavorite,
  };

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      ConversationModel(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        messages: (json['messages'] as List? ?? [])
            .map((m) => Message.fromJson(m as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt']),
        modelId: json['modelId'] ?? '',
        isFavorite: json['isFavorite'] ?? false,
      );
}

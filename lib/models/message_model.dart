enum MessageRole { user, assistant, system }

class Message {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime createdAt;
  final bool isError;

  Message({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.isError = false,
  });

  // Serialização completa (para salvar no histórico local)
  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role.name,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'isError': isError,
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
    role: MessageRole.values.firstWhere(
      (r) => r.name == json['role'],
      orElse: () => MessageRole.user,
    ),
    content: json['content'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
    isError: json['isError'] ?? false,
  );

  // Converte para o formato que a API do Groq espera
  Map<String, dynamic> toApiJson() => {
    'role': role.name,
    'content': content,
  };

  factory Message.user(String content) => Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.user,
        content: content,
        createdAt: DateTime.now(),
      );

  factory Message.assistant(String content, {bool isError = false}) => Message(
        id: '${DateTime.now().millisecondsSinceEpoch}_ai',
        role: MessageRole.assistant,
        content: content,
        createdAt: DateTime.now(),
        isError: isError,
      );
}

// Modelos disponíveis no Groq
class GroqModel {
  final String id;
  final String name;
  final String description;

  const GroqModel({
    required this.id,
    required this.name,
    required this.description,
  });

  static const List<GroqModel> available = [
    GroqModel(
      id: 'llama-3.3-70b-versatile',
      name: 'Llama 3.3 70B',
      description: 'Mais capaz, respostas detalhadas',
    ),
    GroqModel(
      id: 'llama-3.1-8b-instant',
      name: 'Llama 3.1 8B',
      description: 'Mais rápido, ideal para chat',
    ),
  ];
}

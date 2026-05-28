# 🤖 ChatGroq

Aplicativo de chat com inteligência artificial desenvolvido em **Flutter**, integrado à **API do Groq** para respostas ultra-rápidas via modelos LLM como Llama 3.

---

## ✨ Funcionalidades

- 💬 Chat em tempo real com modelos de IA via API Groq
- 🧠 Suporte a múltiplos modelos (Llama 3.3 70B e Llama 3.1 8B)
- 🎛️ Configuração de temperatura (criatividade das respostas)
- 🔑 Gerenciamento de API Key (salva localmente com `shared_preferences`)
- 📜 Histórico de conversas com busca e favoritos
- 🌙 Tema dark com identidade visual do Groq
- 📱 Interface responsiva, orientação portrait

---

## 📋 Pré-requisitos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) `>=3.10.0`
- Dart SDK `>=3.0.0 <4.0.0`
- Uma chave de API do Groq (veja a seção abaixo)

---

## 🔑 Obtendo a API Key do Groq

1. Acesse [console.groq.com](https://console.groq.com) e faça login (gratuito)
2. Vá em **API Keys** → **Create API Key**
3. Copie a chave gerada — ela começa com `gsk_...`
4. Cole a chave no arquivo `lib/config/app_config.dart`:

```dart
class AppConfig {
  static const String defaultApiKey = 'gsk_SUA_CHAVE_AQUI';
}
```

> Alternativamente, você pode inserir a chave diretamente pela tela de **Configurações** dentro do app após rodá-lo.

---

## 🚀 Como rodar

```bash
# 1. Clone ou extraia o projeto e entre na pasta
cd atividade-dia-01-06-2026-main

# 2. Instale as dependências
flutter pub get

# 3. Rode no dispositivo/emulador conectado
flutter run
```

Para rodar em uma plataforma específica:

```bash
flutter run -d android   # Android
flutter run -d ios       # iOS
flutter run -d chrome    # Web
flutter run -d windows   # Windows
flutter run -d linux     # Linux
flutter run -d macos     # macOS
```

---

## 📁 Estrutura do projeto

```
lib/
├── main.dart                          # Ponto de entrada, inicialização e tema
├── create/
│   └── app_config.dart                # Chave de API padrão embutida
├── models/
│   ├── message_model.dart             # Modelo de mensagem, roles e lista de modelos Groq
│   └── conversation_model.dart        # Modelo de conversa para o histórico
├── services/
│   ├── groq_service.dart              # Integração com a API Groq (POST /chat/completions, GET /models)
│   └── history_service.dart           # Persistência local do histórico de conversas
├── providers/
│   └── chat_provider.dart             # Gerenciamento de estado com ChangeNotifier
├── screens/
│   ├── chat_screen.dart               # Tela principal do chat
│   ├── settings_screen.dart           # Tela de configurações (API Key, modelo, temperatura)
│   ├── history_screen.dart            # Tela de histórico com busca e abas
│   └── conversation_detail_screen.dart # Visualização de conversa salva
├── widgets/
│   ├── message_bubble.dart            # Balão de mensagem + indicador de digitação
│   └── chat_input.dart                # Campo de entrada de texto
└── theme/
    └── app_theme.dart                 # Tema dark com cores do Groq
```

---

## 🌐 API Groq utilizada

Base URL: `https://api.groq.com/openai/v1`

| Operação | Método | Endpoint | Descrição |
|----------|--------|----------|-----------|
| Enviar mensagem | `POST` | `/chat/completions` | Envia o histórico e recebe a resposta da IA |
| Listar modelos | `GET` | `/models` | Retorna os modelos disponíveis na conta |

**Cabeçalhos obrigatórios:**

```
Authorization: Bearer gsk_SUA_CHAVE_AQUI
Content-Type: application/json
```

**Modelos disponíveis no app:**

| ID | Nome | Descrição |
|----|------|-----------|
| `llama-3.3-70b-versatile` | Llama 3.3 70B | Mais capaz, respostas detalhadas |
| `llama-3.1-8b-instant` | Llama 3.1 8B | Mais rápido, ideal para chat |

---

## 📦 Dependências

| Pacote | Versão | Uso |
|--------|--------|-----|
| `http` | ^1.2.1 | Requisições HTTP à API Groq |
| `provider` | ^6.1.2 | Gerenciamento de estado |
| `shared_preferences` | ^2.3.2 | Persistência local da API Key e preferências |
| `google_fonts` | ^6.2.1 | Tipografia Inter |
| `intl` | ^0.19.0 | Formatação de data/hora nas mensagens |
| `cupertino_icons` | ^1.0.6 | Ícones estilo iOS |

---

## 🏗️ Arquitetura

O projeto segue o padrão **Provider** para gerenciamento de estado:

```
ChatScreen / SettingsScreen / HistoryScreen
        │
        ▼
   ChatProvider  (ChangeNotifier)
        │
        ├── GroqService      → API Groq (HTTP)
        └── HistoryService   → SharedPreferences (persistência local)
```

O `ChatProvider` é inicializado antes da renderização do app (`main.dart`) para evitar o flash da tela de "chave não configurada" ao abrir.

---

## ⚠️ Tratamento de erros

O `GroqService` trata os principais erros da API:

| Código HTTP | Mensagem exibida |
|-------------|-----------------|
| `401` | API Key inválida — verificar em Configurações |
| `429` | Limite de requisições atingido — aguardar |
| `503` | Serviço Groq indisponível — tentar novamente |
| Sem conexão | Sem conexão com a internet |

---

## 🧪 Testes

```bash
flutter test
```

O arquivo `test/widget_test.dart` contém os testes de widget básicos do app.

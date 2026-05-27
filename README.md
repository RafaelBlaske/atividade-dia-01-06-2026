# 🤖 ChatGroq — Chat com IA via API Groq

App Flutter de chat com inteligência artificial usando a API do Groq,
com suporte a múltiplos modelos (Llama, Mixtral, Gemma).

---

## 🚀 Como rodar

```bash
# 1. Extraia o zip e entre na pasta
cd chatgroq

# 2. Instale as dependências
flutter pub get

# 3. Rode no emulador
flutter run
```

---

## 🔑 Configurar a API Key do Groq

1. Acesse **https://console.groq.com**
2. Faça login (gratuito)
3. Clique em **API Keys** → **Create API Key**
4. Copie a chave (começa com `gsk_...`)
5. No app, toque em **⚙️ Configurações**
6. Cole a chave no campo **API Key** e salve

A chave fica salva localmente no dispositivo via `SharedPreferences`.

---

## 📁 Estrutura

```
lib/
├── main.dart
├── models/
│   └── message_model.dart      # Modelo de mensagem + lista de modelos Groq
├── services/
│   └── groq_service.dart       # POST /chat/completions | GET /models
├── providers/
│   └── chat_provider.dart      # Estado + SharedPreferences (inserção/leitura)
├── screens/
│   ├── chat_screen.dart        # Tela principal do chat
│   └── settings_screen.dart    # Tela de configuração da API Key
├── widgets/
│   ├── message_bubble.dart     # Balão de mensagem + TypingIndicator
│   └── chat_input.dart         # Campo de entrada de texto
└── theme/
    └── app_theme.dart          # Tema dark com cores Groq
```

---

## 🌐 API Groq utilizada

| Operação | Método | Endpoint | Descrição |
|----------|--------|----------|-----------|
| **Inserção** | `POST` | `/chat/completions` | Envia mensagem e recebe resposta |
| **Leitura** | `GET` | `/models` | Lista modelos disponíveis |

**Cabeçalho obrigatório:**
```
Authorization: Bearer gsk_SUA_CHAVE_AQUI
Content-Type: application/json
```

---

## 📦 Dependências

| Pacote | Uso |
|--------|-----|
| `http` | Requisições HTTP à API Groq |
| `provider` | Gerenciamento de estado |
| `shared_preferences` | Salvar API Key e preferências localmente |
| `google_fonts` | Tipografia Inter |
| `intl` | Formatação de hora nas mensagens |

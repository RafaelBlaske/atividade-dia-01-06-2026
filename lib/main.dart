import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'screens/chat_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega a API key salva ANTES de renderizar o app,
  // evitando a tela de "chave não configurada" logo ao abrir.
  final chatProvider = ChatProvider();
  await chatProvider.loadPreferences();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bg,
    ),
  );

  runApp(ChatGroqApp(chatProvider: chatProvider));
}

class ChatGroqApp extends StatelessWidget {
  final ChatProvider chatProvider;

  const ChatGroqApp({super.key, required this.chatProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: chatProvider),
      ],
      child: MaterialApp(
        title: 'ChatGroq',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const ChatScreen(),
      ),
    );
  }
}

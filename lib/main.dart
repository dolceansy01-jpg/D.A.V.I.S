import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF050914),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const DavisApp());
}

class DavisApp extends StatelessWidget {
  const DavisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D.A.V.I.S. ULTRA JARVIS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050914),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D9FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const DavisHomePage(),
    );
  }
}

class DavisHomePage extends StatefulWidget {
  const DavisHomePage({super.key});

  @override
  State<DavisHomePage> createState() => _DavisHomePageState();
}

class _DavisHomePageState extends State<DavisHomePage> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, String>> _messages = [];

  bool _loading = false;

  void _sendMessage() {
    final message = _controller.text.trim();

    if (message.isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'text': message,
      });

      _messages.add({
        'role': 'assistant',
        'text':
            'Bonjour Kim Dolce ! Je suis D.A.V.I.S. '
            'Mon interface est prête. Mon intelligence artificielle '
            'doit encore être connectée à un serveur.',
      });

      _controller.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF080F20),
        title: const Row(
          children: [
            Icon(
              Icons.memory,
              color: Color(0xFF00D9FF),
              size: 32,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'D.A.V.I.S.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'ULTRA JARVIS AI',
                  style: TextStyle(
                    color: Color(0xFF00D9FF),
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 35),

          Container(
            width: 145,
            height: 145,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF00D9FF),
                  Color(0xFF174BFF),
                  Color(0xFF9A4DFF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D9FF)
                      .withValues(alpha: 0.30),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.graphic_eq,
              size: 75,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'BONJOUR, KIM DOLCE',
            style: TextStyle(
              color: Color(0xFF00D9FF),
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Votre assistant personnel',
            style: TextStyle(color: Colors.white60),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(
                      maxWidth:
                          MediaQuery.of(context).size.width * 0.82,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF123A60)
                          : const Color(0xFF111B2D),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF00D9FF)
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(message['text'] ?? ''),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Écrivez à D.A.V.I.S...',
                        filled: true,
                        fillColor: const Color(0xFF111B2D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF00A9E8),
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

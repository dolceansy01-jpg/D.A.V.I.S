import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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
  static const String serverUrl =
      'https://d-a-v-i-s.onrender.com/chat';

  final TextEditingController _controller =
      TextEditingController();

  final ScrollController _scrollController =
      ScrollController();

  final List<Map<String, String>> _messages = [];

  bool _loading = false;

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();

    if (message.isEmpty || _loading) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'text': message,
      });

      _loading = true;
      _controller.clear();
    });

    _scrollToBottom();

    try {
      final response = await http
          .post(
            Uri.parse(serverUrl),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'message': message,
            }),
          )
          .timeout(const Duration(seconds: 90));

      final dynamic decoded = jsonDecode(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decoded is Map &&
          decoded['reply'] is String) {
        if (!mounted) return;

        setState(() {
          _messages.add({
            'role': 'assistant',
            'text': decoded['reply'] as String,
          });
        });
      } else {
        final errorMessage =
            decoded is Map && decoded['error'] is String
                ? decoded['error'] as String
                : 'Le serveur a renvoyé une réponse inattendue.';

        _addError(errorMessage);
      }
    } catch (e) {
      _addError(
        'Impossible de contacter D.A.V.I.S. '
        'Vérifie ta connexion Internet et réessaie.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });

        _scrollToBottom();
      }
    }
  }

  void _addError(String message) {
    if (!mounted) return;

    setState(() {
      _messages.add({
        'role': 'assistant',
        'text': message,
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
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
          const SizedBox(height: 25),

          Container(
            width: 125,
            height: 125,
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
              size: 65,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'BONJOUR, KIM DOLCE',
            style: TextStyle(
              color: Color(0xFF00D9FF),
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Votre assistant personnel',
            style: TextStyle(color: Colors.white60),
          ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_loading && index == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF00D9FF),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'D.A.V.I.S. réfléchit...',
                            style: TextStyle(
                              color: Color(0xFF00D9FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final item = _messages[index];
                final isUser = item['role'] == 'user';

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
                    child: Text(item['text'] ?? ''),
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
                      enabled: !_loading,
                      textInputAction: TextInputAction.send,
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
                      onPressed: _loading ? null : _sendMessage,
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

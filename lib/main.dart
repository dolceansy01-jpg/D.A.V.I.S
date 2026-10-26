import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
WidgetsFlutterBinding.ensureInitialized();
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

final TextEditingController _controller = TextEditingController();
final ScrollController _scrollController = ScrollController();
final FlutterTts _tts = FlutterTts();
final stt.SpeechToText _speech = stt.SpeechToText();

final List<Map<String, String>> _messages = [];

bool _isLoading = false;
bool _isListening = false;
bool _voiceEnabled = true;
bool _speechAvailable = false;

@override
void initState() {
super.initState();
_initializeVoice();
}

Future<void> _initializeVoice() async {
try {
await _tts.setLanguage('fr-FR');
await _tts.setSpeechRate(0.45);
await _tts.setVolume(1.0);
await _tts.setPitch(1.0);

  _speechAvailable = await _speech.initialize(
    onStatus: (status) {
      if (status == 'done' || status == 'notListening') {
        if (mounted) {
          setState(() => _isListening = false);
        }
      }
    },
    onError: (error) {
      if (mounted) {
        setState(() => _isListening = false);
      }
    },
  );

  if (mounted) setState(() {});
} catch (e) {
  debugPrint('Voice initialization error: $e');
}

}

Future<void> _speak(String text) async {
if (!_voiceEnabled || text.trim().isEmpty) return;

try {
  await _tts.stop();
  await _tts.setLanguage('fr-FR');
  await _tts.setSpeechRate(0.45);
  await _tts.speak(text);
} catch (e) {
  debugPrint('Text-to-speech error: $e');
}

}

Future<void> _testVoice() async {
await _speak(
'Bonjour Kim Dolce. Je suis D.A.V.I.S., '
'votre assistant personnel. Je suis prêt à vous aider.',
);
}

Future<void> _toggleListening() async {
if (_isLoading) return;

if (_isListening) {
  await _speech.stop();
  if (mounted) setState(() => _isListening = false);
  return;
}

if (!_speechAvailable) {
  await _initializeVoice();
}

if (!_speechAvailable) {
  _showMessage(
    'Le microphone n’est pas disponible. Vérifiez les permissions '
    'et la reconnaissance vocale de votre téléphone.',
  );
  return;
}

try {
  await _tts.stop();

  await _speech.listen(
    onResult: (result) {
      if (!mounted) return;

      setState(() {
        _controller.text = result.recognizedWords;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      });

      if (result.finalResult) {
        setState(() => _isListening = false);
      }
    },
    localeId: 'fr_FR',
    listenFor: const Duration(seconds: 45),
    pauseFor: const Duration(seconds: 4),
  );

  if (mounted) setState(() => _isListening = true);
} catch (e) {
  _showMessage('Impossible de démarrer le microphone : $e');
}

}

Future<void> _sendMessage() async {
final String message = _controller.text.trim();

if (message.isEmpty || _isLoading) return;

FocusScope.of(context).unfocus();

setState(() {
  _messages.add({'role': 'user', 'text': message});
  _controller.clear();
  _isLoading = true;
});

_scrollToBottom();

try {
  final response = await http
      .post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      )
      .timeout(const Duration(seconds: 90));

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception('Erreur serveur HTTP ${response.statusCode}');
  }

  final dynamic decoded = jsonDecode(response.body);

  if (decoded is! Map<String, dynamic>) {
    throw Exception('Réponse du serveur invalide.');
  }

  final String answer =
      (decoded['reply'] ?? decoded['message'] ?? '').toString().trim();

  if (answer.isEmpty) {
    throw Exception('D.A.V.I.S. n’a reçu aucune réponse.');
  }

  if (!mounted) return;

  setState(() {
    _messages.add({'role': 'assistant', 'text': answer});
  });

  _scrollToBottom();

  await _speak(answer);
} on TimeoutException {
  _showMessage(
    'Le serveur met trop de temps à répondre. Réessayez dans un instant.',
  );
} catch (e) {
  _showMessage(
    'Impossible de contacter D.A.V.I.S. '
    'Vérifiez Internet et le serveur. Détail : $e',
  );
} finally {
  if (mounted) setState(() => _isLoading = false);
}

}

void _showMessage(String message) {
if (!mounted) return;

setState(() {
  _messages.add({'role': 'assistant', 'text': message});
});

_scrollToBottom();

}

void scrollToBottom() {
WidgetsBinding.instance.addPostFrameCallback(() {
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
_tts.stop();
_speech.stop();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
backgroundColor: const Color(0xFF091426),
title: const Column(
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
'ULTRA JARVIS • AI ASSISTANT',
style: TextStyle(fontSize: 10, color: Color(0xFF00D9FF)),
),
],
),
actions: [
IconButton(
tooltip: _voiceEnabled ? 'Désactiver la voix' : 'Activer la voix',
onPressed: () async {
setState(() => _voiceEnabled = !_voiceEnabled);
if (!_voiceEnabled) await _tts.stop();
if (_voiceEnabled) await _testVoice();
},
icon: Icon(
_voiceEnabled ? Icons.volume_up : Icons.volume_off,
color: const Color(0xFF00D9FF),
),
),
IconButton(
tooltip: 'Tester la voix',
onPressed: _testVoice,
icon: const Icon(
Icons.record_voice_over,
color: Color(0xFF00D9FF),
),
),
],
),
body: SafeArea(
child: Column(
children: [
const SizedBox(height: 18),
Container(
width: 112,
height: 112,
decoration: BoxDecoration(
shape: BoxShape.circle,
color: const Color(0xFF071D32),
border: Border.all(
color: const Color(0xFF00D9FF),
width: 2,
),
boxShadow: [
BoxShadow(
color: const Color(0xFF00D9FF).withValues(alpha: 0.22),
blurRadius: 30,
spreadRadius: 4,
),
],
),
child: const Icon(
Icons.memory,
size: 62,
color: Color(0xFF00D9FF),
),
),
const SizedBox(height: 12),
const Text(
'D.A.V.I.S. ULTRA JARVIS',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
letterSpacing: 1.2,
),
),
const SizedBox(height: 5),
Text(
_isListening
? 'MICROPHONE ACTIF • PARLEZ'
: _isLoading
? 'D.A.V.I.S. RÉFLÉCHIT...'
: 'VOTRE ASSISTANT PERSONNEL',
style: const TextStyle(
color: Color(0xFF00D9FF),
fontSize: 11,
letterSpacing: 1,
),
),
const SizedBox(height: 12),
Padding(
padding: const EdgeInsets.symmetric(horizontal: 18),
child: Row(
children: [
Expanded(
child: OutlinedButton.icon(
onPressed: _testVoice,
icon: const Icon(Icons.volume_up),
label: const Text('TESTER LA VOIX'),
),
),
const SizedBox(width: 10),
Expanded(
child: OutlinedButton.icon(
onPressed: _toggleListening,
icon: Icon(
_isListening ? Icons.mic_off : Icons.mic,
),
label: Text(
_isListening ? 'ARRÊTER' : 'PARLER',
),
),
),
],
),
),
const Divider(height: 24, color: Color(0xFF1A3048)),
Expanded(
child: _messages.isEmpty
? Center(
child: Padding(
padding: const EdgeInsets.all(28),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
const Icon(
Icons.auto_awesome,
size: 42,
color: Color(0xFF00D9FF),
),
const SizedBox(height: 14),
const Text(
'Bonjour, Kim Dolce.',
style: TextStyle(
fontSize: 21,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 8),
Text(
'Je suis D.A.V.I.S. Que puis-je faire pour vous ?',
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.white.withValues(alpha: 0.65),
),
),
],
),
),
)
: ListView.builder(
controller: _scrollController,
padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
itemCount: _messages.length,
itemBuilder: (context, index) {
final item = _messages[index];
final bool isUser = item['role'] == 'user';

                    return Align(
                      alignment: isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.84,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isUser
                              ? const Color(0xFF10354A)
                              : const Color(0xFF101A2B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isUser
                                ? const Color(0xFF00D9FF)
                                    .withValues(alpha: 0.35)
                                : const Color(0xFF26374D),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUser ? 'KIM DOLCE' : 'D.A.V.I.S.',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00D9FF),
                              ),
                            ),
                            const SizedBox(height: 6),
                            SelectableText(
                              item['text'] ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.45,
                              ),
                            ),
                            if (!isUser)
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  tooltip: 'Écouter la réponse',
                                  onPressed: () => _speak(
                                    item['text'] ?? '',
                                  ),
                                  icon: const Icon(
                                    Icons.volume_up,
                                    size: 19,
                                    color: Color(0xFF00D9FF),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text('D.A.V.I.S. prépare sa réponse...'),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: const BoxDecoration(
            color: Color(0xFF091426),
            border: Border(
              top: BorderSide(color: Color(0xFF1A3048)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                tooltip: _isListening
                    ? 'Arrêter le microphone'
                    : 'Parler',
                onPressed: _toggleListening,
                icon: Icon(
                  _isListening ? Icons.mic_off : Icons.mic,
                  color: const Color(0xFF00D9FF),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: _isListening
                        ? 'Je vous écoute...'
                        : 'Écrivez à D.A.V.I.S....',
                    filled: true,
                    fillColor: const Color(0xFF101A2B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Envoyer',
                onPressed: _isLoading ? null : _sendMessage,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);

}
}

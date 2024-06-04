import 'package:app_mm_v3/src/add.dart';
import 'package:app_mm_v3/views/home_page.dart';
import 'package:app_mm_v3/views/user_page.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class TextChatPage extends StatefulWidget {
  const TextChatPage({Key? key}) : super(key: key);

  @override
  State<TextChatPage> createState() => _TextChatPageState();
}

class _TextChatPageState extends State<TextChatPage> {
  late final GenerativeModel geminiModel;
  var loading = false;
  var messages = <ChatMessage>[];
  var chatHistory = <Content>[];
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    geminiModel = GenerativeModel(
      model: 'gemini-1.0-pro',
      apiKey: 'AIzaSyASJpDWFpmKHNSdMRgtmIy49g_KlZ9phdc', // Substitua pela sua chave de API
    );
  }

  void addMessage(String message, bool isUserMessage) {
    setState(() {
      messages.insert(0, ChatMessage(message: message, isUser: isUserMessage));
      chatHistory.add(Content.text(message));
    });
  }

  void _sendMessage() async {
    final message = _messageController.text;
    if (message.isEmpty) return;

    addMessage(message, true); // Adiciona a mensagem do usuário ao histórico
    _messageController.clear();

    setState(() {
      loading = true;
    });

    // Passa todo o histórico de mensagens para o modelo
    final result = await geminiModel.generateContent(chatHistory);

    if (result.text != null) {
      addMessage(result.text!, false); // Adiciona a resposta ao histórico
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagem substituindo o AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3, // Ajuste a altura conforme necessário
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/nav.png"), // Substitua pelo caminho da sua imagem
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.3, // Ajuste o preenchimento conforme necessário
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true, // Para exibir as mensagens de baixo para cima
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final chatMessage = messages[index];
                      final isUserMessage = chatMessage.isUser;
                      return Align(
                        alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isUserMessage)
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: AssetImage("assets/images/icon2.jpg"), // Substitua pelo caminho da sua imagem
                              ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isUserMessage ? Color(0xFF3F8782) : Color(0xFF734B9B),
                                  borderRadius: BorderRadius.circular(20), // Arredondar todas as bordas
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  chatMessage.message,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            if (isUserMessage)
                              SizedBox(width: 8),
                            if (isUserMessage)
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: AssetImage("assets/images/user.png"), // Substitua pelo caminho da sua imagem
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (loading)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Digite sua mensagem...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10), // Arredonda todas as bordas
                            ),
                            filled: true,
                            fillColor: Colors.green.shade50,
                          ),
                        ),
                      ),
                      SizedBox(width: 8), // Removido o "const" aqui
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF734B9B), Color(0xFF3F8782)],
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                          ),
                        ),
                        child: FloatingActionButton(
                          onPressed: _sendMessage,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          child: Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.07,
                  color: const Color(0xFF3F8782),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.home),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddTransactionPage(),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.account_circle),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserProfilePage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String message;
  final bool isUser;

  ChatMessage({required this.message, required this.isUser});
}

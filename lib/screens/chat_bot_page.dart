import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl/intl.dart';
import 'package:gift_shop/APIs/chat_bot_api.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChatHistory();
    _addInitialGreetings();
  }

  void _addInitialGreetings()async {
    await _playMessageSound();
    Future.delayed(const Duration(milliseconds: 500), () {
      final hour = DateTime.now().hour;
      String greeting = hour < 12
          ? "Good Morning!"
          : hour < 17
              ? "Good Afternoon!"
              : "Good Evening!";

      setState((){
        _messages.add({
          "text": "Hello! $greeting",
          "isReceived": true,
          "timestamp": DateTime.now().toIso8601String()
        });
        _messages.add({
          "text": "How can I help you today?",
          "isReceived": true,
          "timestamp": DateTime.now().toIso8601String()
        });
      });
    });
  }

  Future<void> _fetchChatHistory() async {
    try {
      final chatHistory = await getChatbotApi();
      setState(() {
        _messages.clear();
        _messages.addAll(chatHistory.map((msg) {
          return {
            'text': msg['message'] ?? '',
            'isReceived': msg['sender'] == 'bot',
            'timestamp': msg['timestamp']
          };
        }).toList());
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching chat history: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load chat history: $e')),
      );
    }
  }

  void _addMessage(String text, {required bool isReceived}) async {
    setState(() {
      _messages.add({
        "text": text, 
        "isReceived": isReceived,
        "timestamp": DateTime.now().toIso8601String()
      });
    });
    await _playMessageSound();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _addMessage(text, isReceived: false);
      _messageController.clear();

      try {
        final chatResponse = await callChatbotApi(text); 
        final answer = chatResponse['bot_response'];
        _addMessage(answer, isReceived: true);
      } catch (e) {
        print('Error: $e');
        _addMessage('Failed to fetch chatbot response', isReceived: true);
      }
    }
  }

  Future<void> _playMessageSound() async {
    await _audioPlayer.play(AssetSource('tick.mp3'));
  }

  void _clearChatBotMessages() async {
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue,
                Color.fromRGBO(187, 222, 251, 1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        title: const Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage("assets/prof.gif"),
            ),
            SizedBox(width: 10),
            Text(
              "Chat Bot",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _clearChatBotMessages();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'clear',
                  child: Text("Clear Chat Bot"),
                ),
              ];
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(10),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[_messages.length - 1 - index];
                      return Column(
                        crossAxisAlignment: message['isReceived'] 
                            ? CrossAxisAlignment.start 
                            : CrossAxisAlignment.end,
                        children: [
                          _buildMessageBubble(
                            message["text"], 
                            message["isReceived"]
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Text(
                              _formatTimestamp(message["timestamp"]),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return DateFormat('MMM d, hh:mm a').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  Widget _buildMessageBubble(String message, bool isReceived) {
    return Align(
      alignment: isReceived ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isReceived ? Colors.grey[300] : Colors.blueAccent,
          borderRadius: BorderRadius.circular(12).copyWith(
            bottomLeft: isReceived ? Radius.zero : const Radius.circular(12),
            bottomRight: isReceived ? const Radius.circular(12) : Radius.zero,
          ),
        ),
        child: Text(
          message,
          style: TextStyle(color: isReceived ? Colors.black87 : Colors.white),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration.collapsed(
                hintText: "Type a message...",
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
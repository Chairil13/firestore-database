import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login/google/google_auth.dart';
import 'widgets/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final model = GenerativeModel(
      model: 'gemini-pro', apiKey: 'AIzaSyCemWq4HMckBt9903Ug6bunb2AQ7kJ0gC8');
  final messageController = TextEditingController();
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  List<ChatBubble> messages = [];

  @override
  void initState() {
    super.initState();
    loadChatHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    try {
      final firebaseServices = FirebaseServices();
      await firebaseServices.googleSignOut();
      if (mounted) {
        await Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal logout: ${e.toString()}')),
        );
      }
    }
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

  Future<void> loadChatHistory() async {
    if (_auth.currentUser == null) return;

    try {
      final snapshot = await _firestore
          .collection('text_chats')
          .doc(_auth.currentUser!.uid)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .get();

      final loadedMessages = snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatBubble(
          direction: data['isUser'] ? Direction.right : Direction.left,
          message: data['message'],
          photoUrl: data['isUser'] ? null : 'https://i.pravatar.cc/150?img=47',
          type: BubbleType.alone,
        );
      }).toList();

      setState(() {
        if (loadedMessages.isEmpty) {
          // Add welcome message if chat is empty
          final userEmail = _auth.currentUser?.email ?? 'User';
          messages = [
            ChatBubble(
              direction: Direction.left,
              message:
                  'Halo selamat datang $userEmail, ada yang bisa saya bantu?',
              photoUrl: 'https://i.pravatar.cc/150?img=47',
              type: BubbleType.alone,
            ),
          ];
          // Save welcome message to Firestore
          saveMessage(
              'Halo selamat datang $userEmail, ada yang bisa saya bantu?',
              false);
        } else {
          messages = loadedMessages;
        }
      });
    } catch (e) {
      debugPrint('Error loading chat history: $e');
    }
  }

  Future<void> saveMessage(String message, bool isUser) async {
    if (_auth.currentUser == null) return;

    try {
      await _firestore
          .collection('text_chats')
          .doc(_auth.currentUser!.uid)
          .collection('messages')
          .add({
        'message': message,
        'isUser': isUser,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving message: $e');
    }
  }

  Future<void> deleteAllMessages() async {
    if (_auth.currentUser == null) return;

    try {
      // Get all messages
      final snapshot = await _firestore
          .collection('text_chats')
          .doc(_auth.currentUser!.uid)
          .collection('messages')
          .get();

      // Delete each message
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // Reset local messages state and add welcome message
      setState(() {
        final userEmail = _auth.currentUser?.email ?? 'User';
        messages = [
          ChatBubble(
            direction: Direction.left,
            message:
                'Halo selamat datang $userEmail, ada yang bisa saya bantu?',
            photoUrl: 'https://i.pravatar.cc/150?img=47',
            type: BubbleType.alone,
          ),
        ];
      });
      // Save welcome message to Firestore
      saveMessage(
          'Halo selamat datang ${_auth.currentUser?.email ?? "User"}, ada yang bisa saya bantu?',
          false);
    } catch (e) {
      debugPrint('Error deleting messages: $e');
    }
  }

  void sendMessage() async {
    if (messageController.text.isEmpty) return;
    setState(() => isLoading = true);

    final userMessage = messageController.text;
    final userChatBubble = ChatBubble(
      direction: Direction.right,
      message: userMessage,
      type: BubbleType.alone,
    );

    setState(() {
      messages.add(userChatBubble);
    });
    _scrollToBottom();

    // Save user message
    await saveMessage(userMessage, true);

    try {
      final response = await model.generateContent([Content.text(userMessage)]);
      final aiMessage = response.text ?? 'Tidak dapat memproses pesan';

      final aiChatBubble = ChatBubble(
        direction: Direction.left,
        message: aiMessage,
        photoUrl: 'https://i.pravatar.cc/150?img=47',
        type: BubbleType.alone,
      );

      setState(() {
        messages.add(aiChatBubble);
        isLoading = false;
      });
      _scrollToBottom();

      // Save AI response
      await saveMessage(aiMessage, false);
    } catch (error) {
      const errorChatBubble = ChatBubble(
        direction: Direction.left,
        message: 'Terjadi kesalahan',
        photoUrl: 'https://i.pravatar.cc/150?img=47',
        type: BubbleType.alone,
      );

      setState(() {
        messages.add(errorChatBubble);
        isLoading = false;
      });
      _scrollToBottom();

      // Save error message
      await saveMessage('Terjadi kesalahan', false);
    }

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Gemini AI ✨',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus Chat'),
                  content: const Text(
                      'Apakah Anda yakin ingin menghapus semua pesan?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        deleteAllMessages();
                        Navigator.pop(context);
                      },
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Hapus Chat',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleLogout();
                      },
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.all(10),
              children: messages.toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration:
                        const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : IconButton(
                        icon: const Icon(Icons.send), onPressed: sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

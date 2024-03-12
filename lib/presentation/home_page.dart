import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:websocket_chatroom/providers/auth_provider.dart';

import '../providers/messages_provider.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime Chat App'),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: Provider.of<MessagesProvider>(context).messages.length,
              itemBuilder: (context, index) {
                final message =
                    Provider.of<MessagesProvider>(context).messages[index];
                return BubbleSpecialThree(
                  text: message.content,
                  isSender: message.user.id ==
                      Provider.of<AuthProvider>(context).user?.id,
                  color: message.user.id ==
                          Provider.of<AuthProvider>(context).user?.id
                      ? const Color(0xffFFD700)
                      : const Color(0xffE0E0E0),
                );
              },
            ),
          ),
          TextField(
            onSubmitted: (value) {
              Provider.of<MessagesProvider>(context, listen: false)
                  .sendMessage(value);
            },
            decoration: const InputDecoration(
              labelText: 'Type a message',
              contentPadding: EdgeInsets.all(16),
              suffixIcon: Icon(Icons.send),
            ),
          ),
        ],
      ),
    );
  }
}

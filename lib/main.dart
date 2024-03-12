import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:websocket_chatroom/presentation/splash_page.dart';

import 'presentation/home_page.dart';
import 'providers/auth_provider.dart';
import 'providers/messages_provider.dart';

void main() {
  runApp(const RootApp());
}

class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (context) => MessagesProvider(),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        title: 'Realtime Chat App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SplashPage(),
      ),
    );
  }
}

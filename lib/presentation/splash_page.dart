import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:websocket_chatroom/presentation/home_page.dart';
import 'package:websocket_chatroom/providers/messages_provider.dart';

import '../providers/auth_provider.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      Provider.of<AuthProvider>(context, listen: false).getUser();
      Provider.of<MessagesProvider>(context, listen: false).getToken();
      if (Provider.of<MessagesProvider>(context, listen: false).token == '') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      } else {
        try {
          Provider.of<MessagesProvider>(context, listen: false)
              .initSocketConnection();
          Provider.of<MessagesProvider>(context, listen: false)
              .getPastMessages();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } catch (e) {
          debugPrint('Error: $e');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/common/font/font.dart';
import 'package:test_flutter/domain/services/player_service.dart';
import 'package:test_flutter/firebase_options.dart';
import 'package:test_flutter/presentation/auth/gate/auth_gate.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 
  runApp(
    ChangeNotifierProvider(
      create: (context) => PlayerService(),
      child: const MyApp()
    ),
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Sona',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: MyFont.fontFamily,
      ),
      home: const AuthGate(), 
      debugShowCheckedModeBanner: false,
    );
  }
}


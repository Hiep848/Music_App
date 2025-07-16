// lib/auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/domain/services/database_service.dart';
import 'package:test_flutter/presentation/auth/pages/signin.dart';
import 'package:test_flutter/presentation/screens/home_page/main_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // User not signed in
        if (!snapshot.hasData) {
          return SigninPage();
        }

        final user = snapshot.data!;
        
        return MultiProvider(
          providers: [
            Provider<User>.value(value: user),
            ProxyProvider<User, DatabaseService>(
              update: (context, user, previous) => DatabaseService(uid: user.uid),
            ),
          ],
          child: const MainScreen(),
        );
      },
    );
  }
}
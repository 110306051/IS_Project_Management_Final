// lib/pages/login_page.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _onLoginPressed() async {
    final username = _usernameCtrl.text.trim();
    final password = _pwdCtrl.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter username and password to login.')),
      );
      return;
    }

    setState(() {
      _loading = true;
    });
    final success = await ApiService.login(username, password);
    setState(() {
      _loading = false;
    });

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login failed. Please check your username and password.',
          ),
        ),
      );
      return;
    }

    Navigator.pushReplacementNamed(context, '/chatList');
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _pwdCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 32),
                _loading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onLoginPressed,
                        child: const Text('Login'),
                      ),
                    ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed:
                      () =>
                          Navigator.pushReplacementNamed(context, '/register'),
                  child: const Text('Don\'t have an account? Register here.'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

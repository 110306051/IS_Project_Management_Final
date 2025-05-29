// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart'; // 使用後端 API Service

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  String? _selectedLanguage;
  String? _selectedIdentity;
  bool _loading = false;

  static const List<String> languages = ['繁體中文', '英文', '印尼文'];
  static const List<String> identities = ['台灣', '印尼'];

  Future<void> _onRegisterPressed() async {
    final username = _usernameCtrl.text.trim();
    final password = _pwdCtrl.text;
    final language = _selectedLanguage;
    final identity = _selectedIdentity;

    if (username.isEmpty || password.isEmpty || language == null || identity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請填寫所有欄位，包括使用者名稱、密碼、語言和身分')),
      );
      return;
    }

    setState(() { _loading = true; });
    final success = await ApiService.register(username, password, language, identity);
    setState(() { _loading = false; });

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('註冊失敗，請稍後再試')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('註冊成功，請登入')),
    );
    Navigator.pushReplacementNamed(context, '/login');
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
      appBar: AppBar(title: const Text('註冊')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(
                labelText: '使用者名稱',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pwdCtrl,
              decoration: const InputDecoration(
                labelText: '密碼',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '語言',
                prefixIcon: Icon(Icons.language),
              ),
              value: _selectedLanguage,
              items: languages.map((lang) => DropdownMenuItem(
                value: lang,
                child: Text(lang),
              )).toList(),
              onChanged: (val) => setState(() => _selectedLanguage = val),
              hint: const Text('選擇語言'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '身分',
                prefixIcon: Icon(Icons.badge),
              ),
              value: _selectedIdentity,
              items: identities.map((id) => DropdownMenuItem(
                value: id,
                child: Text(id),
              )).toList(),
              onChanged: (val) => setState(() => _selectedIdentity = val),
              hint: const Text('選擇身分'),
            ),
            const SizedBox(height: 32),
            _loading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onRegisterPressed,
                      child: const Text('註冊'),
                    ),
                  ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('已有帳號？前往登入'),
            ),
          ],
        ),
      ),
    );
  }
}

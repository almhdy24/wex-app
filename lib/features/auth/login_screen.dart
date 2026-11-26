import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/network/api_exception.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (!email.contains('@')) {
      setState(() => _error = 'أدخل بريدًا إلكترونيًا صحيحًا');
      return;
    }
    setState(() { _busy = true; _error = null; });
    try {
      await ref.read(authControllerProvider.notifier).requestEmailOtp(email);
      if (mounted) context.push('/verify?email=${Uri.encodeComponent(email)}');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'تعذّر الاتصال. حاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: ListView(
        padding: const EdgeInsets.all(Sp.page),
        children: [
          const SizedBox(height: 24),
          const Text('سجّل دخولك بدون كلمة مرور',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('سنرسل رمز تحقق من 6 أرقام إلى بريدك.',
              style: TextStyle(color: WexColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            decoration: const InputDecoration(hintText: 'بريدك الإلكتروني'),
          ),
          if (_error != null) Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_error!, style: const TextStyle(color: WexColors.danger)),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('إرسال رمز التحقق'),
          ),
        ],
      ),
    );
  }
}

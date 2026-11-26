import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design/colors.dart';
import '../../core/design/spacing.dart';
import '../../core/network/api_exception.dart';
import '../../core/utils/ascii_digits.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  final String email;
  const VerifyScreen({super.key, required this.email});
  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  final _code = TextEditingController();
  final _name = TextEditingController();
  bool _busy = false, _needName = false;
  String? _error;

  Future<void> _submit() async {
    final code = toAsciiDigits(_code.text.trim());
    if (code.length != 6) { setState(() => _error = 'الرمز مكوّن من 6 أرقام'); return; }
    setState(() { _busy = true; _error = null; });
    try {
      await ref.read(authControllerProvider.notifier).verifyEmailOtp(
        email: widget.email, code: code, name: _needName ? _name.text.trim() : null);
      if (mounted) context.go('/account');
    } on ApiException catch (e) {
      setState(() {
        if (e.fieldError('name') != null) _needName = true;
        _error = e.message;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تأكيد الرمز')),
      body: ListView(
        padding: const EdgeInsets.all(Sp.page),
        children: [
          const SizedBox(height: 24),
          Text('أدخل الرمز المُرسل إلى\n${widget.email}',
              style: const TextStyle(color: WexColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            maxLength: 6,
            style: const TextStyle(fontSize: 28, letterSpacing: 8, fontWeight: FontWeight.w800),
            decoration: const InputDecoration(counterText: ''),
          ),
          if (_needName) Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextField(controller: _name, decoration: const InputDecoration(hintText: 'اسمك الكامل')),
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
                : const Text('تأكيد الدخول'),
          ),
        ],
      ),
    );
  }
}

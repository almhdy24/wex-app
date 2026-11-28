import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design/colors.g.dart';
import '../../core/design/spacing.dart';
import '../../core/network/api_exception.dart';
import '../../core/strings.dart';
import '../../core/utils/ascii_digits.dart';
import '../../core/widgets/wex_widgets.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  final String email;
  const VerifyScreen({super.key, required this.email});
  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  final _ctrls = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());
  final _name = TextEditingController();
  bool _busy = false, _needName = false;
  String? _error;
  int _resendIn = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResend();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _nodes.first.requestFocus());
  }

  void _startResend() {
    _resendIn = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _resendIn--);
      if (_resendIn <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    _name.dispose();
    super.dispose();
  }

  String get _code => _ctrls.map((c) => c.text).join();

  void _onChanged(int i, String v) {
    final digits = toAsciiDigits(v);
    if (digits.length > 1) {
      // paste
      for (var j = 0; j < 6 && j < digits.length; j++) {
        _ctrls[j].text = digits[j];
      }
      setState(() {});
      if (_code.length == 6) _submit();
      return;
    }
    if (digits.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
    if (digits.isEmpty && i > 0) _nodes[i - 1].requestFocus();
    setState(() {});
    if (_code.length == 6) _submit();
  }

  Future<void> _submit() async {
    if (_code.length != 6) {
      setState(() => _error = Ar.verifyCodeLen);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).verifyEmailOtp(
          email: widget.email,
          code: _code,
          name: _needName ? _name.text.trim() : null);
      if (mounted) context.go('/');
    } on ApiException catch (e) {
      setState(() {
        if (e.fieldError('name') != null) _needName = true;
        _error = e.message;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    try {
      await ref
          .read(authControllerProvider.notifier)
          .requestEmailOtp(widget.email);
      _startResend();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(Sp.x8),
        children: [
          const SizedBox(height: 12),
          const Text(Ar.verifyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(Ar.verifySentTo(widget.email),
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: WexColors.textSecondary, height: 1.6)),
          const SizedBox(height: Sp.x9),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var i = 0; i < 6; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: SizedBox(
                    width: 46,
                    height: 56,
                    child: TextField(
                      controller: _ctrls[i],
                      focusNode: _nodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800),
                      decoration: const InputDecoration(
                          counterText: '', contentPadding: EdgeInsets.zero),
                      onChanged: (v) => _onChanged(i, v),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9٠-٩۰-۹]'))
                      ],
                    ),
                  ),
                ),
            ]),
          ),
          if (_needName)
            Padding(
              padding: const EdgeInsets.only(top: Sp.x6),
              child: TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: Ar.nameHint)),
            ),
          if (_error != null)
            Padding(
                padding: const EdgeInsets.only(top: Sp.x6),
                child: Text(_error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: WexColors.danger))),
          const SizedBox(height: Sp.x7),
          WexButton(Ar.confirmLogin,
              loading: _busy, onPressed: _busy ? null : _submit),
          const SizedBox(height: Sp.x6),
          Center(
            child: _resendIn > 0
                ? Text(Ar.resendCountdown(_resendIn),
                    style: const TextStyle(color: WexColors.textSecondary))
                : TextButton(onPressed: _resend, child: const Text(Ar.resend)),
          ),
        ],
      ),
    );
  }
}

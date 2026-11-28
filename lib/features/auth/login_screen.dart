import '../../ui/brand_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/design/colors.g.dart';
import '../../core/design/spacing.dart';
import '../../core/network/api_exception.dart';
import '../../core/strings.dart';
import '../../ui/icons.dart';
import '../../core/design/typography.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  bool _busyGoogle = false, _busyEmail = false;
  bool _emailMode = false;
  String? _error;

  Future<void> _google() async {
    setState(() {
      _busyGoogle = true;
      _error = null;
    });
    final ok =
        await ref.read(authControllerProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    setState(() => _busyGoogle = false);
    if (ok) {
      context.pop();
    } else {
      setState(() => _error = Ar.googleFailed);
    }
  }

  Future<void> _sendCode() async {
    final email = _email.text.trim();
    if (!email.contains('@')) {
      setState(() => _error = Ar.invalidEmail);
      return;
    }
    setState(() {
      _busyEmail = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).requestEmailOtp(email);
      if (mounted) context.push('/verify?email=${Uri.encodeComponent(email)}');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = Ar.connectFailed);
    } finally {
      if (mounted) setState(() => _busyEmail = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Sp.x8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(LucideIcons.arrowRight)),
              ),
              const Spacer(),
              const Center(child: BrandSymbol(size: 64)),
              const SizedBox(height: Sp.x8),
              const Text(Ar.loginTitle,
                  textAlign: TextAlign.center,
                  style: WexText.titleL),
              const SizedBox(height: 8),
              const Text(Ar.loginSubtitle,
                  textAlign: TextAlign.center,
                  style: WexText.bodyS),
              const SizedBox(height: Sp.x10),

              // PRIMARY: Google
              FilledButton(
                onPressed: _busyGoogle ? null : _google,
                style: FilledButton.styleFrom(
                  backgroundColor: WexColors.surface,
                  foregroundColor: WexColors.ink900,
                  side: const BorderSide(color: WexColors.border),
                  minimumSize: const Size.fromHeight(56),
                ),
                child: _busyGoogle
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                            _GoogleG(),
                            SizedBox(width: 12),
                            Text(Ar.googleContinue,
                                style: TextStyle(fontWeight: FontWeight.w700)),
                          ]),
              ),
              const SizedBox(height: Sp.x6),

              if (!_emailMode)
                TextButton(
                  onPressed: () => setState(() => _emailMode = true),
                  child: const Text(Ar.emailLogin),
                )
              else ...[
                Row(children: const [
                  Expanded(child: Divider()),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(Ar.orWord,
                          style: TextStyle(color: WexColors.textSecondary))),
                  Expanded(child: Divider()),
                ]),
                const SizedBox(height: Sp.x6),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(hintText: Ar.emailHint),
                ),
                const SizedBox(height: Sp.x5),
                FilledButton(
                  onPressed: _busyEmail ? null : _sendCode,
                  child: _busyEmail
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: WexColors.surface))
                      : const Text(Ar.sendCode),
                ),
              ],

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: Sp.x6),
                  child: Text(_error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: WexColors.danger)),
                ),
              const Spacer(flex: 2),
              const Text(Ar.termsNote,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: WexColors.disabled, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple Google "G" mark (brand colours).
class _GoogleG extends StatelessWidget {
  const _GoogleG();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 20,
        height: 20,
        child: CustomPaint(painter: _GPainter()),
      );
}

class _GPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22
      ..strokeCap = StrokeCap.butt;
    void arc(double start, double sweep, Color col) {
      paint.color = col;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r * 0.78), start, sweep,
          false, paint);
    }

    arc(-0.35, 1.2, WexColors.googleBlue);
    arc(0.85, 1.4, WexColors.googleGreen);
    arc(2.25, 1.4, WexColors.googleYellow);
    arc(3.65, 1.4, WexColors.googleRed);
    // crossbar
    final bar = Paint()
      ..color = WexColors.googleBlue
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        Rect.fromLTWH(
            c.dx, c.dy - size.height * 0.08, r * 0.82, size.height * 0.16),
        bar);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import '../../core/design/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const _Placeholder(title: 'الرئيسية', note: 'الواجهة الرئيسية — M1');
}

class _Placeholder extends StatelessWidget {
  final String title, note;
  const _Placeholder({required this.title, required this.note});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Text(note, style: const TextStyle(color: WexColors.textSecondary)),
        ),
      );
}

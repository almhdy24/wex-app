import 'package:flutter/material.dart';
import '../../core/design/colors.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('المتجر')),
        body: const Center(child: Text('قائمة الأجهزة — M1', style: TextStyle(color: WexColors.textSecondary))),
      );
}

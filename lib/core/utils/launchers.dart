import 'package:url_launcher/url_launcher.dart';

String _digits(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

/// Sudan numbers: local 09XXXXXXXX -> +2499XXXXXXXX for wa.me.
String _waNumber(String raw) {
  var d = _digits(raw);
  if (d.startsWith('00')) d = d.substring(2);
  if (d.startsWith('0')) d = '249${d.substring(1)}';
  if (!d.startsWith('249') && d.length == 9) d = '249$d';
  return d;
}

Future<void> openWhatsApp(String number, {String? text}) async {
  final n = _waNumber(number);
  if (n.isEmpty) return;
  final uri = Uri.parse('https://wa.me/$n${text != null ? '?text=${Uri.encodeComponent(text)}' : ''}');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> openDialer(String number) async {
  final uri = Uri(scheme: 'tel', path: _digits(number));
  await launchUrl(uri);
}

Future<void> openMaps(String query) async {
  final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> openUrl(String url) async {
  if (url.isEmpty) return;
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

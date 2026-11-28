import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/design/colors.g.dart';
import '../core/design/typography.dart';
import 'icons.dart';

/// Full-screen gallery with pinch zoom. [urls] are absolute.
void openImageViewer(BuildContext context, List<String> urls, int start) {
  Navigator.of(context, rootNavigator: true).push(PageRouteBuilder<void>(
    opaque: true,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) => _Viewer(urls: urls, start: start),
    transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
  ));
}

class _Viewer extends StatefulWidget {
  final List<String> urls;
  final int start;
  const _Viewer({required this.urls, required this.start});
  @override
  State<_Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<_Viewer> {
  late final PageController _c = PageController(initialPage: widget.start);
  late int _i = widget.start;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: WexColors.ink900,
        body: Stack(children: [
          PageView.builder(
            controller: _c,
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _i = i),
            itemBuilder: (_, i) => InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Center(child: CachedNetworkImage(imageUrl: widget.urls[i], fit: BoxFit.contain)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                IconButton(
                  tooltip: 'إغلاق',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x, color: WexColors.surface),
                ),
                const Spacer(),
                if (widget.urls.length > 1)
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text('${_i + 1} / ${widget.urls.length}', style: WexText.numeric.copyWith(color: WexColors.surface)),
                  ),
                const SizedBox(width: 12),
              ]),
            ),
          ),
        ]),
      );
}

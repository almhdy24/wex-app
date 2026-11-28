import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../core/design/colors.g.dart';
import '../core/design/spacing.dart';
import 'icons.dart';

/// Product photo: CONTAIN on a sunken tile (4:3 by default), 12px padding, never cropped.
class ProductPhoto extends StatelessWidget {
  final String url;
  final double aspectRatio;
  final String? heroTag;
  final int memWidth; // decode width in logical px*dpr; keeps memory flat
  final double padding;
  final BorderRadius? radius;
  const ProductPhoto({
    super.key,
    required this.url,
    this.aspectRatio = 4 / 3,
    this.heroTag,
    this.memWidth = 480,
    this.padding = 12,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    Widget img = url.isEmpty
        ? const _Fallback()
        : CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            memCacheWidth: memWidth,
            fadeInDuration: Motion.base,
            placeholder: (_, __) => const SizedBox.expand(),
            errorWidget: (_, __, ___) => const _Fallback(),
          );
    if (heroTag != null) img = Hero(tag: heroTag!, child: img);
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(color: WexColors.sunken, borderRadius: radius ?? BorderRadius.circular(Radii.control)),
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.all(padding),
        child: img,
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback();
  @override
  Widget build(BuildContext context) =>
      const Center(child: Icon(LucideIcons.image, size: 32, color: WexColors.disabled));
}

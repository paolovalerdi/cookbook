import 'dart:ui';

import 'package:flutter/material.dart';

class GlassSurface extends StatelessWidget {
  const GlassSurface({super.key, this.opacity = 0.55, required this.child});

  final double opacity;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 20,
            sigmaY: 20,
            tileMode: TileMode.clamp,
          ),
          child: Material(
            elevation: 0,
            type: MaterialType.canvas,
            color: Theme.of(
              context,
            ).scaffoldBackgroundColor.withValues(alpha: opacity),
            child: child,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  Rect get globalPaintBounds {
    final renderObject = findRenderObject();
    if (renderObject is RenderBox) {
      final translation = renderObject.getTransformTo(null).getTranslation();
      return Rect.fromLTWH(
        translation.x,
        translation.y,
        renderObject.size.width,
        renderObject.size.height,
      );
    }
    return Rect.zero;
  }
}

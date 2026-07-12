import 'package:flutter/material.dart';

import '../services/localization_service.dart';

class ResponsiveText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final double minFontSize;
  final TextOverflow overflow;

  const ResponsiveText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.minFontSize = 11,
    this.overflow = TextOverflow.visible,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context).style;
    final effectiveStyle = defaultStyle.merge(style);
    final baseFontSize = effectiveStyle.fontSize ?? defaultStyle.fontSize ?? 14;
    final textDirection = LocalizationService.languageCode == 'ar'
        ? TextDirection.rtl
        : Directionality.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth || constraints.maxWidth <= 0) {
          return _buildText(
            effectiveStyle,
            textDirection,
            baseFontSize,
          );
        }

        final fontSize = _largestFittingFontSize(
          text: data,
          style: effectiveStyle,
          baseFontSize: baseFontSize,
          maxWidth: constraints.maxWidth,
          textDirection: textDirection,
          textScaler: MediaQuery.textScalerOf(context),
        );

        return _buildText(
          effectiveStyle,
          textDirection,
          fontSize,
        );
      },
    );
  }

  Widget _buildText(
    TextStyle effectiveStyle,
    TextDirection textDirection,
    double fontSize,
  ) {
    final singleLine = maxLines == 1;

    return Text(
      data,
      textAlign: textAlign,
      maxLines: maxLines,
      softWrap: !singleLine,
      overflow: overflow,
      textDirection: textDirection,
      style: effectiveStyle.copyWith(fontSize: fontSize),
    );
  }

  double _largestFittingFontSize({
    required String text,
    required TextStyle style,
    required double baseFontSize,
    required double maxWidth,
    required TextDirection textDirection,
    required TextScaler textScaler,
  }) {
    if (_fits(
      text: text,
      style: style.copyWith(fontSize: baseFontSize),
      maxWidth: maxWidth,
      textDirection: textDirection,
      textScaler: textScaler,
    )) {
      return baseFontSize;
    }

    var low = minFontSize;
    var high = baseFontSize;

    for (var i = 0; i < 10; i++) {
      final mid = (low + high) / 2;
      if (_fits(
        text: text,
        style: style.copyWith(fontSize: mid),
        maxWidth: maxWidth,
        textDirection: textDirection,
        textScaler: textScaler,
      )) {
        low = mid;
      } else {
        high = mid;
      }
    }

    return low.clamp(minFontSize, baseFontSize);
  }

  bool _fits({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required TextDirection textDirection,
    required TextScaler textScaler,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: textAlign ?? TextAlign.start,
      textDirection: textDirection,
      maxLines: maxLines,
      textScaler: textScaler,
    )..layout(maxWidth: maxWidth);

    return !painter.didExceedMaxLines && painter.width <= maxWidth;
  }
}

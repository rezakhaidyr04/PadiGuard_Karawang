import 'package:flutter/material.dart';

/// Minimal markdown renderer (no external deps):
/// - Bold: **text**
/// - Bullets: "- item" or "1. item" (per-line)
/// - Line breaks: supports "\n"
class MarkdownLikeText extends StatelessWidget {
  final String text;
  final Color textColor;
  final double fontSize;

  const MarkdownLikeText({
    required this.text,
    required this.textColor,
    required this.fontSize,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final lines = text.replaceAll('\r\n', '\n').split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          if (line.trim().isEmpty)
            const SizedBox(height: 10)
          else if (_isOrderedBullet(line))
            _buildBulletRow(
              marker: '${_orderedIndex(line)}.',
              content: _stripOrderedMarker(line),
            )
          else if (_isUnorderedBullet(line))
            _buildBulletRow(
              marker: '•',
              content: _stripUnorderedMarker(line),
            )
          else
            _buildParagraph(line),
      ],
    );
  }

  bool _isUnorderedBullet(String line) {
    final t = line.trimLeft();
    return t.startsWith('- ');
  }

  String _stripUnorderedMarker(String line) {
    final t = line.trimLeft();
    return t.startsWith('- ') ? t.substring(2) : t;
  }

  bool _isOrderedBullet(String line) {
    final t = line.trimLeft();
    return RegExp(r'^\d+\.\s+').hasMatch(t);
  }

  int _orderedIndex(String line) {
    final t = line.trimLeft();
    final match = RegExp(r'^(\d+)\.\s+').firstMatch(t);
    if (match == null) return 1;
    return int.tryParse(match.group(1) ?? '') ?? 1;
  }

  String _stripOrderedMarker(String line) {
    final t = line.trimLeft();
    final match = RegExp(r'^\d+\.\s+').firstMatch(t);
    if (match == null) return t;
    return t.substring(match.end);
  }

  Widget _buildBulletRow({
    required String marker,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            marker,
            style: TextStyle(
              fontSize: fontSize,
              color: textColor,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildInlineBoldText(content),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraph(String line) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: _buildInlineBoldText(line),
    );
  }

  /// Supports **bold** spans only.
  Widget _buildInlineBoldText(String line) {
    final parts = line.split('**');

    // If no markdown bold delimiters, render normal Text
    if (parts.length < 3) {
      return Text(
        line,
        style: TextStyle(
          fontSize: fontSize,
          color: textColor,
          height: 1.5,
          fontFamily: 'Inter',
        ),
      );
    }

    final spans = <TextSpan>[];
    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      if (part.isEmpty) continue;

      final isBold = i.isOdd; // split produces: normal, bold, normal, bold...
      spans.add(
        TextSpan(
          text: part,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor,
            height: 1.5,
            fontFamily: 'Inter',
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w400,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}

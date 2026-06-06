import 'package:flutter/material.dart';

class HtmlParser {
  /// Parses simple HTML from Arbeitnow and returns a list of styled Widgets.
  static List<Widget> parse(String html, ThemeData theme) {
    final List<Widget> widgets = [];
    if (html.isEmpty) return widgets;

    // First decode common HTML entities
    String cleanHtml = decodeHtmlEntities(html);

    // Split by block tags to isolate paragraphs and headings
    final blocks = cleanHtml.split(RegExp(r'(?=<(?:p|h1|h2|h3|ul|ol|li|div|br)\b)'));

    for (var block in blocks) {
      block = block.trim();
      if (block.isEmpty) continue;

      if (block.startsWith('<h1') || block.startsWith('<h2') || block.startsWith('<h3') || block.startsWith('<h4')) {
        final content = _stripTags(block);
        if (content.isNotEmpty) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                content,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          );
        }
      } else if (block.startsWith('<li')) {
        final content = _stripTags(block);
        if (content.isNotEmpty) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "• ",
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      content,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      } else if (block.startsWith('<p') || block.startsWith('<div') || block.startsWith('<span')) {
        final content = _stripTags(block);
        if (content.isNotEmpty) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                content,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  height: 1.6,
                ),
              ),
            ),
          );
        }
      } else {
        // Fallback for untagged text
        final content = _stripTags(block);
        if (content.isNotEmpty) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                content,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                ),
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }

  /// Strip all HTML tags
  static String _stripTags(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  /// Decodes HTML entities like &#x26; or &amp; to plain text symbols
  static String decodeHtmlEntities(String input) {
    if (input.isEmpty) return '';
    
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&#x26;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&#x3C;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#x3E;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#160;', ' ')
        .replaceAll('&ndash;', '–')
        .replaceAll('&mdash;', '—')
        .replaceAll('&euro;', '€')
        .replaceAll('&copy;', '©')
        .replaceAll('&reg;', '®');
  }
}

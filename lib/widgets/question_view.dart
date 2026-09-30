import 'package:flutter/material.dart';

import 'models.dart';

/// Shows one question with its 4 options.
/// - Test mode: tap an option to select it.
/// - Review mode: correct option is green, a wrong selection is red.
class QuestionView extends StatelessWidget {
  const QuestionView({
    super.key,
    required this.question,
    this.selected = -1,
    this.review = false,
    this.onSelect,
  });

  final Question question;
  final int selected;
  final bool review;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final q = question;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (q.image != null)
          AssetPic(path: 'assets/${q.image}')
        else
          Text(
            q.text,
            style: const TextStyle(
              fontSize: 17,
              height: 1.55,
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(height: 16),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OptionTile(
              index: i,
              question: q,
              selected: selected,
              review: review,
              onTap: onSelect == null ? null : () => onSelect!(i),
            ),
          ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.index,
    required this.question,
    required this.selected,
    required this.review,
    this.onTap,
  });

  final int index;
  final Question question;
  final int selected;
  final bool review;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isCorrect = index == question.answer;
    final isSelected = index == selected;

    Color border = cs.outlineVariant;
    Color fill = Colors.transparent;
    Widget? trailing;
    var thick = false;

    if (review) {
      if (isCorrect) {
        border = Colors.green;
        fill = const Color(0x2243A047);
        trailing = const Icon(Icons.check_circle, color: Colors.green);
        thick = true;
      } else if (isSelected) {
        border = Colors.red;
        fill = const Color(0x22E53935);
        trailing = const Icon(Icons.cancel, color: Colors.red);
        thick = true;
      }
    } else if (isSelected) {
      border = cs.primary;
      fill = cs.primaryContainer;
      thick = true;
    }

    final radius = BorderRadius.circular(12);
    final img = question.optionImages[index];

    return Material(
      color: fill,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: border, width: thick ? 2 : 1),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: isSelected && !review
                    ? cs.primary
                    : cs.surfaceContainerHighest,
                foregroundColor:
                    isSelected && !review ? cs.onPrimary : cs.onSurface,
                child: Text('${index + 1}',
                    style: const TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: img != null
                    ? AssetPic(path: 'assets/$img')
                    : Text(
                        question.options[index],
                        style: const TextStyle(fontSize: 16, height: 1.4),
                      ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// An image cropped from the source PDF (fractions, tables, figures...).
/// Tap to open it full screen and pinch-zoom.
class AssetPic extends StatelessWidget {
  const AssetPic({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => _ZoomPage(path: path),
        ),
      ),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.all(4),
        alignment: Alignment.centerLeft,
        child: Image.asset(
          path,
          fit: BoxFit.contain,
          alignment: Alignment.centerLeft,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}

class _ZoomPage extends StatelessWidget {
  const _ZoomPage({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Pinch to zoom')),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5,
          child: Image.asset(path),
        ),
      ),
    );
  }
}

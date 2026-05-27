import 'package:flutter/material.dart';

enum QRButtonTone { filled, soft }

class QRButton extends StatelessWidget {
  final String headLineText;
  final String descriptionText;
  final IconData icon;
  final VoidCallback? onPressed;
  final QRButtonTone tone;
  final double height;
  final String? eyebrowText;

  const QRButton({
    super.key,
    required this.headLineText,
    required this.descriptionText,
    required this.icon,
    this.onPressed,
    this.tone = QRButtonTone.filled,
    this.height = 148,
    this.eyebrowText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isFilled = tone == QRButtonTone.filled;
    final backgroundColor = isFilled
        ? colors.primary
        : Color.alphaBlend(
            colors.primary.withValues(alpha: 0.07),
            colors.surface,
          );
    final foregroundColor = isFilled ? Colors.white : colors.onSurface;
    final descriptionColor = isFilled
        ? Colors.white.withValues(alpha: 0.88)
        : colors.onSurface.withValues(alpha: 0.68);
    final iconBackground = isFilled
        ? Colors.white.withValues(alpha: 0.16)
        : colors.primary.withValues(alpha: 0.12);
    final borderColor = isFilled
        ? Colors.transparent
        : colors.primary.withValues(alpha: 0.18);
    final shadowColor = isFilled
        ? colors.primary.withValues(alpha: 0.24)
        : Colors.black.withValues(alpha: 0.08);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: backgroundColor,
        elevation: isFilled ? 7 : 2,
        shadowColor: shadowColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (eyebrowText != null) ...[
                        Text(
                          eyebrowText!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: foregroundColor.withValues(alpha: 0.74),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        headLineText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: foregroundColor,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        descriptionText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: descriptionColor,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 29,
                    color: isFilled ? Colors.white : colors.primary,
                  ),
                ),
                if (onPressed != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isFilled
                        ? Colors.white.withValues(alpha: 0.72)
                        : colors.primary.withValues(alpha: 0.72),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';

class TagWidget extends StatelessWidget {
  const TagWidget({
    super.key,
    required this.title,
    required this.icon,
    this.selected = false,
    this.onTap,
  });

  final String title;
  final Icon icon;
  final bool selected;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    ColorScheme col = context.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: .circular(15),
      child: Container(
        padding: .symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? col.primary.withValues(alpha: .56)
              : col.surfaceContainerHighest,
          borderRadius: .circular(15),
          boxShadow: [
            .new(color: col.primary.withValues(alpha: .45), blurRadius: 13),
          ],
        ),
        child: Row(
          spacing: 4,
          children: [
            ColorFiltered(
              colorFilter: .mode(col.onSurfaceVariant, .dstIn),
              child: icon,
            ),
            Text(title, style: TextStyle(color: col.onSurface)),
          ],
        ),
      ),
    );
  }
}

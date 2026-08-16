import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';

class IconMenuListTile extends StatefulWidget {
  const IconMenuListTile({
    super.key,
    required this.title,
    required this.subTitle,
    required this.leadIcon,
    required this.trailingIcon,
    this.onTap,
  });

  final String title;
  final String subTitle;
  final IconData leadIcon;
  final IconData trailingIcon;
  final void Function()? onTap;

  @override
  State<IconMenuListTile> createState() => _IconMenuListTileState();
}

class _IconMenuListTileState extends State<IconMenuListTile> {
  late final col = context.colorScheme;
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) => setState(() {
          isSelected = true;
        }),
        onExit: (event) => setState(() {
          isSelected = false;
        }),
        child: Container(
          padding: .symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: .circular(15),
            color: isSelected
                ? col.surfaceContainerHighest
                : col.surfaceContainerHighest.withValues(alpha: .45),
          ),
          child: Row(
            children: [
              Container(
                padding: .all(5),
                decoration: BoxDecoration(
                  color: col.primaryContainer,
                  borderRadius: .circular(15),
                ),
                child: Icon(widget.leadIcon, color: col.onPrimaryContainer),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: .start,
                spacing: 4,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: .w600,
                      color: col.onSurface,
                    ),
                  ),
                  Text(
                    widget.subTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: .w400,
                      color: col.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Icon(widget.trailingIcon, color: col.onPrimaryFixedVariant),
            ],
          ),
        ),
      ),
    );
  }
}

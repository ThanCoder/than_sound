// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

///Sort Item
class SortItem {
  final int id;
  final String title;
  final bool isTrue;
  final String trueTitle;
  final String falseTitle;
  const SortItem({
    required this.id,
    required this.title,
    required this.isTrue,
    required this.trueTitle,
    required this.falseTitle,
  });

  ///default name
  ///
  ///trueTitle: Text("A To Z"),
  ///
  ///falseTitle: Text('Z To A'),
  ///
  ///isTrue: true,
  ///
  static final nameSortItem = SortItem(
    id: 1000,
    title: 'Name',
    trueTitle: "A To Z",
    falseTitle: 'Z To A',
    isTrue: true,
  );

  /// default data
  /// trueTitle: Text("New To Old"),
  ///
  /// falseTitle: Text('Old To New'),
  ///
  /// isTrue: true,
  static final dateSortItem = SortItem(
    id: 1001,
    title: 'Date',
    trueTitle: "New To Old",
    falseTitle: 'Old To New',
    isTrue: true,
  );

  /// trueTitle: Text("Small To Big"),
  ///
  /// falseTitle: Text("Big To Small"),
  ///
  /// isTrue: true,
  static final sizeSortItem = SortItem(
    id: 1,
    title: 'Size',
    trueTitle: "Small To Big",
    falseTitle: "Big To Small",
    isTrue: true,
  );

  /// trueTitle: Text("Small To Big"),
  ///
  /// falseTitle: Text("Big To Small"),
  ///
  /// isTrue: true,
  static final durationSortItem = SortItem(
    id: 2,
    title: 'Duration',
    trueTitle: "Small To Big",
    falseTitle: "Big To Small",
    isTrue: true,
  );

  @override
  String toString() {
    return 'SortItem(id: $id, title: $title, isTrue: $isTrue, trueTitle: $trueTitle, falseTitle: $falseTitle)';
  }

  // ပြဿနာကို ဖြေရှင်းပေးမယ့် ကုဒ်အပိုင်းအစ
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortItem && runtimeType == other.runtimeType && id == other.id; // ID တူရင် Object ချင်း တူတယ်လို့ သတ်မှတ်ခိုင်းတာပါ

  @override
  int get hashCode => id.hashCode;

  SortItem copyWith({
    int? id,
    String? title,
    bool? isTrue,
    String? trueTitle,
    String? falseTitle,
  }) {
    return SortItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isTrue: isTrue ?? this.isTrue,
      trueTitle: trueTitle ?? this.trueTitle,
      falseTitle: falseTitle ?? this.falseTitle,
    );
  }
}

class SortButton extends StatelessWidget {
  final List<SortItem> list;
  final SortItem value;
  final BoxConstraints? boxConstraints;
  final void Function(SortItem item)? onApply;
  final Widget? title;
  const SortButton({
    super.key,
    required this.value,
    required this.list,
    this.onApply,
    this.title,
    this.boxConstraints,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final res = await showModalBottomSheet<SortItem>(
          context: context,
          builder: (context) => SortProviderDialog(
            list: list,
            value: value,
            title: title,
            boxConstraints: boxConstraints,
          ),
        );
        if (res == null) return;
        onApply?.call(res);
      },
      icon: Icon(Icons.sort),
    );
  }
}

class SortProviderDialog extends StatefulWidget {
  final List<SortItem> list;
  final SortItem value;
  final Widget? title;
  final BoxConstraints? boxConstraints;
  const SortProviderDialog({
    super.key,
    required this.list,
    required this.value,
    this.boxConstraints,
    this.title,
  });

  @override
  State<SortProviderDialog> createState() => _SortProviderDialogState();
}

class _SortProviderDialogState extends State<SortProviderDialog> {
  late SortItem item;

  @override
  void initState() {
    item = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop<SortItem>(context, item);
      },
      child: ConstrainedBox(
        constraints:
            widget.boxConstraints ?? const BoxConstraints(minHeight: 400),
        child: Material(
          color: colors.surface,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              spacing: 12,
              children: [
                _header(),

                _section(child: sortGropWidget),

                _section(child: sortResultWidgt),

                // applyWidget,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.sort_rounded, color: colors.primary, size: 22),
        ),

        const SizedBox(width: 12),

        Expanded(
          child:
              widget.title ??
              const Text(
                'Sort By',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
        ),
      ],
    );
  }

  Widget _section({required Widget child}) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .25)),
      ),
      child: child,
    );
  }

  Widget get sortGropWidget {
    return RadioGroup<SortItem>(
      groupValue: item,
      onChanged: (value) {
        setState(() {
          item = value!;
        });
      },
      child: Column(
        children: widget.list
            .map(
              (e) => _radioItem<SortItem>(
                value: e,
                groupValue: item,
                title: e.title,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget get sortResultWidgt {
    return RadioGroup<bool>(
      groupValue: item.isTrue,
      onChanged: (bool? value) {
        if (value == null) return;

        setState(() {
          item = item.copyWith(isTrue: value);
        });
      },
      child: Column(
        children: [
          _radioItem<bool>(
            value: true,
            groupValue: item.isTrue,
            title: item.trueTitle,
          ),

          _radioItem<bool>(
            value: false,
            groupValue: item.isTrue,
            title: item.falseTitle,
          ),
        ],
      ),
    );
  }

  Widget _radioItem<T>({
    required T value,
    required T? groupValue,
    required String title,
  }) {
    final colors = Theme.of(context).colorScheme;
    final selected = value == groupValue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: .10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: RadioListTile<T>.adaptive(
          value: value,
          title: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? colors.primary : colors.onSurface,
            ),
          ),
          activeColor: colors.primary,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          dense: true,
        ),
      ),
    );
  }

  Widget get applyWidget {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          Navigator.pop<SortItem>(context, item);
        },
        icon: const Icon(Icons.check_rounded, size: 20),
        label: const Text(
          'Apply',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

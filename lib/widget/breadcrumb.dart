import 'package:flutter/material.dart';

/// Simple, reusable breadcrumb widget.
///
/// Usage:
/// Breadcrumb(
///   items: [
///     BreadcrumbItem('Home', onTap: () => ...),
///     BreadcrumbItem('Category', onTap: () => ...),
///     BreadcrumbItem('Product'), // last item, non-clickable
///   ],
/// )

class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  BreadcrumbItem(this.label, {this.onTap});
}

class Breadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final TextStyle? textStyle;
  final Widget separator;

  const Breadcrumb({
    Key? key,
    required this.items,
    this.textStyle,
    this.separator = const Icon(Icons.chevron_right, size: 16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultStyle = textStyle ?? Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

    final children = <Widget>[];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;

      final label = GestureDetector(
        onTap: item.onTap,
        child: Text(
          item.label,
          style: isLast
              ? defaultStyle.copyWith(fontWeight: FontWeight.w600)
              : (item.onTap != null
                  ? defaultStyle.copyWith(color: Theme.of(context).primaryColor)
                  : defaultStyle),
        ),
      );

      children.add(label);

      if (!isLast) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: separator,
        ));
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

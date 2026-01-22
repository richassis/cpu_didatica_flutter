import 'package:flutter/material.dart';

/// A large card widget that displays a word pair prominently.
///
/// Used in the Generator page to show the current random word combination.
class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(text, style: style, semanticsLabel: text),
      ),
    );
  }
}

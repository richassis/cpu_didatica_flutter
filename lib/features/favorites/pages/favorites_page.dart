import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../word_generator/providers/word_generator_state.dart';

/// Page that displays the user's favorite word pairs.
///
/// Shows a list of all saved favorites with the ability to view them.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    var appState = context.watch<WordGeneratorState>();

    if (appState.favorites.isEmpty) {
      return Center(child: Text('No favorites yet.'));
    }

    var listview = ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'You have '
            '${appState.favorites.length} favorites:',
          ),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );

    return Center(
      child: Container(
        color: theme.colorScheme.surfaceContainer,
        child: Padding(padding: const EdgeInsets.all(16.0), child: listview),
      ),
    );
  }
}

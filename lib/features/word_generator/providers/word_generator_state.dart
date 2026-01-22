import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';

/// Provider that manages the state for the word generator feature.
///
/// Handles generation of random word pairs and manages favorites list.
class WordGeneratorState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
    print(favorites);
  }
}

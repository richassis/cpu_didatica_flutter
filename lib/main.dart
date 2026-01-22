import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/cpu_simulator/cpu_simulator.dart';
import 'features/favorites/favorites.dart';
import 'features/word_generator/word_generator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WordGeneratorState()),
        ChangeNotifierProvider(create: (_) => CpuSimulatorState()),
      ],
      child: MaterialApp(
        title: 'CPU Didática',
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
          ),
        ),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    Color pageColor;
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
        pageColor = Theme.of(context).colorScheme.primaryContainer;
      case 1:
        page = const FavoritesPage();
        pageColor = Theme.of(context).colorScheme.primaryContainer;
      case 2:
        page = const SimulatorPage();
        pageColor = Theme.of(context).colorScheme.surfaceContainer;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: true,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favorites'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.play_circle_outline),
                  label: Text('Simulator'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(color: pageColor, child: page),
          ),
        ],
      ),
    );
  }
}

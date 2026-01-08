import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
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
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
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

class MyHomePage extends StatefulWidget {
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
        page = GeneratorPage();
        pageColor = Theme.of(context).colorScheme.primaryContainer;
      case 1:
        page = FavoritesPage();
        pageColor = Theme.of(context).colorScheme.primaryContainer;
      case 2:
        page = SimulatorPage();
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
              destinations: [
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

Widget buildCpuComponent(BuildContext context, String type, bool isActive) {
  //AVALIAR UTILIZAÇÃO DO RIVE: https://editor.rive.app/home
  final colorScheme = Theme.of(context).colorScheme;
  final svgPath = switch (type) {
    'ula' => 'assets/images/ula_white.svg',
    'memory' => 'assets/images/ula_white.svg',
    _ => 'assets/images/ula_white.svg',
  };
  final color = isActive ? colorScheme.primary : colorScheme.onSurfaceVariant;

  final component = switch (type) {
    'ula' => Padding(
      padding: const EdgeInsets.all(0.0),
      child: SvgPicture.asset(
        svgPath,
        width: 100,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    ),
    _ => Padding(
      padding: const EdgeInsets.all(0.0),
      child: SizedBox(
        height: 240,
        width: 150,
        child: Card.filled(
          color: color,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
                    ],),
          ),
        ),
      ),
    ),
  };

  return AnimatedContainer(
    duration: Duration(seconds: 5),
    decoration: isActive
        ? BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          )
        : null,
    child: component,
  );
}

final GlobalKey gpr = GlobalKey();
final GlobalKey ula = GlobalKey();

class SimulatorPage extends StatefulWidget {
  const SimulatorPage({super.key});

  @override
  State<SimulatorPage> createState() => _SimulatorPageState();
}

class _SimulatorPageState extends State<SimulatorPage> {
  // O estado do seu simulador vive aqui
  bool _isUlaActive = false;

  void _toggleUla() {
    setState(() {
      _isUlaActive = !_isUlaActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: BusPainter(
                busColor: colorScheme.primary,
                isActive: _isUlaActive,
              ),
            ),
          ),

          Center(
            child: Row(
              spacing: 50.0,
              children: [
                Flexible(
                  key: gpr,
                  child: buildCpuComponent(context, 'GPR', _isUlaActive),
                ),
                Expanded(
                  key: ula,
                  child: buildCpuComponent(context, 'ula', _isUlaActive),
                ),
                Flexible(
                  child: ElevatedButton(
                    onPressed: _toggleUla, // Botão que altera o estado
                    child: Text(_isUlaActive ? "Desativar ULA" : "Ativar ULA"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BusPainter extends CustomPainter {
  final Color busColor;
  final bool isActive;

  BusPainter({required this.busColor, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isActive ? busColor : busColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Criamos o caminho do barramento
    final path = Path();

    path.moveTo(size.width * 0.1, size.height * 0.56);
    path.lineTo(size.width * 0.35, size.height * 0.56);

    path.moveTo(size.width * 0.1, size.height * 0.44);
    path.lineTo(size.width * 0.35, size.height * 0.44);

    path.moveTo(size.width * 0.4, size.height * 0.5);
    path.lineTo(size.width * 0.5, size.height * 0.5);

    path.moveTo(size.width * 0.5, size.height * 0.5);
    path.lineTo(size.width * 0.5, size.height * 0.3);

    canvas.drawPath(path, paint);

    // Se estiver ativo, podemos desenhar um "pulso" de dado (um círculo pequeno)
    if (isActive) {
      final pulsePaint = Paint()..color = Colors.white;
      canvas.drawCircle(
        Offset(size.width * 0.46, size.height * 0.5),
        6,
        pulsePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BusPainter oldDelegate) {
    return oldDelegate.isActive != isActive;
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;
    final style = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onSurface,
      // backgroundColor: theme.colorScheme.surfaceContainerHighest,
    );

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

    var widgets = <Widget>[
      for (var fav in favorites)
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(fav.asLowerCase, style: style),
        ),
    ];

    return Center(
      child: Container(
        color: theme.colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: listview,
          // Column(
          //   mainAxisSize: MainAxisSize.min,
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: widgets,
          // ),
        ),
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair});

  final WordPair pair;

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
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: pair.asPascalCase,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'snake_screen.dart';

class GameItem {
  final String title;
  final String emoji;
  final String subtitle;
  final Widget? screen;

  const GameItem({
    required this.title,
    required this.emoji,
    required this.subtitle,
    this.screen,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<GameItem> games = [
    const GameItem(
      title: 'SNAKE',
      emoji: '🐍',
      subtitle: 'Makan dan tumbuh!',
      screen: SnakeScreen(),
    ),
    const GameItem(
      title: 'BRICK',
      emoji: '🧱',
      subtitle: 'Hancurkan semua!',
    ),
    const GameItem(
      title: 'SPACE',
      emoji: '🚀',
      subtitle: 'Petualangan luar angkasa!',
    ),
    const GameItem(
      title: 'PUZZLE',
      emoji: '🧩',
      subtitle: 'Susun dengan benar!',
    ),
    const GameItem(
      title: '2048',
      emoji: '🔢',
      subtitle: 'Gabungkan angka!',
    ),
    const GameItem(
      title: 'BLOCK',
      emoji: '🟪',
      subtitle: 'Susun blok!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF102A6B),
              Color(0xFF6A2C91),
              Color(0xFF163A70),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🐱',
                    style: TextStyle(fontSize: 55),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CINGKU',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Colors.yellow,
                          letterSpacing: 4,
                        ),
                      ),
                      Text(
                        'KIDS ARCADE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Text(
                'Ayo Main Bersama Cingku!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: GridView.builder(
                    itemCount: games.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.9,
                    ),
                    itemBuilder: (context, index) {
                      final game = games[index];

                      return _GameCard(game: game);
                    },
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  '↑ ↓ ← → PILIH GAME     •     OK MULAI     •     BACK KEMBALI',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatefulWidget {
  final GameItem game;

  const _GameCard({
    required this.game,
  });

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> {
  bool focused = false;

  void openGame() {
    if (widget.game.screen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.game.title} segera hadir!'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => widget.game.screen!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (value) {
        setState(() {
          focused = value;
        });
      },
      child: GestureDetector(
        onTap: openGame,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.identity()
            ..scale(focused ? 1.06 : 1.0),
          decoration: BoxDecoration(
            color: focused
                ? Colors.orange.shade600
                : Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: focused ? Colors.yellow : Colors.white24,
              width: focused ? 4 : 2,
            ),
            boxShadow: focused
                ? [
                    const BoxShadow(
                      color: Colors.yellow,
                      blurRadius: 18,
                    ),
                  ]
                : [],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: openGame,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.game.emoji,
                  style: const TextStyle(fontSize: 45),
                ),
                const SizedBox(width: 14),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.game.title,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.game.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

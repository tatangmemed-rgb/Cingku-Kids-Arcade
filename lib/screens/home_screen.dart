import 'package:flutter/material.dart';

import 'snake_screen.dart';
import 'brick_breaker_screen.dart';
import 'space_screen.dart';
import 'puzzle_screen.dart';
import 'game_2048_screen.dart';
import 'block_screen.dart';

class GameItem {
  final String title;
  final String emoji;
  final String subtitle;
  final Widget screen;

  const GameItem({
    required this.title,
    required this.emoji,
    required this.subtitle,
    required this.screen,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      const GameItem(
        title: 'SNAKE',
        emoji: '🐍',
        subtitle: 'Makan dan tumbuh!',
        screen: SnakeScreen(),
      ),
      const GameItem(
        title: 'BRICK BREAKER',
        emoji: '🧱',
        subtitle: 'Hancurkan semua!',
        screen: BrickBreakerScreen(),
      ),
      const GameItem(
        title: 'SPACE',
        emoji: '🚀',
        subtitle: 'Petualangan luar angkasa!',
        screen: SpaceScreen(),
      ),
      const GameItem(
        title: 'PUZZLE',
        emoji: '🧩',
        subtitle: 'Susun dengan benar!',
        screen: PuzzleScreen(),
      ),
      const GameItem(
        title: '2048',
        emoji: '🔢',
        subtitle: 'Gabungkan angka!',
        screen: Game2048Screen(),
      ),
      const GameItem(
        title: 'BLOCK',
        emoji: '🟪',
        subtitle: 'Susun blok!',
        screen: BlockScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),

            const Text(
              '🎮',
              style: TextStyle(fontSize: 50),
            ),

            const Text(
              'CINGKU KIDS ARCADE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Pilih permainan favoritmu!',
              style: TextStyle(
                fontSize: 17,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: games.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.05,
                ),
                itemBuilder: (context, index) {
                  final game = games[index];

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => game.screen,
                          ),
                        );
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Text(
                                game.emoji,
                                style: const TextStyle(
                                  fontSize: 45,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                game.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                game.subtitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'CINGKU KIDS ARCADE',
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}                          fontSize: 18,
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

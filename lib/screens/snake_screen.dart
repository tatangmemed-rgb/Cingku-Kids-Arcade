import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Direction {
  up,
  down,
  left,
  right,
}

class SnakeScreen extends StatefulWidget {
  const SnakeScreen({super.key});

  @override
  State<SnakeScreen> createState() => _SnakeScreenState();
}

class _SnakeScreenState extends State<SnakeScreen> {
  static const int columns = 20;
  static const int rows = 12;

  List<Point<int>> snake = [];
  Point<int> food = const Point(15, 6);

  Direction direction = Direction.right;
  Direction nextDirection = Direction.right;

  Timer? timer;

  int score = 0;
  bool gameOver = false;
  bool paused = false;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    timer?.cancel();

    setState(() {
      snake = [
        const Point(8, 6),
        const Point(7, 6),
        const Point(6, 6),
      ];

      direction = Direction.right;
      nextDirection = Direction.right;

      score = 0;
      gameOver = false;
      paused = false;

      placeFood();
    });

    timer = Timer.periodic(
      const Duration(milliseconds: 180),
      (_) => moveSnake(),
    );
  }

  void placeFood() {
    final random = Random();
    Point<int> newFood;

    do {
      newFood = Point(
        random.nextInt(columns),
        random.nextInt(rows),
      );
    } while (snake.contains(newFood));

    food = newFood;
  }

  void moveSnake() {
    if (gameOver || paused || snake.isEmpty) return;

    direction = nextDirection;

    final head = snake.first;

    Point<int> newHead = head;

    switch (direction) {
      case Direction.up:
        newHead = Point(head.x, head.y - 1);
        break;
      case Direction.down:
        newHead = Point(head.x, head.y + 1);
        break;
      case Direction.left:
        newHead = Point(head.x - 1, head.y);
        break;
      case Direction.right:
        newHead = Point(head.x + 1, head.y);
        break;
    }

    if (newHead.x < 0 ||
        newHead.x >= columns ||
        newHead.y < 0 ||
        newHead.y >= rows ||
        snake.contains(newHead)) {
      setState(() {
        gameOver = true;
      });

      timer?.cancel();
      return;
    }

    setState(() {
      snake.insert(0, newHead);

      if (newHead == food) {
        score += 10;
        placeFood();
      } else {
        snake.removeLast();
      }
    });
  }

  void changeDirection(Direction newDirection) {
    if (direction == Direction.up &&
        newDirection == Direction.down) {
      return;
    }

    if (direction == Direction.down &&
        newDirection == Direction.up) {
      return;
    }

    if (direction == Direction.left &&
        newDirection == Direction.right) {
      return;
    }

    if (direction == Direction.right &&
        newDirection == Direction.left) {
      return;
    }

    nextDirection = newDirection;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          final key = event.logicalKey;

          if (key == LogicalKeyboardKey.arrowUp) {
            changeDirection(Direction.up);
          } else if (key == LogicalKeyboardKey.arrowDown) {
            changeDirection(Direction.down);
          } else if (key == LogicalKeyboardKey.arrowLeft) {
            changeDirection(Direction.left);
          } else if (key == LogicalKeyboardKey.arrowRight) {
            changeDirection(Direction.right);
          } else if (key == LogicalKeyboardKey.select ||
              key == LogicalKeyboardKey.enter) {
            setState(() {
              paused = !paused;
            });
          } else if (key == LogicalKeyboardKey.goBack) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF101A35),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('MENU'),
                    ),
                    const Spacer(),
                    const Text(
                      '🐍 CINGKU SNAKE',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'SKOR: $score',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: columns / rows,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF17254A),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.cyanAccent,
                          width: 3,
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final cellWidth =
                              constraints.maxWidth / columns;

                          final cellHeight =
                              constraints.maxHeight / rows;

                          return Stack(
                            children: [
                              for (final part in snake)
                                Positioned(
                                  left: part.x * cellWidth + 2,
                                  top: part.y * cellHeight + 2,
                                  width: cellWidth - 4,
                                  height: cellHeight - 4,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: part == snake.first
                                          ? Colors.lightGreenAccent
                                          : Colors.green,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                  ),
                                ),

                              Positioned(
                                left: food.x * cellWidth + 2,
                                top: food.y * cellHeight + 2,
                                width: cellWidth - 4,
                                height: cellHeight - 4,
                                child: const Center(
                                  child: Text(
                                    '🍎',
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),

                              if (paused)
                                _centerMessage(
                                  '⏸ PAUSE',
                                  'Tekan OK untuk lanjut',
                                ),

                              if (gameOver)
                                _gameOverMessage(),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(bottom: 18),
                child: Text(
                  'REMOTE: ↑ ↓ ← → GERAKKAN ULAR   •   OK PAUSE',
                  style: TextStyle(
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

  Widget _centerMessage(
    String title,
    String subtitle,
  ) {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gameOverMessage() {
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: ElevatedButton(
            onPressed: startGame,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 22,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'GAME OVER',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'SKOR: $score',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 12),
                const Text('MAIN LAGI'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

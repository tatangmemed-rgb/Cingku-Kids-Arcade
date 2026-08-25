import 'dart:math';
import 'package:flutter/material.dart';

class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  final Random random = Random();

  List<List<int>> board = [];
  int score = 0;
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    newGame();
  }

  void newGame() {
    setState(() {
      board = List.generate(4, (_) => List.filled(4, 0));
      score = 0;
      gameOver = false;
      addRandomTile();
      addRandomTile();
    });
  }

  void addRandomTile() {
    final empty = <Point<int>>[];

    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (board[row][col] == 0) {
          empty.add(Point(row, col));
        }
      }
    }

    if (empty.isEmpty) return;

    final position = empty[random.nextInt(empty.length)];
    board[position.x][position.y] =
        random.nextInt(10) == 0 ? 4 : 2;
  }

  List<int> mergeLine(List<int> line) {
    final numbers = line.where((number) => number != 0).toList();
    final result = <int>[];

    int i = 0;

    while (i < numbers.length) {
      if (i + 1 < numbers.length &&
          numbers[i] == numbers[i + 1]) {
        final merged = numbers[i] * 2;
        result.add(merged);
        score += merged;
        i += 2;
      } else {
        result.add(numbers[i]);
        i++;
      }
    }

    while (result.length < 4) {
      result.add(0);
    }

    return result;
  }

  bool moveLeft() {
    bool changed = false;

    for (int row = 0; row < 4; row++) {
      final oldLine = List<int>.from(board[row]);
      final newLine = mergeLine(oldLine);

      if (!_sameLine(oldLine, newLine)) {
        changed = true;
      }

      board[row] = newLine;
    }

    return changed;
  }

  bool moveRight() {
    bool changed = false;

    for (int row = 0; row < 4; row++) {
      final oldLine = List<int>.from(board[row]);
      final reversed = oldLine.reversed.toList();
      final merged = mergeLine(reversed).reversed.toList();

      if (!_sameLine(oldLine, merged)) {
        changed = true;
      }

      board[row] = merged;
    }

    return changed;
  }

  bool moveUp() {
    bool changed = false;

    for (int col = 0; col < 4; col++) {
      final oldLine =
          List.generate(4, (row) => board[row][col]);

      final newLine = mergeLine(oldLine);

      if (!_sameLine(oldLine, newLine)) {
        changed = true;
      }

      for (int row = 0; row < 4; row++) {
        board[row][col] = newLine[row];
      }
    }

    return changed;
  }

  bool moveDown() {
    bool changed = false;

    for (int col = 0; col < 4; col++) {
      final oldLine =
          List.generate(4, (row) => board[row][col]);

      final reversed = oldLine.reversed.toList();
      final merged = mergeLine(reversed).reversed.toList();

      if (!_sameLine(oldLine, merged)) {
        changed = true;
      }

      for (int row = 0; row < 4; row++) {
        board[row][col] = merged[row];
      }
    }

    return changed;
  }

  bool _sameLine(List<int> a, List<int> b) {
    for (int i = 0; i < 4; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool hasMoves() {
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (board[row][col] == 0) return true;

        if (row < 3 &&
            board[row][col] == board[row + 1][col]) {
          return true;
        }

        if (col < 3 &&
            board[row][col] == board[row][col + 1]) {
          return true;
        }
      }
    }

    return false;
  }

  void move(String direction) {
    if (gameOver) return;

    setState(() {
      bool changed = false;

      if (direction == 'left') {
        changed = moveLeft();
      } else if (direction == 'right') {
        changed = moveRight();
      } else if (direction == 'up') {
        changed = moveUp();
      } else if (direction == 'down') {
        changed = moveDown();
      }

      if (changed) {
        addRandomTile();
      }

      if (!hasMoves()) {
        gameOver = true;
      }
    });
  }

  Color getTileColor(int value) {
    switch (value) {
      case 0:
        return const Color(0xFFCDC1B4);
      case 2:
        return const Color(0xFFEEE4DA);
      case 4:
        return const Color(0xFFEDE0C8);
      case 8:
        return Colors.orangeAccent;
      case 16:
        return Colors.deepOrangeAccent;
      case 32:
        return Colors.redAccent;
      case 64:
        return Colors.red;
      case 128:
        return Colors.amber;
      case 256:
        return Colors.amberAccent;
      case 512:
        return Colors.yellow;
      case 1024:
        return Colors.lightGreen;
      case 2048:
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  Color getTextColor(int value) {
    if (value == 2 || value == 4) {
      return const Color(0xFF776E65);
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8EF),
      appBar: AppBar(
        title: const Text('2048'),
        centerTitle: true,
        backgroundColor: const Color(0xFF776E65),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: newGame,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            final velocity =
                details.primaryVelocity ?? 0;

            if (velocity < -100) {
              move('left');
            } else if (velocity > 100) {
              move('right');
            }
          },
          onVerticalDragEnd: (details) {
            final velocity =
                details.primaryVelocity ?? 0;

            if (velocity < -100) {
              move('up');
            } else if (velocity > 100) {
              move('down');
            }
          },
          child: Column(
            children: [
              const SizedBox(height: 15),

              const Text(
                '🔢 GAME 2048',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF776E65),
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFBBADA0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'SKOR: $score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBBADA0),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: GridView.builder(
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: 16,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemBuilder: (context, index) {
                          final row = index ~/ 4;
                          final col = index % 4;
                          final value = board[row][col];

                          return Container(
                            decoration: BoxDecoration(
                              color: getTileColor(value),
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                value == 0 ? '' : '$value',
                                style: TextStyle(
                                  color: getTextColor(value),
                                  fontSize: value >= 1024
                                      ? 22
                                      : value >= 128
                                          ? 28
                                          : 34,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              if (gameOver)
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'GAME OVER!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  5,
                  20,
                  20,
                ),
                child: const Text(
                  'Geser papan ke kiri, kanan, atas, atau bawah',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF776E65),
                    fontSize: 15,
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

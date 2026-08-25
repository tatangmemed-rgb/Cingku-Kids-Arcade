import 'dart:math';
import 'package:flutter/material.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  final Random _random = Random();

  List<int> tiles = [];
  int moves = 0;
  bool won = false;

  @override
  void initState() {
    super.initState();
    resetGame();
  }

  void resetGame() {
    tiles = List.generate(15, (index) => index + 1);
    tiles.add(0);

    moves = 0;
    won = false;

    for (int i = 0; i < 300; i++) {
      _shuffleOnce();
    }

    setState(() {});
  }

  void _shuffleOnce() {
    final emptyIndex = tiles.indexOf(0);
    final possibleMoves = <int>[];

    final row = emptyIndex ~/ 4;
    final col = emptyIndex % 4;

    if (row > 0) possibleMoves.add(emptyIndex - 4);
    if (row < 3) possibleMoves.add(emptyIndex + 4);
    if (col > 0) possibleMoves.add(emptyIndex - 1);
    if (col < 3) possibleMoves.add(emptyIndex + 1);

    final selected =
        possibleMoves[_random.nextInt(possibleMoves.length)];

    final temp = tiles[selected];
    tiles[selected] = tiles[emptyIndex];
    tiles[emptyIndex] = temp;
  }

  void moveTile(int index) {
    if (won) return;

    final emptyIndex = tiles.indexOf(0);

    if (!_canMove(index, emptyIndex)) {
      return;
    }

    setState(() {
      final temp = tiles[index];
      tiles[index] = tiles[emptyIndex];
      tiles[emptyIndex] = temp;

      moves++;

      if (_checkWin()) {
        won = true;
      }
    });

    if (won) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _showWinDialog();
        }
      });
    }
  }

  bool _canMove(int index, int emptyIndex) {
    final row1 = index ~/ 4;
    final col1 = index % 4;

    final row2 = emptyIndex ~/ 4;
    final col2 = emptyIndex % 4;

    return (row1 == row2 && (col1 - col2).abs() == 1) ||
        (col1 == col2 && (row1 - row2).abs() == 1);
  }

  bool _checkWin() {
    for (int i = 0; i < 15; i++) {
      if (tiles[i] != i + 1) {
        return false;
      }
    }

    return tiles[15] == 0;
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('🎉 Kamu Menang!'),
          content: Text(
            'Puzzle berhasil diselesaikan dalam $moves langkah.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                resetGame();
              },
              child: const Text('MAIN LAGI'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('SELESAI'),
            ),
          ],
        );
      },
    );
  }

  Color _tileColor(int number) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.green,
      Colors.teal,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
    ];

    return colors[(number - 1) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF3E0),
              Color(0xFFFFCC80),
              Color(0xFFFF8A65),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'PUZZLE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: resetGame,
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Susun angka 1 sampai 15 dengan benar!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'LANGKAH: $moves',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 16,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemBuilder: (context, index) {
                          final number = tiles[index];

                          if (number == 0) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            );
                          }

                          return GestureDetector(
                            onTap: () => moveTile(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: _tileColor(number),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '$number',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
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

              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton.icon(
                  onPressed: resetGame,
                  icon: const Icon(Icons.shuffle),
                  label: const Text(
                    'ACAK ULANG',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
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

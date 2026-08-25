import 'dart:math';
import 'package:flutter/material.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  List<int> tiles = [];
  int moves = 0;
  bool won = false;

  @override
  void initState() {
    super.initState();
    resetGame();
  }

  void resetGame() {
    tiles = List.generate(16, (index) => index);
    moves = 0;
    won = false;

    final random = Random();

    for (int i = 0; i < 200; i++) {
      final emptyIndex = tiles.indexOf(0);
      final possibleMoves = <int>[];

      final row = emptyIndex ~/ 4;
      final col = emptyIndex % 4;

      if (row > 0) possibleMoves.add(emptyIndex - 4);
      if (row < 3) possibleMoves.add(emptyIndex + 4);
      if (col > 0) possibleMoves.add(emptyIndex - 1);
      if (col < 3) possibleMoves.add(emptyIndex + 1);

      final selected =
          possibleMoves[random.nextInt(possibleMoves.length)];

      final temp = tiles[emptyIndex];
      tiles[emptyIndex] = tiles[selected];
      tiles[selected] = temp;
    }

    setState(() {});
  }

  bool canMove(int index) {
    final emptyIndex = tiles.indexOf(0);

    final row = index ~/ 4;
    final col = index % 4;
    final emptyRow = emptyIndex ~/ 4;
    final emptyCol = emptyIndex % 4;

    return (row == emptyRow && (col - emptyCol).abs() == 1) ||
        (col == emptyCol && (row - emptyRow).abs() == 1);
  }

  void moveTile(int index) {
    if (won || !canMove(index)) return;

    final emptyIndex = tiles.indexOf(0);

    setState(() {
      final temp = tiles[index];
      tiles[index] = tiles[emptyIndex];
      tiles[emptyIndex] = temp;

      moves++;

      checkWin();
    });
  }

  void checkWin() {
    bool completed = true;

    for (int i = 1; i < 16; i++) {
      if (tiles[i - 1] != i) {
        completed = false;
        break;
      }
    }

    if (tiles[15] != 0) {
      completed = false;
    }

    if (completed) {
      won = true;

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text('🎉 KAMU MENANG!'),
              content: Text(
                'Puzzle berhasil diselesaikan dalam $moves langkah!',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    resetGame();
                  },
                  child: const Text('MAIN LAGI'),
                ),
              ],
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151B2E),
      appBar: AppBar(
        title: const Text('PUZZLE'),
        backgroundColor: const Color(0xFF242B45),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              '🧩 SUSUN ANGKA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'LANGKAH: $moves',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 16,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemBuilder: (context, index) {
                    final number = tiles[index];

                    if (number == 0) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    }

                    final correctPosition = index == number - 1;

                    return InkWell(
                      onTap: () => moveTile(index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: correctPosition
                              ? Colors.green
                              : Colors.blueAccent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 4,
                              offset: Offset(2, 3),
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

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton.icon(
                onPressed: resetGame,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'ACAK ULANG',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

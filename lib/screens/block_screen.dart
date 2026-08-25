import 'dart:math';
import 'package:flutter/material.dart';

class BlockScreen extends StatefulWidget {
  const BlockScreen({super.key});

  @override
  State<BlockScreen> createState() => _BlockScreenState();
}

class _BlockScreenState extends State<BlockScreen> {
  final Random random = Random();

  static const int rows = 8;
  static const int cols = 8;

  List<List<bool>> board = [];
  List<List<List<Point<int>>>> pieces = [];

  int score = 0;
  bool gameOver = false;

  final List<List<Point<int>>> shapes = [
    [const Point(0, 0)],
    [const Point(0, 0), const Point(0, 1)],
    [
      const Point(0, 0),
      const Point(0, 1),
      const Point(0, 2),
    ],
    [
      const Point(0, 0),
      const Point(1, 0),
    ],
    [
      const Point(0, 0),
      const Point(1, 0),
      const Point(2, 0),
    ],
    [
      const Point(0, 0),
      const Point(0, 1),
      const Point(1, 0),
      const Point(1, 1),
    ],
    [
      const Point(0, 0),
      const Point(0, 1),
      const Point(0, 2),
      const Point(1, 1),
    ],
    [
      const Point(0, 0),
      const Point(1, 0),
      const Point(1, 1),
    ],
    [
      const Point(0, 0),
      const Point(0, 1),
      const Point(1, 1),
    ],
  ];

  @override
  void initState() {
    super.initState();
    newGame();
  }

  void newGame() {
    setState(() {
      board = List.generate(
        rows,
        (_) => List.generate(cols, (_) => false),
      );

      score = 0;
      gameOver = false;
      generatePieces();
    });
  }

  void generatePieces() {
    pieces = List.generate(
      3,
      (_) => [List<Point<int>>.from(
            shapes[random.nextInt(shapes.length)],
          )],
    );
  }

  bool canPlace(
    List<Point<int>> piece,
    int startRow,
    int startCol,
  ) {
    for (final block in piece) {
      final row = startRow + block.x;
      final col = startCol + block.y;

      if (row < 0 ||
          row >= rows ||
          col < 0 ||
          col >= cols) {
        return false;
      }

      if (board[row][col]) {
        return false;
      }
    }

    return true;
  }

  void placePiece(
    List<Point<int>> piece,
    int startRow,
    int startCol,
  ) {
    if (!canPlace(piece, startRow, startCol)) return;

    setState(() {
      for (final block in piece) {
        board[startRow + block.x][startCol + block.y] = true;
      }

      score += piece.length;

      clearLines();

      if (pieces.every((pieceList) => pieceList.isEmpty)) {
        generatePieces();
      }

      checkGameOver();
    });
  }

  void clearLines() {
    int cleared = 0;

    for (int row = 0; row < rows; row++) {
      if (board[row].every((cell) => cell)) {
        board[row] = List.generate(cols, (_) => false);
        cleared++;
      }
    }

    for (int col = 0; col < cols; col++) {
      bool full = true;

      for (int row = 0; row < rows; row++) {
        if (!board[row][col]) {
          full = false;
          break;
        }
      }

      if (full) {
        for (int row = 0; row < rows; row++) {
          board[row][col] = false;
        }

        cleared++;
      }
    }

    if (cleared > 0) {
      score += cleared * 10;
    }
  }

  bool canAnyPieceFit() {
    for (final pieceList in pieces) {
      if (pieceList.isEmpty) continue;

      final piece = pieceList.first;

      for (int row = 0; row < rows; row++) {
        for (int col = 0; col < cols; col++) {
          if (canPlace(piece, row, col)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  void checkGameOver() {
    if (!canAnyPieceFit()) {
      gameOver = true;
    }
  }

  Color getBlockColor(int row, int col) {
    if (!board[row][col]) {
      return const Color(0xFFE8EEF7);
    }

    final colors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.pink,
      Colors.red,
    ];

    return colors[(row + col) % colors.length];
  }

  void removePiece(int index) {
    setState(() {
      pieces[index].clear();

      if (pieces.every((piece) => piece.isEmpty)) {
        generatePieces();
      }
    });
  }

  void tryPlaceFromPiece(
    int pieceIndex,
    int row,
    int col,
  ) {
    if (gameOver) return;
    if (pieces[pieceIndex].isEmpty) return;

    final piece = pieces[pieceIndex].first;

    if (canPlace(piece, row, col)) {
      placePiece(piece, row, col);
      removePiece(pieceIndex);
      checkGameOver();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('BLOCK'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: newGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            const Text(
              '🟪 BLOCK GAME',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                'SKOR: $score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: GridView.builder(
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: rows * cols,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
                      ),
                      itemBuilder: (context, index) {
                        final row = index ~/ cols;
                        final col = index % cols;

                        return GestureDetector(
                          onTap: () {
                            int selected = -1;

                            for (
                              int i = 0;
                              i < pieces.length;
                              i++
                            ) {
                              if (pieces[i].isNotEmpty) {
                                selected = i;
                                break;
                              }
                            }

                            if (selected != -1) {
                              tryPlaceFromPiece(
                                selected,
                                row,
                                col,
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: getBlockColor(row, col),
                              borderRadius:
                                  BorderRadius.circular(6),
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
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'GAME OVER! Tekan ↻ untuk bermain lagi.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const Text(
              'Pilih blok, lalu ketuk papan untuk menaruhnya',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  pieces.length,
                  (index) {
                    if (pieces[index].isEmpty) {
                      return const SizedBox(
                        width: 90,
                        height: 90,
                      );
                    }

                    final piece = pieces[index].first;

                    return GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            duration:
                                const Duration(seconds: 1),
                            content: Text(
                              'Blok ${index + 1} dipilih. Ketuk papan.',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.deepPurple,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Wrap(
                            spacing: 3,
                            runSpacing: 3,
                            children: List.generate(
                              piece.length,
                              (_) => Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  borderRadius:
                                      BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';

class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  final Random _random = Random();

  List<List<int>> board =
      List.generate(4, (_) => List.filled(4, 0));

  int score = 0;
  bool gameOver = false;
  bool won = false;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    board = List.generate(4, (_) => List.filled(4, 0));
    score = 0;
    gameOver = false;
    won = false;

    _addRandomTile();
    _addRandomTile();

    if (mounted) {
      setState(() {});
    }
  }

  void _addRandomTile() {
    List<Point<int>> emptyCells = [];

    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (board[row][col] == 0) {
          emptyCells.add(Point(row, col));
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      Point<int> cell =
          emptyCells[_random.nextInt(emptyCells.length)];

      board[cell.x][cell.y] =
          _random.nextInt(10) == 0 ? 4 : 2;
    }
  }

  bool _moveLeft() {
    bool changed = false;

    for (int row = 0; row < 4; row++) {
      List<int> values =
          board[row].where((value) => value != 0).toList();

      List<int> merged = [];

      int i = 0;

      while (i < values.length) {
        if (i + 1 < values.length &&
            values[i] == values[i + 1]) {
          int newValue = values[i] * 2;

          merged.add(newValue);
          score += newValue;

          if (newValue == 2048) {
            won = true;
          }

          i += 2;
        } else {
          merged.add(values[i]);
          i++;
        }
      }

      while (merged.length < 4) {
        merged.add(0);
      }

      for (int col = 0; col < 4; col++) {
        if (board[row][col] != merged[col]) {
          changed = true;
        }

        board[row][col] = merged[col];
      }
    }

    return changed;
  }

  bool _moveRight() {
    for (int row = 0; row < 4; row++) {
      board[row] = board[row].reversed.toList();
    }

    bool changed = _moveLeft();

    for (int row = 0; row < 4; row++) {
      board[row] = board[row].reversed.toList();
    }

    return changed;
  }

  bool _moveUp() {
    bool changed = false;

    for (int col = 0; col < 4; col++) {
      List<int> values = [];

      for (int row = 0; row < 4; row++) {
        if (board[row][col] != 0) {
          values.add(board[row][col]);
        }
      }

      List<int> merged = [];

      int i = 0;

      while (i < values.length) {
        if (i + 1 < values.length &&
            values[i] == values[i + 1]) {
          int newValue = values[i] * 2;

          merged.add(newValue);
          score += newValue;

          if (newValue == 2048) {
            won = true;
          }

          i += 2;
        } else {
          merged.add(values[i]);
          i++;
        }
      }

      while (merged.length < 4) {
        merged.add(0);
      }

      for (int row = 0; row < 4; row++) {
        if (board[row][col] != merged[row]) {
          changed = true;
        }

        board[row][col] = merged[row];
      }
    }

    return changed;
  }

  bool _moveDown() {
    for (int col = 0; col < 4; col++) {
      List<int> column = [];

      for (int row = 0; row < 4; row++) {
        column.add(board[row][col]);
      }

      column = column.reversed.toList();

      for (int row = 0; row < 4; row++) {
        board[row][col] = column[row];
      }
    }

    bool changed = _moveUp();

    for (int col = 0; col < 4; col++) {
      List<int> column = [];

      for (int row = 0; row < 4; row++) {
        column.add(board[row][col]);
      }

      column = column.reversed.toList();

      for (int row = 0; row < 4; row++) {
        board[row][col] = column[row];
      }
    }

    return changed;
  }

  bool _canMove() {
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (board[row][col] == 0) {
          return true;
        }

        if (col < 3 &&
            board[row][col] == board[row][col + 1]) {
          return true;
        }

        if (row < 3 &&
            board[row][col] == board[row + 1][col]) {
          return true;
        }
      }
    }

    return false;
  }

  void _handleMove(String direction) {
    if (gameOver || won) return;

    bool changed = false;

    setState(() {
      if (direction == 'left') {
        changed = _moveLeft();
      } else if (direction == 'right') {
        changed = _moveRight();
      } else if (direction == 'up') {
        changed = _moveUp();
      } else if (direction == 'down') {
        changed = _moveDown();
      }

      if (changed) {
        _addRandomTile();
      }

      if (!_canMove()) {
        gameOver = true;
      }
    });
  }

  Color _tileColor(int value) {
    switch (value) {
      case 0:
        return Colors.grey.shade300;
      case 2:
        return Colors.orange.shade100;
      case 4:
        return Colors.orange.shade200;
      case 8:
        return Colors.deepOrange.shade300;
      case 16:
        return Colors.deepOrange.shade400;
      case 32:
        return Colors.red.shade400;
      case 64:
        return Colors.red.shade600;
      case 128:
        return Colors.purple.shade300;
      case 256:
        return Colors.purple.shade500;
      case 512:
        return Colors.indigo.shade400;
      case 1024:
        return Colors.blue.shade600;
      case 2048:
        return Colors.green.shade600;
      default:
        return Colors.black87;
    }
  }

  Widget _buildTile(int value) {
    return Container(
      decoration: BoxDecoration(
        color: _tileColor(value),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: value == 0
            ? const SizedBox()
            : Text(
                '$value',
                style: TextStyle(
                  fontSize: value >= 1024 ? 22 : 28,
                  fontWeight: FontWeight.bold,
                  color: value <= 4
                      ? Colors.black87
                      : Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _controlButton(
    IconData icon,
    String direction,
  ) {
    return SizedBox(
      width: 65,
      height: 55,
      child: ElevatedButton(
        onPressed: () => _handleMove(direction),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, size: 30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('2048'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              '🔢 GAME 2048',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'SKOR: $score',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Center(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade300,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
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
                        int row = index ~/ 4;
                        int col = index % 4;

                        return _buildTile(board[row][col]);
                      },
                    ),
                  ),
                ),
              ),
            ),

            if (won)
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  '🎉 SELAMAT! KAMU MENCAPAI 2048!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),

            if (gameOver)
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  '😢 GAME OVER!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),

            _controlButton(Icons.keyboard_arrow_up, 'up'),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _controlButton(
                  Icons.keyboard_arrow_left,
                  'left',
                ),
                const SizedBox(width: 70),
                _controlButton(
                  Icons.keyboard_arrow_right,
                  'right',
                ),
              ],
            ),

            const SizedBox(height: 8),

            _controlButton(
              Icons.keyboard_arrow_down,
              'down',
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: 220,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _newGame,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'GAME BARU',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}      final reversed = oldLine.reversed.toList();
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

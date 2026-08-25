import 'dart:math';
import 'package:flutter/material.dart';

class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  final Random _random = Random();

  List<List<int>> _board =
      List.generate(4, (_) => List.filled(4, 0));

  int _score = 0;
  bool _gameOver = false;
  bool _won = false;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    _board = List.generate(4, (_) => List.filled(4, 0));
    _score = 0;
    _gameOver = false;
    _won = false;

    _addRandomTile();
    _addRandomTile();

    if (mounted) setState(() {});
  }

  void _addRandomTile() {
    final empty = <Point<int>>[];

    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (_board[row][col] == 0) {
          empty.add(Point(row, col));
        }
      }
    }

    if (empty.isEmpty) return;

    final cell = empty[_random.nextInt(empty.length)];
    _board[cell.x][cell.y] =
        _random.nextInt(10) == 0 ? 4 : 2;
  }

  List<int> _mergeLine(List<int> line) {
    final values = line.where((value) => value != 0).toList();
    final result = <int>[];

    int i = 0;
    while (i < values.length) {
      if (i + 1 < values.length &&
          values[i] == values[i + 1]) {
        final newValue = values[i] * 2;
        result.add(newValue);
        _score += newValue;

        if (newValue >= 2048) {
          _won = true;
        }

        i += 2;
      } else {
        result.add(values[i]);
        i++;
      }
    }

    while (result.length < 4) {
      result.add(0);
    }

    return result;
  }

  bool _sameLine(List<int> a, List<int> b) {
    for (int i = 0; i < 4; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _moveLeft() {
    bool changed = false;

    for (int row = 0; row < 4; row++) {
      final oldLine = List<int>.from(_board[row]);
      final newLine = _mergeLine(oldLine);

      if (!_sameLine(oldLine, newLine)) {
        changed = true;
      }

      _board[row] = newLine;
    }

    return changed;
  }

  bool _moveRight() {
    bool changed = false;

    for (int row = 0; row < 4; row++) {
      final oldLine = List<int>.from(_board[row]);
      final reversed = oldLine.reversed.toList();
      final merged = _mergeLine(reversed).reversed.toList();

      if (!_sameLine(oldLine, merged)) {
        changed = true;
      }

      _board[row] = merged;
    }

    return changed;
  }

  bool _moveUp() {
    bool changed = false;

    for (int col = 0; col < 4; col++) {
      final oldLine =
          List.generate(4, (row) => _board[row][col]);
      final newLine = _mergeLine(oldLine);

      if (!_sameLine(oldLine, newLine)) {
        changed = true;
      }

      for (int row = 0; row < 4; row++) {
        _board[row][col] = newLine[row];
      }
    }

    return changed;
  }

  bool _moveDown() {
    bool changed = false;

    for (int col = 0; col < 4; col++) {
      final oldLine =
          List.generate(4, (row) => _board[row][col]);
      final reversed = oldLine.reversed.toList();
      final merged = _mergeLine(reversed).reversed.toList();

      if (!_sameLine(oldLine, merged)) {
        changed = true;
      }

      for (int row = 0; row < 4; row++) {
        _board[row][col] = merged[row];
      }
    }

    return changed;
  }

  bool _hasMoves() {
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        if (_board[row][col] == 0) return true;

        if (row < 3 &&
            _board[row][col] == _board[row + 1][col]) {
          return true;
        }

        if (col < 3 &&
            _board[row][col] == _board[row][col + 1]) {
          return true;
        }
      }
    }

    return false;
  }

  void _move(String direction) {
    if (_gameOver || _won) return;

    setState(() {
      bool changed = false;

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

      if (!_hasMoves()) {
        _gameOver = true;
      }
    });
  }

  Color _tileColor(int value) {
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
        return Colors.indigoAccent;
      case 1024:
        return Colors.blueAccent;
      case 2048:
        return Colors.green;
      default:
        return Colors.black87;
    }
  }

  Widget _buildTile(int value) {
    final darkText = value == 2 || value == 4;

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
                  fontSize: value >= 1024 ? 20 : 28,
                  fontWeight: FontWeight.bold,
                  color: darkText
                      ? Colors.black87
                      : Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _controlButton(IconData icon, String direction) {
    return SizedBox(
      width: 64,
      height: 54,
      child: ElevatedButton(
        onPressed: () => _move(direction),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, size: 30),
      ),
    );
  }

  void _handleSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    if (velocity.abs() > 250) {
      _move(velocity > 0 ? 'right' : 'left');
      return;
    }

    final v = details.velocity.pixelsPerSecond;
    if (v.dy.abs() > v.dx.abs() && v.dy.abs() > 250) {
      _move(v.dy > 0 ? 'down' : 'up');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('GAME 2048'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _newGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'SKOR: $_score',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onHorizontalDragEnd: _handleSwipe,
                  onVerticalDragEnd: _handleSwipe,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
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
                          final row = index ~/ 4;
                          final col = index % 4;
                          return _buildTile(_board[row][col]);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (_won)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'SELAMAT! KAMU MENCAPAI 2048!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
            if (_gameOver)
              const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'GAME OVER!',
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
                _controlButton(Icons.keyboard_arrow_left, 'left'),
                const SizedBox(width: 70),
                _controlButton(Icons.keyboard_arrow_right, 'right'),
              ],
            ),
            const SizedBox(height: 8),
            _controlButton(Icons.keyboard_arrow_down, 'down'),
            const SizedBox(height: 16),
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
}

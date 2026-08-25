import 'dart:async';
import 'package:flutter/material.dart';

class BrickBreakerScreen extends StatefulWidget {
  const BrickBreakerScreen({super.key});

  @override
  State<BrickBreakerScreen> createState() => _BrickBreakerScreenState();
}

class _BrickBreakerScreenState extends State<BrickBreakerScreen> {
  Timer? _timer;
  double _ballX = 0;
  double _ballY = 0.45;
  double _ballDX = 0.018;
  double _ballDY = -0.022;
  double _paddleX = 0;

  static const double _paddleWidth = 0.42;
  static const double _paddleY = 0.86;

  int _score = 0;
  bool _started = false;
  bool _gameOver = false;
  bool _won = false;
  List<_Brick> _bricks = [];

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    _timer?.cancel();
    _ballX = 0;
    _ballY = 0.45;
    _ballDX = 0.018;
    _ballDY = -0.022;
    _paddleX = 0;
    _score = 0;
    _started = false;
    _gameOver = false;
    _won = false;

    _bricks = [];
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 6; col++) {
        _bricks.add(
          _Brick(
            x: -0.78 + col * 0.31,
            y: -0.82 + row * 0.14,
            row: row,
          ),
        );
      }
    }

    if (mounted) setState(() {});
  }

  void _startGame() {
    if (_started || _gameOver || _won) return;
    setState(() => _started = true);

    _timer = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _updateGame(),
    );
  }

  void _updateGame() {
    if (!mounted || !_started) return;

    double nextX = _ballX + _ballDX;
    double nextY = _ballY + _ballDY;

    if (nextX <= -0.96 || nextX >= 0.96) {
      _ballDX = -_ballDX;
      nextX = _ballX + _ballDX;
    }

    if (nextY <= -0.96) {
      _ballDY = _ballDY.abs();
      nextY = _ballY + _ballDY;
    }

    if (nextY >= 1.02) {
      _finish(false);
      return;
    }

    if (_ballDY > 0 &&
        nextY >= _paddleY - 0.07 &&
        nextY <= _paddleY + 0.07 &&
        nextX >= _paddleX - _paddleWidth / 2 &&
        nextX <= _paddleX + _paddleWidth / 2) {
      _ballDY = -_ballDY.abs();

      final hit = (nextX - _paddleX) / (_paddleWidth / 2);
      _ballDX = hit * 0.028;

      if (_ballDX.abs() < 0.008) {
        _ballDX = _ballDX < 0 ? -0.008 : 0.008;
      }

      nextY = _paddleY - 0.08;
    }

    for (final brick in _bricks) {
      if (!brick.alive) continue;

      const brickHalfWidth = 0.13;
      const brickHalfHeight = 0.055;

      if (nextX >= brick.x - brickHalfWidth &&
          nextX <= brick.x + brickHalfWidth &&
          nextY >= brick.y - brickHalfHeight &&
          nextY <= brick.y + brickHalfHeight) {
        brick.alive = false;
        _ballDY = -_ballDY;
        _score += 10;
        break;
      }
    }

    if (_bricks.every((brick) => !brick.alive)) {
      _finish(true);
      return;
    }

    setState(() {
      _ballX = nextX;
      _ballY = nextY;
    });
  }

  void _finish(bool playerWon) {
    _timer?.cancel();
    if (!mounted) return;

    setState(() {
      _started = false;
      _won = playerWon;
      _gameOver = !playerWon;
    });
  }

  void _movePaddle(double position) {
    final min = -1 + _paddleWidth / 2;
    final max = 1 - _paddleWidth / 2;

    setState(() {
      _paddleX = position.clamp(min, max).toDouble();
    });
  }

  Color _brickColor(int row) {
    const colors = [
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.yellowAccent,
      Colors.greenAccent,
      Colors.lightBlueAccent,
    ];

    return colors[row % colors.length];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      appBar: AppBar(
        title: const Text('BRICK BREAKER'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              'SKOR: $_score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _startGame,
                      onHorizontalDragUpdate: (details) {
                        final position =
                            (details.localPosition.dx / constraints.maxWidth) *
                                    2 -
                                1;
                        _movePaddle(position);
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF17212B),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white24,
                                width: 2,
                              ),
                            ),
                          ),
                          ..._bricks
                              .where((brick) => brick.alive)
                              .map((brick) {
                            return Positioned(
                              left: ((brick.x + 1) / 2) *
                                      constraints.maxWidth -
                                  45,
                              top: ((brick.y + 1) / 2) *
                                      constraints.maxHeight -
                                  12,
                              child: Container(
                                width: 90,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _brickColor(brick.row),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            );
                          }),
                          Positioned(
                            left: ((_ballX + 1) / 2) *
                                    constraints.maxWidth -
                                10,
                            top: ((_ballY + 1) / 2) *
                                    constraints.maxHeight -
                                10,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            left: ((_paddleX + 1) / 2) *
                                    constraints.maxWidth -
                                (_paddleWidth *
                                    constraints.maxWidth /
                                    4),
                            top: ((_paddleY + 1) / 2) *
                                    constraints.maxHeight -
                                9,
                            child: Container(
                              width: _paddleWidth *
                                  constraints.maxWidth /
                                  2,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.cyanAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          if (!_started && !_gameOver && !_won)
                            const Center(
                              child: Text(
                                'KETUK LAYAR UNTUK MULAI\n\n'
                                'GESER JARI KE KIRI / KANAN',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (_gameOver || _won)
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.black87,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _won
                                          ? 'KAMU MENANG!'
                                          : 'GAME OVER',
                                      style: TextStyle(
                                        color: _won
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Skor: $_score',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _resetGame,
                                      child: const Text('MAIN LAGI'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                _started
                    ? 'Geser jari untuk menggerakkan paddle'
                    : 'Ketuk layar untuk mulai',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Brick {
  final double x;
  final double y;
  final int row;
  bool alive;

  _Brick({
    required this.x,
    required this.y,
    required this.row,
    this.alive = true,
  });
}

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class BrickBreakerScreen extends StatefulWidget {
  const BrickBreakerScreen({super.key});

  @override
  State<BrickBreakerScreen> createState() => _BrickBreakerScreenState();
}

class _BrickBreakerScreenState extends State<BrickBreakerScreen> {
  final Random random = Random();

  double ballX = 0;
  double ballY = 0;
  double ballDX = 0.018;
  double ballDY = -0.025;

  double paddleX = 0;
  final double paddleWidth = 0.35;

  int score = 0;
  bool gameStarted = false;
  bool gameOver = false;
  bool gameWon = false;

  late List<Brick> bricks;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    resetGame();
  }

  void resetGame() {
    timer?.cancel();

    ballX = 0;
    ballY = 0.5;
    ballDX = 0.018;
    ballDY = -0.025;

    paddleX = 0;
    score = 0;
    gameStarted = false;
    gameOver = false;
    gameWon = false;

    bricks = [];

    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 7; col++) {
        bricks.add(
          Brick(
            x: -0.84 + (col * 0.28),
            y: -0.82 + (row * 0.16),
            alive: true,
          ),
        );
      }
    }

    setState(() {});
  }

  void startGame() {
    if (gameStarted || gameOver || gameWon) return;

    setState(() {
      gameStarted = true;
    });

    timer = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => updateGame(),
    );
  }

  void updateGame() {
    if (!mounted) return;

    double newX = ballX + ballDX;
    double newY = ballY + ballDY;

    // Dinding kiri dan kanan
    if (newX <= -0.95 || newX >= 0.95) {
      ballDX = -ballDX;
      newX = ballX + ballDX;
    }

    // Dinding atas
    if (newY <= -0.95) {
      ballDY = -ballDY;
      newY = ballY + ballDY;
    }

    // Bola jatuh
    if (newY >= 1.0) {
      finishGame(false);
      return;
    }

    // Pantulan paddle
    const paddleY = 0.84;

    if (ballDY > 0 &&
        newY >= paddleY - 0.06 &&
        newY <= paddleY + 0.06 &&
        newX >= paddleX - paddleWidth / 2 &&
        newX <= paddleX + paddleWidth / 2) {
      ballDY = -ballDY.abs();

      double hitPosition = (newX - paddleX) / (paddleWidth / 2);
      ballDX = hitPosition * 0.025;

      if (ballDX.abs() < 0.008) {
        ballDX = ballDX < 0 ? -0.008 : 0.008;
      }

      newY = paddleY - 0.07;
    }

    // Tabrakan dengan bata
    for (final brick in bricks) {
      if (!brick.alive) continue;

      const brickWidth = 0.115;
      const brickHeight = 0.055;

      if (newX >= brick.x - brickWidth &&
          newX <= brick.x + brickWidth &&
          newY >= brick.y - brickHeight &&
          newY <= brick.y + brickHeight) {
        brick.alive = false;
        ballDY = -ballDY;
        score += 10;
        break;
      }
    }

    // Menang
    if (bricks.every((brick) => !brick.alive)) {
      finishGame(true);
      return;
    }

    setState(() {
      ballX = newX;
      ballY = newY;
    });
  }

  void finishGame(bool won) {
    timer?.cancel();

    setState(() {
      gameStarted = false;
      gameOver = !won;
      gameWon = won;
    });
  }

  void movePaddle(double position) {
    if (position < -1 + paddleWidth / 2) {
      position = -1 + paddleWidth / 2;
    }

    if (position > 1 - paddleWidth / 2) {
      position = 1 - paddleWidth / 2;
    }

    setState(() {
      paddleX = position;
    });
  }

  Color brickColor(int index) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ];

    return colors[index % colors.length];
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      appBar: AppBar(
        title: const Text('BRICK BREAKER'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetGame,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            Text(
              'SKOR: $score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: GestureDetector(
                onTap: startGame,
                onHorizontalDragUpdate: (details) {
                  final width = MediaQuery.of(context).size.width;

                  double position =
                      (details.localPosition.dx / width) * 2 - 1;

                  movePaddle(position);
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        // Area permainan
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF17212B),
                            border: Border.all(
                              color: Colors.white24,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        // Bata
                        ...bricks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final brick = entry.value;

                          if (!brick.alive) {
                            return const SizedBox.shrink();
                          }

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
                                color: brickColor(index ~/ 7),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: brickColor(index ~/ 7)
                                        .withOpacity(0.4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        // Bola
                        Positioned(
                          left: ((ballX + 1) / 2) *
                                  constraints.maxWidth -
                              10,
                          top: ((ballY + 1) / 2) *
                                  constraints.maxHeight -
                              10,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white54,
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Paddle
                        Positioned(
                          left: ((paddleX + 1) / 2) *
                                  constraints.maxWidth -
                              (paddleWidth / 2) *
                                  constraints.maxWidth / 2,
                          top: 0.92 * constraints.maxHeight,
                          child: Container(
                            width: paddleWidth *
                                constraints.maxWidth / 2,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.cyanAccent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.cyanAccent,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Tampilan awal
                        if (!gameStarted &&
                            !gameOver &&
                            !gameWon)
                          const Center(
                            child: Text(
                              'KETUK LAYAR UNTUK MULAI\n\nGESER JARI UNTUK MENGGERAKKAN PADDLE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        // Game over
                        if (gameOver)
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
                                  const Text(
                                    'GAME OVER',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Skor: $score',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: resetGame,
                                    child: const Text('MAIN LAGI'),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Menang
                        if (gameWon)
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
                                  const Text(
                                    '🎉 KAMU MENANG! 🎉',
                                    style: TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Skor akhir: $score',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: resetGame,
                                    child: const Text('MAIN LAGI'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                gameStarted
                    ? 'Geser jari ke kiri atau kanan'
                    : 'Ketuk area permainan untuk mulai',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
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

class Brick {
  double x;
  double y;
  bool alive;

  Brick({
    required this.x,
    required this.y,
    required this.alive,
  });
}    }

    // Pantulan paddle
    if (ballDY > 0 &&
        nextY >= 0.78 &&
        nextY <= 0.92 &&
        nextX >= paddleX - paddleWidth / 2 &&
        nextX <= paddleX + paddleWidth / 2) {
      ballDY = -ballDY.abs();

      double hitPosition = (nextX - paddleX) / (paddleWidth / 2);
      ballDX += hitPosition * 0.006;

      if (ballDX > 0.032) ball

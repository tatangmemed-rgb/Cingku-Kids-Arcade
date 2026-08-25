import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SpaceScreen extends StatefulWidget {
  const SpaceScreen({super.key});

  @override
  State<SpaceScreen> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends State<SpaceScreen> {
  Timer? _timer;
  final Random _random = Random();

  double playerX = 0;
  double enemyX = 0;
  double enemyY = -0.8;

  int score = 0;
  bool started = false;
  bool gameOver = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startGame() {
    _timer?.cancel();

    setState(() {
      playerX = 0;
      enemyX = _random.nextDouble() * 1.6 - 0.8;
      enemyY = -0.8;
      score = 0;
      started = true;
      gameOver = false;
    });

    _timer = Timer.periodic(
      const Duration(milliseconds: 35),
      (timer) {
        if (!mounted || gameOver) {
          timer.cancel();
          return;
        }

        setState(() {
          enemyY += 0.018 + (score * 0.0003);

          if (enemyY > 1.15) {
            score++;
            enemyY = -0.9;
            enemyX = _random.nextDouble() * 1.6 - 0.8;
          }

          if ((enemyY - 0.78).abs() < 0.16 &&
              (enemyX - playerX).abs() < 0.22) {
            gameOver = true;
            timer.cancel();
          }
        });
      },
    );
  }

  void moveLeft() {
    if (!started || gameOver) return;

    setState(() {
      playerX -= 0.18;
      if (playerX < -0.85) playerX = -0.85;
    });
  }

  void moveRight() {
    if (!started || gameOver) return;

    setState(() {
      playerX += 0.18;
      if (playerX > 0.85) playerX = 0.85;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B20),
      appBar: AppBar(
        title: const Text('SPACE'),
        backgroundColor: const Color(0xFF0B1638),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (!started || gameOver) return;

                    setState(() {
                      playerX +=
                          details.delta.dx / constraints.maxWidth * 2;

                      if (playerX < -0.85) playerX = -0.85;
                      if (playerX > 0.85) playerX = 0.85;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1230),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.blueAccent,
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        for (int i = 0; i < 35; i++)
                          Positioned(
                            left: (i * 73.0) %
                                (constraints.maxWidth - 10),
                            top: (i * 113.0) %
                                (constraints.maxHeight - 10),
                            child: const Icon(
                              Icons.star,
                              size: 5,
                              color: Colors.white54,
                            ),
                          ),

                        Align(
                          alignment: Alignment(enemyX, enemyY),
                          child: const Icon(
                            Icons.rocket_launch,
                            color: Colors.redAccent,
                            size: 52,
                          ),
                        ),

                        Align(
                          alignment: Alignment(playerX, 0.82),
                          child: const Icon(
                            Icons.airplanemode_active,
                            color: Colors.cyanAccent,
                            size: 60,
                          ),
                        ),

                        if (!started)
                          Center(
                            child: ElevatedButton(
                              onPressed: startGame,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 18,
                                ),
                              ),
                              child: const Text(
                                'MULAI GAME',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        if (gameOver)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.redAccent,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'GAME OVER!',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Skor: $score',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: startGame,
                                    child: const Text('MAIN LAGI'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: moveLeft,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 60),
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Icon(Icons.arrow_back, size: 32),
                ),
                const SizedBox(width: 40),
                ElevatedButton(
                  onPressed: moveRight,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 60),
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Icon(Icons.arrow_forward, size: 32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

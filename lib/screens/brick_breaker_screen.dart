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

  Timer? timer;

  double ballX = 0;
  double ballY = 0.5;

  double ballDX = 0.018;
  double ballDY = -0.018;

  double paddleX = 0;
  final double paddleWidth = 0.32;

  final int rows = 5;
  final int columns = 7;

  List<bool> bricks = [];

  int score = 0;
  bool gameStarted = false;
  bool gameOver = false;
  bool gameWon = false;

  @override
  void initState() {
    super.initState();
    _createBricks();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _createBricks() {
    bricks = List<bool>.filled(rows * columns, true);
  }

  void startGame() {
    timer?.cancel();

    setState(() {
      ballX = 0;
      ballY = 0.55;

      ballDX = random.nextBool() ? 0.018 : -0.018;
      ballDY = -0.018;

      paddleX = 0;

      score = 0;
      gameOver = false;
      gameWon = false;
      gameStarted = true;

      _createBricks();
    });

    timer = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _updateGame(),
    );
  }

  void _updateGame() {
    if (!gameStarted || gameOver || gameWon) return;

    double nextX = ballX + ballDX;
    double nextY = ballY + ballDY;

    // Dinding kiri dan kanan
    if (nextX <= -0.96 || nextX >= 0.96) {
      ballDX = -ballDX;
      nextX = ballX + ballDX;
    }

    // Dinding atas
    if (nextY <= -0.96) {
      ballDY = -ballDY;
      nextY = ballY + ballDY;
    }

    // Bola jatuh
    if (nextY >= 1.05) {
      _finishGame(false);
      return;
    }

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

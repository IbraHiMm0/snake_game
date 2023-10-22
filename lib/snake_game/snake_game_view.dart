import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../helper/enum.dart';
import 'SnakePointer.dart';

class SnakeGameView extends StatefulWidget {
  const SnakeGameView({super.key});

  @override
  State<SnakeGameView> createState() => _SnakeGameViewState();
}

class _SnakeGameViewState extends State<SnakeGameView> {
  late List<Offset> snake;
  late Offset food;
  late Direction direction;
  int count=0;

  bool gameOver = false;

  final double tileDimension = 20;
  final int gameSpeed = 8;

  late Timer timer;

  void _handleSwipe(DragUpdateDetails details) {
    final dx = details.delta.dx;
    final dy = details.delta.dy;
    if (dx.abs() > dy.abs()) {
      if (dx > 0) {
        setState(() => direction = Direction.right);
      } else {
        setState(() => direction = Direction.left);
      }
    } else {
      if (dy > 0) {
        setState(() => direction = Direction.down);
      } else {
        setState(() => direction = Direction.up);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // ignore: deprecated_member_use
    window.onKeyData = (final keyData) {
      if (keyData.logical == LogicalKeyboardKey.arrowRight.keyId) {
        setState(() => direction = Direction.right);
      }
      if (keyData.logical == LogicalKeyboardKey.arrowLeft.keyId) {
        setState(() => direction = Direction.left);
      }
      if (keyData.logical == LogicalKeyboardKey.arrowUp.keyId) {
        setState(() => direction = Direction.up);
      }
      if (keyData.logical == LogicalKeyboardKey.arrowDown.keyId) {
        setState(() => direction = Direction.down);
      }
      if (keyData.logical == LogicalKeyboardKey.space.keyId) {
        setState(() {
          gameOver = false;
          initGame();
        });
      }
      return false;
    };

    initGame();
  }

  bool snakeLeftViewport() {
    final head = snake[0];
    if (head.dx < 0 || head.dy < 0) return true;

    // ignore: deprecated_member_use
    var logicalScreenSize = window.physicalSize / window.devicePixelRatio;
    var width = logicalScreenSize.width;
    var height = logicalScreenSize.height;

    if (head.dx > width ~/ tileDimension || head.dy > height ~/ tileDimension) {
      return true;
    }
    return false;
  }

  void setGameOver() {
    setState(() {
      gameOver = true;
      timer.cancel();
    });
  }

  void initGame() {
    debugPrint('Game Over');
    setState(() {
      snake = [const Offset(10, 10)];
      food = const Offset(15, 15);
      direction = Direction.right;
    });

    timer = Timer.periodic(Duration(milliseconds: 1000 ~/ gameSpeed), (timer) {
      if (snakeLeftViewport()) {
        setGameOver();
      }

      setState(() {
        Offset head = snake.last;
        switch (direction) {
          case Direction.up:
            moveSnakeToOffset(offset: Offset(head.dx, head.dy - 1));
            break;
          case Direction.down:
            moveSnakeToOffset(offset: Offset(head.dx, head.dy + 1));
            break;
          case Direction.left:
            moveSnakeToOffset(offset: Offset(head.dx - 1, head.dy));
            break;
          case Direction.right:
            moveSnakeToOffset(offset: Offset(head.dx + 1, head.dy));
            break;
        }
        final Random random = Random();
        // ignore: deprecated_member_use
        var logicalScreenSize = window.physicalSize / window.devicePixelRatio;
        var width = logicalScreenSize.width;
        var height = logicalScreenSize.height;

        if (snake.last == food) {
          score();
          food = Offset(
            random.nextInt(width ~/ tileDimension).toDouble(),
            random.nextInt(height ~/ tileDimension).toDouble(),
          );
        } else {
          snake.removeAt(0);
        }
      });
    });
  }
    void score(){
        count++;
    }
  void moveSnakeToOffset({required Offset offset}) {
    if (snake.contains(offset)) {
      setGameOver();
      return;
    }
    snake.add(offset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: _handleSwipe,
        onVerticalDragUpdate: _handleSwipe,
        child: Stack(
          children: [
            Container(
              color: Colors.black,
              child: CustomPaint(
                painter: SnakePainter(
                  snake,
                  food,
                  tileDimension,
                ),
              ),
            ),
            if (gameOver)
              Center(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5,
                    sigmaY: 5,
                  ),
                  child: Container(
                    width: 300,
                    height: 250,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          gameOver = false;
                          initGame();
                          count=0;
                        });
                      },
                      child:  Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            'Game Over',
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                            ),
                          ),
                          Text('Your Score is : $count',style: const TextStyle(
                            fontSize: 26,
                            color: Colors.white,
                          ),),
                          const SizedBox(height: 10),
                          const Text(
                            kIsWeb
                                ? 'Press Enter to play again'
                                : 'Click to play again',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Container()
          ],
        ),
      ),
    );
  }
}
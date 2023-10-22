import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SnakePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;
  final double tileDimension;

  SnakePainter(
      this.snake,
      this.food,
      this.tileDimension,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final snakepaint = Paint()
      ..color = Colors.green

      ..style = PaintingStyle.fill;

    final foodPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    for (int i = snake.length - 1; i >= 0; i--) {
      Offset offset = snake[i];
      canvas.drawRect(
        Rect.fromLTWH(
          offset.dx * tileDimension,
          offset.dy * tileDimension,
          tileDimension,
          tileDimension,
        ),
        snakepaint,
      );
    }

    canvas.drawRect(
      Rect.fromLTWH(
        food.dx * tileDimension,
        food.dy * tileDimension,
        tileDimension,
        tileDimension,
      ),
      foodPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
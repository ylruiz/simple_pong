import 'package:flutter/material.dart';

import 'ball.dart';
import 'bat.dart';

enum Direction { up, down, left, right }

class Pong extends StatefulWidget {
  @override
  _PongState createState() => _PongState();
}

class _PongState extends State<Pong> with SingleTickerProviderStateMixin {
  double width;
  double height;
  double posX = 0;
  double posY = 0;
  double batWidth = 0;
  double batHeight = 0;
  double batPosition = 0;
  double increment = 5;

  Animation<double> animation;
  AnimationController controller;

  Direction vDir = Direction.down;
  Direction hDir = Direction.right;

  @override
  void initState() {
    posX = 0;
    posY = 0;
    controller = AnimationController(
      duration: const Duration(seconds: 10000),
      vsync: this,
    );
    animation = Tween<double>(begin: 0, end: 100).animate(controller);
    animation.addListener(() {
      safeSetState(() {
        (hDir == Direction.right) ? posX += increment : posX -= increment;
        (vDir == Direction.down) ? posY += increment : posY -= increment;
      });
      checkBorders();
    });
    controller.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        width = constraints.maxWidth;
        height = constraints.maxHeight;
        batWidth = width / 5;
        batHeight = height / 20;

        return Stack(
          children: <Widget>[
            Positioned(
              child: Ball(),
              top: posY,
              left: posX,
            ),
            Positioned(
              child: GestureDetector(
                child: Bat(batWidth, batHeight),
                onHorizontalDragUpdate: (DragUpdateDetails update) =>
                    moveBat(update),
              ),
              bottom: 0,
              left: batPosition,
            ),
          ],
        );
      },
    );
  }

  void checkBorders() {
    double diameter = 50;
    if (posX <= 0 && hDir == Direction.left) {
      hDir = Direction.right;
    }
    if (posX >= (width - diameter) && hDir == Direction.right) {
      hDir = Direction.left;
    }
    if (posY >= (height - diameter) && vDir == Direction.down) {
      if (posX >= (batPosition - diameter) &&
          posX <= (batPosition + batWidth + diameter)) {
        vDir = Direction.up;
      } else {
        controller.stop();
        dispose();
      }
    }
    if (posY <= 0 && vDir == Direction.up) {
      vDir = Direction.down;
    }
  }

  void moveBat(DragUpdateDetails update) {
    safeSetState(() {
      batPosition += update.delta.dx;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void safeSetState(Function function) {
    if (mounted && controller.isAnimating) {
      setState(() {
        function();
      });
    }
  }
}

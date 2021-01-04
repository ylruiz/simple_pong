import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

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
  double randX = 1;
  double randY = 1;
  int score = 0;

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
        (hDir == Direction.right) ? posX += ((increment * randX).round()) : posX -= ((increment * randX).round());
        (vDir == Direction.down) ? posY += ((increment * randY).round()) : posY -= ((increment * randY).round());
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
              child: Text('Score: $score'),
              top: 10,
              right: 24,
            ),
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
      randX = randomNumber();
    }
    if (posX >= (width - diameter) && hDir == Direction.right) {
      hDir = Direction.left;
      randX = randomNumber();
    }
    if (posY >= (height - diameter - batHeight) && vDir == Direction.down) {
      if (posX >= (batPosition - diameter) &&
          posX <= (batPosition + batWidth + diameter)) {
        vDir = Direction.up;
        randY = randomNumber();
        safeSetState(() {
          score++;
        });
      } else {
        controller.stop();
        showMessage(context);
      }
    }
    if (posY <= 0 && vDir == Direction.up) {
      vDir = Direction.down;
      randY = randomNumber();
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

  double randomNumber() {
    // this is a number between 0.5 and 1.5
    var ran = new Random();
    int myNum = ran.nextInt(101);
    return (50 + myNum) / 100;
  }

  void showMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: Text('Would you like to play again?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                setState(() {
                  posX = 0;
                  posY = 0;
                  score = 0;
                });
                Navigator.of(context).pop();
                controller.repeat();
              }, 
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              }, 
            ),
          ],
        );
      }
    );
  }
}

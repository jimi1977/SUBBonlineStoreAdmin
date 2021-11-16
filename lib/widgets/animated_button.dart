import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  @override
  _AnimatedButtonState createState() => _AnimatedButtonState(onTapAction,icon);

  final Function onTapAction;
  final Icon icon;

  AnimatedButton({this.onTapAction, this.icon});
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  double _scale;
  AnimationController _controller;
  final Function onTapAction;
  final Icon icon;


  _AnimatedButtonState(this.onTapAction, this.icon);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.5,
    )..addListener(() {
      setState(() {

      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
      onTapAction();
    _controller.forward();

  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,

      child: Transform.scale(
        scale: _scale,
        child: _animatedButtonUI,
      ),
    );
  }

  Widget get _animatedButtonUI => Container(

    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(0),
//       boxShadow: [
//        BoxShadow(
//          color: Color(0x80000000),
//          blurRadius: 7.0,
//          offset: Offset(0.0, 5.0),
//        ),
//      ],
     /* gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFD7465),
          Color(0xFFFD7465),
        ],
      ),*/
    ),
    child: Center(
      child:  icon
    ),
  );
}
/*
Container(
    height: 30,
    width: 100,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(0),
      boxShadow: [
        BoxShadow(
          color: Color(0x80000000),
          blurRadius: 30.0,
          offset: Offset(0.0, 5.0),
        ),
      ],
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFD7465),
          Color(0xFFFD7465),
        ],
      ),
    ),
    child: Center(
      child: Text(
        "ADD TO CART",
        textAlign: TextAlign.start,
        style: TextStyle(
            fontFamily: 'Montserrat',
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12.0),
      ),
    ),
  );
 */
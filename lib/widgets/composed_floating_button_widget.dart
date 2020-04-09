import 'package:flutter/material.dart';
import 'dart:math';

class ComposedFloatingButton extends StatefulWidget {
  final List<IconData> icons;
  final List<Function> functions;
  final List<dynamic> parameters;

  const ComposedFloatingButton(
      {Key key,
      @required this.icons,
      @required this.functions,
      @required this.parameters})
      : super(key: key);

  @override
  State createState() => new ComposedFloatingButtonState();
}

class ComposedFloatingButtonState extends State<ComposedFloatingButton>
    with TickerProviderStateMixin {
  AnimationController _animationController;

  /*static const List<IconData> icons = const [
    Icons.sms,
    Icons.mail,
    Icons.phone,
    Icons.add
  ];*/

  @override
  void initState() {
    if (widget.icons.length != widget.functions.length) {
      throw Exception("Invalid widget parameters.");
    }
    _animationController = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).cardColor;
    Color foregroundColor = Theme.of(context).accentColor;
    return new Column(
      mainAxisSize: MainAxisSize.min,
      // Generate list of floating buttons
      children: new List.generate(widget.icons.length, (int index) {
        Widget child = new Container(
          height: 70.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: new ScaleTransition(
            scale: new CurvedAnimation(
              parent: _animationController,
              curve: new Interval(0.0, 1.0 - index / widget.icons.length / 2.0,
                  curve: Curves.easeOut),
            ),
            child: new FloatingActionButton(
              heroTag: null,
              backgroundColor: backgroundColor,
              mini: true,
              child: new Icon(widget.icons[index], color: foregroundColor),
              onPressed: () => widget.functions[index](widget.parameters[index]),
            ),
          ),
        );
        return child;
      }).toList()
        ..add(
          // Generate principal floating button
          new FloatingActionButton(
            heroTag: null,
            child: new AnimatedBuilder(
              animation: _animationController,
              builder: (BuildContext context, Widget child) {
                return new Transform(
                  transform: new Matrix4.rotationZ(
                      _animationController.value * 0.5 * pi),
                  alignment: FractionalOffset.center,
                  child: new Icon(_animationController.isDismissed
                      ? Icons.add
                      : Icons.close),
                );
              },
            ),
            onPressed: () {
              if (_animationController.isDismissed) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            },
          ),
        ),
    );
  }
}

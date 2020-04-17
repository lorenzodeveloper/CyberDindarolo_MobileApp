import 'package:flutter/material.dart';

abstract class BlocBase{
  void dispose();
}

class BlocProvider<T extends BlocBase> extends StatefulWidget{

  BlocProvider({
    Key key,
    @required this.child,
    @required this.bloc,
  }): super(key: key);

  final T bloc;
  final Widget child;

  @override
  _BlocProviderState createState () => _BlocProviderState<T>();

  static T of<T extends BlocBase>(BuildContext context){
    //final type = _typeOf<BlocProvider<T>>();
    BlocProvider<T> provider = context.findAncestorWidgetOfExactType();

    if (provider.bloc == null) {
      throw FlutterError(
          'BlocProvider.of() called with a context that does not contain a Bloc of type $T.\n'
              'No $T ancestor could be found starting from the context that was passed '
              'to BlocProvider.of(). This can happen '
              'if the context you use comes from a widget above your Bloc.\n'
              'The context used was:\n'
              '  $context'
      );
    }

    return provider.bloc;
  }

  //static Type _typeOf<T>() => T;

}

class _BlocProviderState<T> extends State<BlocProvider<BlocBase>>{

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }

}
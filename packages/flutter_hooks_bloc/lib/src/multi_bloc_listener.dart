import 'bloc_listener.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class MultiBlocListener extends HookWidget {
  const MultiBlocListener({this.listeners, this.child})
      : assert(listeners != null),
        assert(child != null);

  final List<BlocListenableBase> listeners;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    listeners.forEach((it) => it.listen());
    return child;
  }
}

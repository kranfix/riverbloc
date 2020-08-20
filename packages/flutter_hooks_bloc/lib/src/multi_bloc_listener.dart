import 'bloc_listener.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class MultiBlocListener extends HookWidget {
  MultiBlocListener({@required this.listeners, @required this.child})
      : assert(listeners != null),
        assert(listeners.isNotEmpty),
        assert(listeners.debugBlocListenerWithNoChild()),
        assert(child != null);

  final List<BlocListenableBase> listeners;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    listeners.forEach((it) => it.listen());
    return child;
  }
}

extension _DebugBlocListenerWithNoChildX on List<BlocListenableBase> {
  @visibleForTesting
  bool debugBlocListenerWithNoChild() =>
      fold(true, (prev, it) => prev && it.hasNoChild);
}

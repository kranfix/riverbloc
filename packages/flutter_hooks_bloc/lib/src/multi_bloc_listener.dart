import 'bloc_listener.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// {@template multi_bloc_listener}
/// Merges multiple [BlocListener] widgets into one widget tree.
///
/// [MultiBlocListener] improves the readability and eliminates the need
/// to nest multiple [BlocListener]s.
///
/// By using [MultiBlocListener] we can go from:
///
/// ```dart
/// BlocListener<BlocA, BlocAState>(
///   listener: (context, state) {},
///   child: BlocListener<BlocB, BlocBState>(
///     listener: (context, state) {},
///     child: BlocListener<BlocC, BlocCState>(
///       listener: (context, state) {},
///       child: ChildA(),
///     ),
///   ),
/// )
/// ```
///
/// to:
///
/// ```dart
/// MultiBlocListener(
///   listeners: [
///     BlocListener<BlocA, BlocAState>(
///       listener: (context, state) {},
///     ),
///     BlocListener<BlocB, BlocBState>(
///       listener: (context, state) {},
///     ),
///     BlocListener<BlocC, BlocCState>(
///       listener: (context, state) {},
///     ),
///   ],
///   child: ChildA(),
/// )
/// ```
///
/// In addition, [BlocListenable] can replace [BlocListener] but it has a
/// lighter implementation. Also
///
/// ```dart
/// MultiBlocListener(
///   listeners: [
///     BlocListenable<BlocA, BlocAState>(
///       listener: (context, state) {},
///     ),
///     BlocListener<BlocB, BlocBState>(
///       listener: (context, state) {},
///     ),
///   ],
///   child: ChildA(),
/// )
/// ```
///
/// [MultiBlocListener] avoids converts a tree of nested [BlocListener] and
/// only add a widget to the widget tree.
/// As a result, the only advantages of using [MultiBlocListener] are both the
/// reduce of widgets in the widget tree and better readability due to the
/// reduction in nesting and boilerplate.
/// {@endtemplate}
class MultiBlocListener extends HookWidget {
  /// {@macro multi_bloc_listener}
  MultiBlocListener({@required this.listeners, @required this.child})
      : assert(listeners != null),
        assert(listeners.isNotEmpty),
        assert(listeners._debugBlocListenerWithNoChild()),
        assert(child != null);

  final List<NesteableBlocListener> listeners;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    listeners.forEach((it) => it.listen());
    return child;
  }
}

extension _DebugBlocListenerWithNoChildX on List<NesteableBlocListener> {
  bool _debugBlocListenerWithNoChild() => every((it) => it.hasNoChild);
}

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:flutter_hooks_bloc/src/bloc_listener.dart';
import 'package:flutter_hooks_bloc/src/flutter_bloc.dart';

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
/// [MultiBlocListener] avoids converts a tree of nested [BlocListener] and
/// only add a widget to the widget tree.
/// As a result, the only advantages of using [MultiBlocListener] are both the
/// reduce of widgets in the widget tree and better readability due to the
/// reduction in nesting and boilerplate.
/// {@endtemplate}
class MultiBlocListener extends HookWidget {
  /// {@macro multi_bloc_listener}
  MultiBlocListener({Key? key, required this.listeners, required this.child})
      : assert(
          listeners.isNotEmpty,
          'MultiBlocListener must have at least one provider',
        ),
        assert(
          listeners._debugBlocListenerWithNoChild(),
          'Providers in MultiBlocListener must not have any child',
        ),
        super(key: key);

  /// List of [BlocListener] and/or  [NestableBlocListener].
  /// Must have at least one element
  final List<NestableBlocListener> listeners;

  /// `child` [Widget] for [MultiBlocListener]
  final Widget child;

  @override
  Widget build(BuildContext context) {
    for (final it in listeners) {
      it.listen();
    }
    return child;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      BlocListenerTree(listeners: listeners).toDiagnosticsNode(
        name: 'listeners',
        style: DiagnosticsTreeStyle.dense,
      ),
    );
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() =>
      [for (final listener in listeners) listener.asDiagnosticsNode()];
}

/// The [NestableBlocListener] is the base for every item in a
/// [MultiBlocProvider]. Thus, the bloc listener is not limited to be a
/// [BlocListener], but can another type.
///
/// see also
/// - [MultiBlocListener]
abstract class NestableBlocListener {
  /// The `listen` method describe how a widget must listen a [BlocBase]
  void listen();

  /// Given that the [NestableBlocListener] are used in a [MultiBlocProvider]
  /// The must not have a child each one. Then, the `hasNoChild` allows
  /// the [MultiBlocProvider] to check that they don't have them.
  bool get hasNoChild;

  /// Generates a [DiagnosticsNode] for show the `bloc` states in the debugger.
  DiagnosticsNode asDiagnosticsNode();
}

extension _DebugBlocListenerWithNoChildX on List<NestableBlocListener> {
  bool _debugBlocListenerWithNoChild() => every((it) => it.hasNoChild);
}

/// {@template bloc_listener_tree}
/// The [BlocListenerTree] is a [DiagnosticableTree] for showwing
/// the `bloc` providers in the devtools.
/// {@endtemplate}
@visibleForTesting
class BlocListenerTree extends DiagnosticableTree {
  /// {@macro bloc_listener_tree}
  const BlocListenerTree({required this.listeners});

  /// List of [NestableBlocListener] ([BlocListener] for example) that
  /// will be used in the [MultiBlocListener].
  final List<NestableBlocListener> listeners;

  @override
  List<DiagnosticsNode> debugDescribeChildren() =>
      [for (final listener in listeners) listener.asDiagnosticsNode()];
}

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
/// [MultiBlocListener] converts a tree of nested [BlocListener] widgets into
/// a flat list, adding only one widget to the widget tree.
/// The advantages of using [MultiBlocListener] are fewer widgets in the widget
/// tree and better readability due to reduced nesting and boilerplate.
/// {@endtemplate}
class MultiBlocListener extends HookWidget {
  /// {@macro multi_bloc_listener}
  MultiBlocListener({required this.listeners, required this.child, super.key})
      : assert(
          listeners.isNotEmpty,
          'MultiBlocListener must have at least one BlocListener',
        ),
        assert(
          listeners._debugBlocListenerWithNoChild(),
          'BlocListener must have no child in a MultiBlocListener',
        );

  /// List of [BlocListener] and/or [NestableBlocListener].
  /// Must have at least one element.
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
/// [MultiBlocListener]. Thus, the bloc listener is not limited to be a
/// [BlocListener], but can be another type.
///
/// See also:
/// - [MultiBlocListener]
abstract class NestableBlocListener {
  /// Describes how a widget must listen to a [BlocBase].
  void listen();

  /// Given that [NestableBlocListener]s are used in a [MultiBlocListener],
  /// they must not each have a child. The `hasNoChild` property allows
  /// [MultiBlocListener] to verify this.
  bool get hasNoChild;

  /// Generates a [DiagnosticsNode] for showing the `bloc` state
  /// in the debugger.
  DiagnosticsNode asDiagnosticsNode();
}

extension _DebugBlocListenerWithNoChildX on List<NestableBlocListener> {
  bool _debugBlocListenerWithNoChild() => every((it) => it.hasNoChild);
}

/// {@template bloc_listener_tree}
/// The [BlocListenerTree] is a [DiagnosticableTree] for showing
/// the `bloc` listeners in the devtools.
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

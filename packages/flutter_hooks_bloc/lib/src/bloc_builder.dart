import 'bloc_hook.dart';
import 'flutter_bloc.dart' hide BlocProvider;
import 'package:riverbloc/riverbloc.dart' show BlocProvider;
import 'package:flutter/widgets.dart';

/// {@template bloc_builder}
/// Please refer to `BlocListener` if you want to "do" anything in response to
/// `state` changes such as navigation, showing a dialog, etc...
///
/// If the [cubit] parameter is omitted, [BlocBuilder] will automatically
/// perform a lookup using [BlocProvider] and the current `BuildContext`.
///
/// ```dart
/// BlocBuilder<BlocA, BlocAState>(
///   builder: (context, state) {
///   // return widget here based on BlocA's state
///   }
/// )
/// ```
///
/// Only specify the [cubit] if you wish to provide a [cubit] that is otherwise
/// not accessible via [BlocProvider] and the current `BuildContext`.
///
/// ```dart
/// BlocBuilder<BlocA, BlocAState>(
///   cubit: blocA,
///   builder: (context, state) {
///   // return widget here based on BlocA's state
///   }
/// )
/// ```
/// {@endtemplate}
/// {@template bloc_builder_build_when}
/// An optional [buildWhen] can be implemented for more granular control over
/// how often [BlocBuilder] rebuilds.
/// [buildWhen] will be invoked on each [cubit] `state` change.
/// [buildWhen] takes the previous `state` and current `state` and must
/// return a [bool] which determines whether or not the [builder] function will
/// be invoked.
/// The previous `state` will be initialized to the `state` of the [cubit] when
/// the [BlocBuilder] is initialized.
/// [buildWhen] is optional and if omitted, it will default to `true`.
///
/// ```dart
/// BlocBuilder<BlocA, BlocAState>(
///   buildWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to rebuild the widget with state
///   },
///   builder: (context, state) {
///     // return widget here based on BlocA's state
///   }
///)
/// ```
/// {@endtemplate}
class BlocBuilder<C extends Cubit<S>, S> extends ClassicBlocWidget<S> {
  const BlocBuilder({
    Key key,

    /// The [cubit] that the [BlocBuilder] will interact with.
    /// If omitted, [BlocBuilder] will automatically perform a lookup using
    /// [BlocProvider] and the current `BuildContext`.
    C cubit,
    @required this.builder,
    this.buildWhen,
  })  : assert(builder != null),
        super(key: key, cubit: cubit);

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final BlocWidgetBuilder<S> builder;

  ///{@macro bloc_builder_build_when}
  final BlocBuilderCondition<S> buildWhen;

  @override
  Widget build(BuildContext context) {
    final _cubit = $use<C>();
    return builder(context, _cubit.state);
  }

  @override
  bool onStateEmitted(BuildContext context, S previous, S state) {
    return buildWhen?.call(previous, state) ?? true;
  }
}

class RiverBlocBuilder<C extends Cubit<S>, S> extends RiverBlocWidget<S> {
  const RiverBlocBuilder({
    Key key,

    /// The [cubit] that the [BlocBuilder] will interact with.
    /// If omitted, [BlocBuilder] will automatically perform a lookup using
    /// [BlocProvider] and the current `BuildContext`.
    BlocProvider<C> provider,
    @required this.builder,
    this.buildWhen,
  })  : assert(builder != null),
        super(key: key, provider: provider);

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final BlocWidgetBuilder<S> builder;

  ///{@macro bloc_builder_build_when}
  final BlocBuilderCondition<S> buildWhen;

  @override
  Widget build(BuildContext context) {
    final _cubit = $use<C>();
    return builder(context, _cubit.state);
  }

  @override
  bool onStateEmitted(BuildContext context, S previous, S state) {
    return buildWhen?.call(previous, state) ?? true;
  }
}

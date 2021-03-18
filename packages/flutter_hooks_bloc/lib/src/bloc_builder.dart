import 'package:flutter/widgets.dart';
import 'package:riverbloc/riverbloc.dart' show BlocProvider;

import 'bloc_hook.dart';
import 'flutter_bloc.dart' hide BlocProvider;

/// Signature for the `builder` function which takes the `BuildContext` and
/// [state] and is responsible for returning a widget which is to be rendered.
/// This is analogous to the `builder` function in [StreamBuilder].
typedef BlocWidgetBuilder<S> = Widget Function(BuildContext context, S state);

/// Signature for the `buildWhen` function which takes the previous `state` and
/// the current `state` and is responsible for returning a [bool] which
/// determines whether to rebuild [BlocBuilder] with the current `state`.
typedef BlocBuilderCondition<S> = bool Function(S previous, S current);

/// {@template bloc_builder}
/// Please refer to `BlocListener` if you want to "do" anything in response to
/// `state` changes such as navigation, showing a dialog, etc...
///
/// If the [bloc] parameter is omitted, [BlocBuilder] will automatically
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
/// Only specify the [bloc] if you wish to provide a [bloc] that is otherwise
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
/// [buildWhen] will be invoked on each [bloc] `state` change.
/// [buildWhen] takes the previous `state` and current `state` and must
/// return a [bool] which determines whether or not the [builder] function will
/// be invoked.
/// The previous `state` will be initialized to the `state` of the [bloc] when
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
class BlocBuilder<B extends BlocBase<S>, S extends Object>
    extends BlocWidget<B, S> {
  ///The [BlocBuilder] constuctor builds a widget when a `bloc` state change.
  const BlocBuilder({
    Key? key,

    /// The [bloc] that the [BlocBuilder] will interact with.
    /// If omitted, [BlocBuilder] will automatically perform a lookup using
    /// [BlocProvider] and the current `BuildContext`.
    B? bloc,
    required this.builder,
    this.buildWhen,
  }) : super(key: key, bloc: bloc);

  /// Rebuilds its content based on a `riverbloc` provider.
  @Deprecated(
    'The BlocBuilder.river constructor is deprecated and'
    ' will be removed on v0.14.0.'
    'Use riverbloc instead',
  )
  const BlocBuilder.river({
    Key? key,
    required BlocProvider<B> provider,
    required this.builder,
    this.buildWhen,
  }) : super.river(key: key, provider: provider);

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final BlocWidgetBuilder<S> builder;

  ///{@macro bloc_builder_build_when}
  final BlocBuilderCondition<S>? buildWhen;

  @override
  Widget build(BuildContext context) {
    final _bloc = $use();
    return builder(context, _bloc.state);
  }

  @override
  bool onStateEmitted(BuildContext context, S previous, S state) {
    return buildWhen?.call(previous, state) ?? true;
  }
}

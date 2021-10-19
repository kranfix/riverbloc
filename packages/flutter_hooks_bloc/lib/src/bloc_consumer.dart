import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_hooks_bloc/src/bloc_builder.dart';
import 'package:flutter_hooks_bloc/src/bloc_listener.dart';

/// {@template bloc_consumer}
/// [BlocConsumer] exposes a [builder] and [listener] in order react to new
/// states.
/// [BlocConsumer] is analogous to a nested `BlocListener`
/// and `BlocBuilder` but reduces the amount of boilerplate needed.
/// [BlocConsumer] should only be used when it is necessary to both rebuild UI
/// and execute other reactions to state changes in the [bloc].
///
/// [BlocConsumer] takes a required `BlocWidgetBuilder`
/// and `BlocWidgetListener` and an optional [bloc],
/// `BlocBuilderCondition`, and `BlocListenerCondition`.
///
/// If the [bloc] parameter is omitted, [BlocConsumer] will automatically
/// perform a lookup using `BlocProvider` and the current `BuildContext`.
///
/// ```dart
/// BlocConsumer<BlocA, BlocAState>(
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
///   builder: (context, state) {
///     // return widget here based on BlocA's state
///   }
/// )
/// ```
///
/// An optional [listenWhen] and [buildWhen] can be implemented for more
/// granular control over when [listener] and [builder] are called.
/// The [listenWhen] and [buildWhen] will be invoked on each [bloc] `state`
/// change.
/// They each take the previous `state` and current `state` and must return
/// a [bool] which determines whether or not the [builder] and/or [listener]
/// function will be invoked.
/// The previous `state` will be initialized to the `state` of the [bloc] when
/// the [BlocConsumer] is initialized.
/// [listenWhen] and [buildWhen] are optional and if they aren't implemented,
/// they will default to `true`.
///
/// ```dart
/// BlocConsumer<BlocA, BlocAState>(
///   listenWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to invoke listener with state
///   },
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
///   buildWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to rebuild the widget with state
///   },
///   builder: (context, state) {
///     // return widget here based on BlocA's state
///   }
/// )
/// ```
/// {@endtemplate}
class BlocConsumer<B extends BlocBase<S>, S extends Object>
    extends BlocListenerBase<B, S> {
  /// The [BlocConsumer] constuctor listen and rebuilds a widget
  /// when a `bloc` state change.
  const BlocConsumer({
    Key? key,

    /// The [bloc] that the [BlocConsumer] will interact with.
    /// If omitted, [BlocConsumer] will automatically perform a lookup using
    /// `BlocProvider` and the current `BuildContext`.
    B? bloc,
    BlocListenerCondition<S>? listenWhen,
    required BlocWidgetListener<S> listener,
    this.buildWhen,
    required this.builder,
  }) : super(
          key: key,
          bloc: bloc,
          listenWhen: listenWhen,
          listener: listener,
        );

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to call [listener] of
  /// [BlocConsumer] with the current `state`.
  final BlocBuilderCondition<S>? buildWhen;

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final BlocWidgetBuilder<S> builder;

  /// Takes the previous `state` and the current `state` and is responsible
  /// for returning a [bool] which determines whether or not to trigger
  /// [builder] with the current `state`.
  @override
  Widget build(BuildContext context) {
    final state = $use();
    return builder(context, state);
  }

  @override
  bool onStateEmitted(BuildContext context, S previous, S state) {
    super.onStateEmitted(context, previous, state);
    return buildWhen?.call(previous, state) ?? true;
  }
}

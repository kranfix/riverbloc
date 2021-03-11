import 'package:flutter_hooks_bloc/src/multi_bloc_listener.dart';

import 'bloc_hook.dart';
import 'flutter_bloc.dart' hide BlocProvider;
import 'package:riverbloc/riverbloc.dart' show BlocProvider;

import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

/// Signature for the `listener` function which takes the `BuildContext` along
/// with the `state` and is responsible for executing in response to
/// `state` changes.
typedef BlocWidgetListener<S> = void Function(BuildContext context, S state);

/// Signature for the `listenWhen` function which takes the previous `state`
/// and the current `state` and is responsible for returning a [bool] which
/// determines whether or not to call [BlocWidgetListener] of [BlocListener]
/// with the current `state`.
typedef BlocListenerCondition<S> = bool Function(S previous, S current);

/// {@template bloc_listener}
/// Takes a [BlocWidgetListener] and an optional [bloc] and invokes
/// the [listener] in response to `state` changes in the [bloc].
/// It should be used for functionality that needs to occur only in response to
/// a `state` change such as navigation, showing a `SnackBar`, showing
/// a `Dialog`, etc...
/// The [listener] is guaranteed to only be called once for each `state` change
/// unlike the `builder` in `BlocBuilder`.
///
/// If the [bloc] parameter is omitted, [BlocListener] will automatically
/// perform a lookup using [BlocProvider] and the current `BuildContext`.
///
/// ```dart
/// BlocListener<BlocA, BlocAState>(
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
///   child: Container(),
/// )
/// ```
/// Only specify the [bloc] if you wish to provide a [bloc] that is otherwise
/// not accessible via [BlocProvider] and the current `BuildContext`.
///
/// ```dart
/// BlocListener<BlocA, BlocAState>(
///   bloc: blocA,
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
///   child: Container(),
/// )
/// ```
/// {@endtemplate}
///
/// {@template bloc_listener_listen_when}
/// An optional [listenWhen] can be implemented for more granular control
/// over when [listener] is called.
/// [listenWhen] will be invoked on each [bloc] `state` change.
/// [listenWhen] takes the previous `state` and current `state` and must
/// return a [bool] which determines whether or not the [listener] function
/// will be invoked.
/// The previous `state` will be initialized to the `state` of the [bloc]
/// when the [BlocListener] is initialized.
/// [listenWhen] is optional and if omitted, it will default to `true`.
///
/// ```dart
/// BlocListener<BlocA, BlocAState>(
///   listenWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to invoke listener with state
///   },
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   }
///   child: Container(),
/// )
/// ```
/// {@endtemplate}
class BlocListener<B extends Bloc<Object?, S>, S extends Object>
    extends BlocListenerBase<B, S> implements NestableBlocListener {
  const BlocListener({
    Key? key,
    B? bloc,
    BlocListenerCondition<S>? listenWhen,
    required BlocWidgetListener<S> listener,
    Widget? child,
  }) : super(
          key: key,
          bloc: bloc,
          listenWhen: listenWhen,
          listener: listener,
          child: child,
        );

  const BlocListener.river({
    Key? key,
    required BlocProvider<B> provider,
    BlocListenerCondition<S>? listenWhen,
    required BlocWidgetListener<S> listener,
    Widget? child,
  }) : super.river(
          key: key,
          provider: provider,
          listenWhen: listenWhen,
          listener: listener,
          child: child,
        );

  /// Helps to subscribe to a [bloc]
  @override
  void listen() => $use();

  @override
  bool get hasNoChild => child == null;

  @override
  DiagnosticsNode asDiagnosticsNode() {
    if (provider != null) {
      return DiagnosticsProperty<BlocProvider<B>>(
        '$runtimeType.river',
        null,
        ifNull: '',
        showSeparator: false,
      );
    } else {
      return DiagnosticsProperty<S>(
        '$runtimeType',
        bloc?.state,
        ifNull: '',
        showSeparator: bloc?.state != null,
      );
    }
  }
}

abstract class BlocListenerBase<B extends Bloc<Object?, S>, S extends Object>
    extends BlocWidget<B, S> {
  const BlocListenerBase({
    Key? key,
    B? bloc,
    this.listenWhen,
    required this.listener,
    this.child,
  }) : super(key: key, bloc: bloc);

  const BlocListenerBase.river({
    Key? key,
    required BlocProvider<B> provider,
    this.listenWhen,
    required this.listener,
    this.child,
  }) : super.river(key: key, provider: provider);

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to call [listener]
  /// with the current `state`.
  final BlocListenerCondition<S>? listenWhen;

  /// Takes the `BuildContext` along with the [bloc] `state`
  /// and is responsible for executing in response to `state` changes.
  final BlocWidgetListener<S> listener;

  /// The widget which will be rendered as a descendant.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    $use();
    return child!;
  }

  @override
  bool onStateEmitted(BuildContext context, S previous, S state) {
    if (listenWhen?.call(previous, state) ?? true) {
      listener.call(context, state);
    }
    return false;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    if (provider != null) {
      properties.add(DiagnosticsProperty<BlocProvider<B>>(
        'povider',
        provider,
      ));
    } else if (bloc != null) {
      properties.add(DiagnosticsProperty<S>(
        'state',
        bloc?.state,
        ifNull: '<null>',
        showSeparator: bloc?.state != null,
      ));
    }
  }
}

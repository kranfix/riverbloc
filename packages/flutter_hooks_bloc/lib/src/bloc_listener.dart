import 'bloc_hook.dart';
import 'flutter_bloc.dart' hide BlocProvider;
import 'package:riverbloc/riverbloc.dart' show BlocProvider;

import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

abstract class NesteableBlocListener {
  void listen();

  bool get hasNoChild;

  DiagnosticsNode asDiagnosticsNode();
}

class BlocListener<C extends Cubit<S>, S> extends BlocListenerBase<C, S>
    implements NesteableBlocListener {
  const BlocListener({
    Key key,
    C cubit,
    BlocListenerCondition<S> listenWhen,
    @required BlocWidgetListener<S> listener,
    Widget child,
  })  : assert(listener != null),
        super(
          key: key,
          cubit: cubit,
          listenWhen: listenWhen,
          listener: listener,
          child: child,
        );

  const BlocListener.river({
    Key key,
    BlocProvider<C> provider,
    BlocListenerCondition<S> listenWhen,
    @required BlocWidgetListener<S> listener,
    Widget child,
  })  : assert(listener != null),
        super.river(
          key: key,
          provider: provider,
          listenWhen: listenWhen,
          listener: listener,
          child: child,
        );

  /// Helps to subscribe to a [cubit]
  @override
  void listen() => $use<C>();

  @override
  bool get hasNoChild => child == null;

  @override
  DiagnosticsNode asDiagnosticsNode() {
    if (provider != null) {
      return DiagnosticsProperty<BlocProvider<C>>(
        '$runtimeType',
        provider,
      );
    } else {
      return DiagnosticsProperty<S>(
        '$runtimeType',
        cubit?.state,
        ifNull: '',
        showSeparator: cubit?.state != null,
      );
    }
  }
}

abstract class BlocListenerBase<C extends Cubit<S>, S> extends BlocWidget<S> {
  const BlocListenerBase({
    Key key,
    Cubit<S> cubit,
    this.listenWhen,
    @required this.listener,
    this.child,
  }) : super(key: key, cubit: cubit);

  const BlocListenerBase.river({
    Key key,
    BlocProvider<Cubit<S>> provider,
    this.listenWhen,
    @required this.listener,
    @required this.child,
  }) : super.river(key: key, provider: provider);

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to call [listener]
  /// with the current `state`.
  final BlocListenerCondition<S> listenWhen;

  /// Takes the `BuildContext` along with the [cubit] `state`
  /// and is responsible for executing in response to `state` changes.
  final BlocWidgetListener<S> listener;

  /// The widget which will be rendered as a descendant.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    $use<C>();
    return child;
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
      properties.add(DiagnosticsProperty<BlocProvider<C>>(
        'povider',
        provider,
      ));
    } else if (cubit != null) {
      properties.add(DiagnosticsProperty<S>(
        'state',
        cubit.state,
        ifNull: '<null>',
        showSeparator: cubit.state != null,
      ));
    }
  }
}

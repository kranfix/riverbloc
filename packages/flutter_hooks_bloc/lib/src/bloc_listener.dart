import 'bloc_hook.dart';
import 'flutter_bloc.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

abstract class NesteableBlocListener {
  void listen();

  bool get hasNoChild;

  DiagnosticsNode asDiagnosticsNode();
}

abstract class BlocListenerBase<C extends Cubit<S>, S>
    extends BlocWidget<C, S> {
  const BlocListenerBase({Key key, C cubit, this.listenWhen, this.listener})
      : super(key: key, cubit: cubit);

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to call [listener]
  /// with the current `state`.
  final BlocListenerCondition<S> listenWhen;

  /// Takes the `BuildContext` along with the [cubit] `state`
  /// and is responsible for executing in response to `state` changes.
  final BlocWidgetListener<S> listener;

  @override
  bool onStateEmitted(BuildContext context, S previous, S state) {
    super.onStateEmitted(context, previous, state);
    if (listenWhen?.call(previous, state) ?? true) {
      listener.call(context, state);
    }
    return false;
  }
}

class BlocListener<C extends Cubit<S>, S> extends BlocListenerBase<C, S>
    implements NesteableBlocListener {
  const BlocListener({
    Key key,
    C cubit,
    BlocListenerCondition<S> listenWhen,
    @required BlocWidgetListener<S> listener,
    this.child,
  })  : assert(listener != null),
        super(
            key: key, cubit: cubit, listenWhen: listenWhen, listener: listener);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    use();
    return child;
  }

  /// Helps to subscribe to a [cubit]
  @override
  void listen() => use();

  @override
  bool get hasNoChild => child == null;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(asDiagnosticsNode());
  }

  @override
  DiagnosticsNode asDiagnosticsNode() => DiagnosticsProperty<S>(
        '$runtimeType',
        cubit?.state,
        ifNull: '',
        showSeparator: cubit?.state != null,
      );
}

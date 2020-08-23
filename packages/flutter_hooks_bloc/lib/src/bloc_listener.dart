import 'bloc_hook.dart';
import 'flutter_bloc.dart';

import 'package:flutter/widgets.dart';

abstract class BlocListenableBase {
  void listen();

  bool get hasNoChild;
}

abstract class BlocListenerBase<C extends Cubit<S>, S>
    extends BlocWidget<C, S> {
  const BlocListenerBase({
    Key key,
    C cubit,
    this.listenWhen,
    this.listener,
    bool allowRebuild = false,
  }) : super(key: key, cubit: cubit, allowRebuild: allowRebuild ?? false);

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to call [listener]
  /// with the current `state`.
  final BlocListenerCondition<S> listenWhen;

  /// Takes the `BuildContext` along with the [cubit] `state`
  /// and is responsible for executing in response to `state` changes.
  final BlocWidgetListener<S> listener;

  /// Helps to subscribe to a [cubit] and optianly rebuild depending on
  /// if [allowRebuild] or [buildWhen] invocation returns `true`
  C listen({BlocBuilderCondition<S> buildWhen}) =>
      use(listener: _onListen, buildWhen: buildWhen);

  void _onListen(BuildContext context, S prev, S state) {
    if (listenWhen?.call(prev, state) ?? true) {
      listener.call(context, state);
    }
  }
}

class BlocListener<C extends Cubit<S>, S> extends BlocListenerBase<C, S>
    implements BlocListenableBase {
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
    listen();
    return child;
  }

  @override
  bool get hasNoChild => child == null;
}

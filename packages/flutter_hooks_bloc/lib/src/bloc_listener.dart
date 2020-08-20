import 'bloc_hook.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide BlocListener;
import 'package:flutter_hooks/flutter_hooks.dart';

class BlocListenable<C extends Cubit<S>, S>
    with CubitComposer<C>, BlocListenerInterface<C, S>
    implements BlocListenableBase {
  const BlocListenable({
    this.cubit,
    this.listenWhen,
    @required this.listener,
  }) : assert(listener != null);

  @override
  final BlocListenerCondition<S> listenWhen;

  @override
  final BlocWidgetListener<S> listener;

  @override
  final C cubit;

  @override
  void listen() => _listen();
}

abstract class BlocListenableBase {
  void listen();
}

mixin BlocListenerInterface<C extends Cubit<S>, S> on CubitComposer<C> {
  BlocListenerCondition<S> get listenWhen;
  BlocWidgetListener<S> get listener;

  void listenerCallback(BuildContext context, S prev, S state) {
    if (listenWhen?.call(prev, state) ?? true) {
      listener.call(context, state);
    }
  }
}

extension _BlocListenerX<C extends Cubit<S>, S> on BlocListenerInterface<C, S> {
  void _listen() => useBloc(cubit: cubit, listener: listenerCallback);
}

class BlocListener<C extends Cubit<S>, S> extends HookWidget
    with CubitComposer<C>, BlocListenerInterface<C, S>
    implements BlocListenableBase {
  const BlocListener({
    Key key,
    this.cubit,
    this.listenWhen,
    @required this.listener,
    this.child,
  })  : assert(listener != null),
        super(key: key);

  @override
  final BlocListenerCondition<S> listenWhen;

  @override
  final BlocWidgetListener<S> listener;

  @override
  final C cubit;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    _listen();
    return child;
  }

  /// `listen` allows [MultiBlocProvider] to verify if
  @override
  void listen() {
    assert(
      child == null,
      'In MultiBlocProvider, BlocListener.child must be null.',
    );
    return _listen();
  }
}

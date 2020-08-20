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
    this.listener,
  }) : assert(listener != null);

  final BlocListenerCondition<S> listenWhen;
  final BlocWidgetListener<S> listener;
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
  void _listen() => useBloc<C, S>(cubit: cubit, listener: listenerCallback);
}

abstract class BlocListenerItemBase<C extends Cubit<S>, S>
    with CubitComposer<C>, BlocListenerInterface<C, S> {}

class BlocListenerItem<C extends Cubit<S>, S>
    with CubitComposer<C>, BlocListenerInterface<C, S> {
  const BlocListenerItem({this.cubit, this.listenWhen, this.listener})
      : assert(listener != null);

  final C cubit;
  final BlocListenerCondition<S> listenWhen;
  final BlocWidgetListener<S> listener;
}

class BlocListener<C extends Cubit<S>, S> extends HookWidget
    with CubitComposer<C>, BlocListenerInterface<C, S> {
  const BlocListener({
    Key key,
    this.cubit,
    this.listenWhen,
    this.listener,
    this.child,
  })  : assert(listener != null),
        super(key: key);

  final BlocListenerCondition<S> listenWhen;
  final BlocWidgetListener<S> listener;
  final C cubit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    _listen();
    return child;
  }
}

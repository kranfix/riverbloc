import 'dart:async';
import 'package:flutter/foundation.dart';

import 'flutter_bloc.dart';

import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_hooks/flutter_hooks.dart';

/// Signature for the `listener` function which takes the `BuildContext` along
/// with the `current` and `previous` state and is responsible for executing in
/// response to `state` changes.
typedef BlocHookListener<S> = bool Function(
  BuildContext context,
  S previous,
  S current,
);

abstract class BlocWidget<S> extends HookWidget {
  const BlocWidget({Key key, this.cubit}) : super(key: key);

  final Cubit<S> cubit;

  C use<C extends Cubit<S>>() =>
      useBloc<C, S>(cubit: cubit, onEmitted: onStateEmitted);

  @protected
  @mustCallSuper
  bool onStateEmitted(BuildContext context, S previous, S state) => true;
}

/// Subscribes to a Cubit and handles a listener or a rebuild.
///
/// Whenever [Cubit.state] updates, it will mark the caller [HookWidget]
/// as needing build if either [allowRebuild] is `true` or [buildWhen]
/// invocation returns [true].
///
/// if [cubit] is null, it will be inherited with `context.bloc()`
///
/// The following example showcase a basic counter application.
///
/// ```dart
/// class CounterCubit extends Cubit<int> {
///   CounterCubit() : super(0);
///
///   void increment() => emit(state + 1);
/// }
///
/// class Counter extends HookWidget {
///   @override
///   Widget build(BuildContext context) {
///     // automatically triggers a rebuild of Counter widget
///     final counterCubit = useBloc<CounterCubit, int>();
///
///     return GestureDetector(
///       onTap: () => counterCubit.increment(),
///       child: Text('${counter.state}'),
///     );
///   }
/// }
/// ```
///
/// See also:
///
///  * [Cubit]
C useBloc<C extends Cubit<S>, S>({C cubit, BlocHookListener<S> onEmitted}) {
  final context = useContext();
  final _cubit = cubit ?? context.bloc<C>();
  return use(_BlocHook<C, S>(_cubit, onEmitted));
}

class _BlocHook<C extends Cubit<S>, S> extends Hook<C> {
  const _BlocHook(this.cubit, this.onEmitted);

  final C cubit;
  final BlocHookListener<S> onEmitted;

  @override
  HookState<C, Hook<C>> createState() => _BlocHookState<C, S>();
}

class _BlocHookState<C extends Cubit<S>, S>
    extends HookState<C, _BlocHook<C, S>> {
  StreamSubscription<S> _subscription;

  /// Previous state from cubit
  S _previous;

  C _cubit;

  @override
  C build(BuildContext context) => _cubit;

  @override
  void initHook() {
    super.initHook();
    _cubit = hook.cubit;
    _previous = _cubit?.state;
    _subscribe();
  }

  @override
  void didUpdateHook(_BlocHook<C, S> oldWidget) {
    super.didUpdateHook(oldWidget);
    final oldCubit = oldWidget.cubit;
    final currentCubit = hook.cubit ?? oldCubit;
    if (oldCubit != currentCubit) {
      if (_subscription != null) {
        _unsubscribe();
        _cubit = hook.cubit ?? context.bloc<C>();
        _previous = _cubit?.state;
      }
      _subscribe();
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    if (_cubit != null) {
      _subscription = _cubit.listen((state) {
        if (hook.onEmitted?.call(context, _previous, state) ?? true) {
          setState(() {});
        }
        _previous = state;
      });
    }
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }
}

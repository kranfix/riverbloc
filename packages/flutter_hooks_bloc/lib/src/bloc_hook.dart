import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:flutter_hooks_bloc/src/flutter_bloc.dart'
    show Cubit, Bloc, BlocBase, ReadContext;

/// Signature for the `listener` function which takes the `BuildContext` along
/// with the `current` and `previous` state and is responsible for executing in
/// response to `state` changes.
typedef BlocHookListener<S> = bool Function(
  BuildContext context,
  S previous,
  S current,
);

/// {@template BlocWidget}
/// The [BlocWidget] is the base for every reimplementation of `flutter_bloc`'s
/// widgets based on `Hook`s.
/// {@endtemplate}
abstract class BlocWidget<B extends BlocBase<S>, S extends Object>
    extends HookWidget {
  /// {@macro BlocWidget}
  const BlocWidget({
    Key? key,
    this.bloc,
  }) : super(key: key);

  /// `bloc` that has the state. If it's null, it will be infered from
  /// [BuildContext]
  final B? bloc;

  /// The `$use` method is a sugar syntax for the `useBloc`.
  @protected
  S $use() => useBloc<B, S>(bloc: bloc, onEmitted: onStateEmitted);

  /// The `onStateEmitted` method allows to customize the behavior
  /// of the implementation of the [BlocWidget]
  @protected
  bool onStateEmitted(BuildContext context, S previous, S state);
}

/// Subscribes to a Cubit and handles a listener or a rebuild.
///
/// Whenever [BlocBase.state] updates, it will mark the caller [HookWidget]
/// as needing build if either `allowRebuild` is `true` or `buildWhen`
/// invocation returns `true`.
///
/// if [bloc] is null, it will be inherited with `context.bloc()`
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
///  * [Bloc]
///  * [BlocBase]
S useBloc<B extends BlocBase<S>, S extends Object>({
  B? bloc,
  BlocHookListener<S>? onEmitted,
}) {
  final _bloc = bloc ?? useContext().read<B>();
  return use(_BlocHook<S>(_bloc, onEmitted));
}

class _BlocHook<S> extends Hook<S> {
  const _BlocHook(this.bloc, this.onEmitted);

  final BlocBase<S> bloc;
  final BlocHookListener<S>? onEmitted;

  @override
  HookState<S, _BlocHook<S>> createState() => _BlocHookState<S>();
}

class _BlocHookState<S> extends HookState<S, _BlocHook<S>> {
  // ignore: cancel_subscriptions
  StreamSubscription<S>? _subscription;

  /// Previous state from cubit
  late S _previous;

  @override
  S build(BuildContext context) => hook.bloc.state;

  @override
  void initHook() {
    super.initHook();
    _previous = hook.bloc.state;
    _subscribe();
  }

  @override
  void didUpdateHook(_BlocHook<S> oldHook) {
    super.didUpdateHook(oldHook);
    if (oldHook.bloc != hook.bloc) {
      if (_subscription != null) {
        _unsubscribe();
        _previous = hook.bloc.state;
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
    _subscription = hook.bloc.stream.listen((state) {
      if (hook.onEmitted?.call(context, _previous, state) ?? true) {
        setState(() {});
      }
      _previous = state;
    });
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription!.cancel();
      _subscription = null;
    }
  }
}

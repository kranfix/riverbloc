import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverbloc/riverbloc.dart' show BlocProvider;

import 'flutter_bloc.dart' show BlocBase, ReadContext;

import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' show useProvider;

/// Signature for the `listener` function which takes the `BuildContext` along
/// with the `current` and `previous` state and is responsible for executing in
/// response to `state` changes.
typedef BlocHookListener<S> = bool Function(
  BuildContext context,
  S previous,
  S current,
);

abstract class BlocWidget<B extends BlocBase<S>, S extends Object>
    extends HookWidget {
  const BlocWidget({
    Key? key,
    B? bloc,
  })  : provider = null,
        bloc = bloc,
        super(key: key);

  const BlocWidget.river({
    Key? key,
    @required this.provider,
  })  : bloc = null,
        super(key: key);

  final B? bloc;
  final BlocProvider<B>? provider;

  @protected
  B $use() {
    if (provider != null) {
      return useRiverBloc<B, S>(provider!, onEmitted: onStateEmitted);
    }
    return useBloc<B, S>(bloc: bloc, onEmitted: onStateEmitted);
  }

  @protected
  bool onStateEmitted(BuildContext context, S previous, S state);
}

/// Subscribes to a Cubit and handles a listener or a rebuild.
///
/// Whenever [Cubit.state] updates, it will mark the caller [HookWidget]
/// as needing build if either [allowRebuild] is `true` or [buildWhen]
/// invocation returns [true].
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
B useBloc<B extends BlocBase<S>, S extends Object>({
  B? bloc,
  BlocHookListener<S>? onEmitted,
}) {
  // TODO(@kranfix): try to reduce lines
  final context = useContext();
  final _bloc = bloc ?? context.read<B>();
  return use(_BlocHook<S>(_bloc, onEmitted)) as B;
}

B useRiverBloc<B extends BlocBase<S>, S extends Object>(
  BlocProvider<B> provider, {
  BlocHookListener<S>? onEmitted,
}) {
  final _bloc = useProvider(provider);
  return use(_BlocHook<S>(_bloc, onEmitted)) as B;
}

class _BlocHook<S> extends Hook<BlocBase<S>> {
  const _BlocHook(this.bloc, this.onEmitted);

  final BlocBase<S> bloc;
  final BlocHookListener<S>? onEmitted;

  @override
  HookState<BlocBase<S>, _BlocHook<S>> createState() => _BlocHookState<S>();
}

class _BlocHookState<S> extends HookState<BlocBase<S>, _BlocHook<S>> {
  StreamSubscription<S>? _subscription;

  /// Previous state from cubit
  late S _previous;

  @override
  BlocBase<S> build(BuildContext context) => hook.bloc;

  @override
  void initHook() {
    super.initHook();
    _previous = hook.bloc.state;
    _subscribe();
  }

  @override
  void didUpdateHook(_BlocHook<S> oldHook) {
    super.didUpdateHook(oldHook);
    final oldCubit = oldHook.bloc;
    final currentCubit = hook.bloc;
    if (oldCubit != currentCubit) {
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

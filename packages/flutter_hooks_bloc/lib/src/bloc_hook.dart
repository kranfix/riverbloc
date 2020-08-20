import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart' show BuildContext;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show Cubit, BlocBuilderCondition, BlocProviderExtension;

/// Signature for the `listener` function which takes the `BuildContext` along
/// with the `current` and `previous` state and is responsible for executing in
/// response to `state` changes.
typedef BlocHookListener<S> = void Function(
  BuildContext context,
  S previous,
  S current,
);

abstract class CubitComposer<C> {
  C get cubit;
}

C useBloc<C extends Cubit<S>, S>({
  C cubit,
  BlocHookListener<S> listener,
  BlocBuilderCondition<S> buildWhen,
  bool allowRebuild = false,
}) =>
    use(_BlocHook<C, S>(cubit, listener, buildWhen, allowRebuild));

class _BlocHook<C extends Cubit<S>, S> extends Hook<C> {
  const _BlocHook(
    this.cubit,
    this.listener,
    this.buildWhen,
    bool allowRebuild,
  ) : allowRebuild = (buildWhen != null) || (allowRebuild ?? false);

  final C cubit;
  final BlocHookListener<S> listener;
  final BlocBuilderCondition<S> buildWhen;
  final bool allowRebuild;

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
    _cubit = hook.cubit ?? context.bloc<C>();
    _previous = _cubit?.state;
    _subscribe();
  }

  @override
  void didUpdateHook(_BlocHook<C, S> oldWidget) {
    super.didUpdateHook(oldWidget);
    final oldCubit = oldWidget.cubit ?? context.bloc<C>();
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
        hook.listener?.call(context, _previous, state);
        if (hook.buildWhen?.call(_previous, state) ?? hook.allowRebuild) {
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

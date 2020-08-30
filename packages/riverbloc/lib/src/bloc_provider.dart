import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:riverpod/riverpod.dart';

// ignore: implementation_imports
import 'package:riverpod/src/framework.dart';

class BlocProvider<C extends Cubit<Object>> extends Provider<C> {
  BlocProvider(
    Create<C, ProviderReference> create, {
    String name,
  }) : super(create, name: name);

  BlocStateProvider<Object> _state;
}

/// Adds [state] to [BlocProvider.autoDispose].
extension BlocStateProviderX<S> on BlocProvider<Cubit<S>> {
  BlocStateProvider<S> get state {
    _state ??= BlocStateProvider<S>._(this);
    return _state as BlocStateProvider<S>;
  }
}

class BlocStateProvider<S> extends AlwaysAliveProviderBase<Cubit<S>, S> {
  BlocStateProvider._(this._provider)
      : super(
          (ref) => ref.watch(_provider),
          _provider.name != null ? '${_provider.name}.state' : null,
        );

  final BlocProvider<Cubit<S>> _provider;

  @override
  Override overrideWithValue(S value) {
    return ProviderOverride(
      ValueProvider<Cubit<S>, S>((ref) {
        return ref.watch(_provider);
      }, value),
      this,
    );
  }

  @override
  _BlocStateProviderState<S> createState() => _BlocStateProviderState();
}

class _BlocStateProviderState<S> extends ProviderStateBase<Cubit<S>, S> {
  StreamSubscription<S> _subscription;

  @override
  void valueChanged({Cubit<S> previous}) {
    assert(
      createdValue != null,
      'BlocProvider must return a non-null value',
    );
    if (createdValue != previous) {
      if (_subscription != null) {
        _unsubscribe();
      }
      _subscribe();
    }
  }

  void _subscribe() {
    if (createdValue != null) {
      exposedValue ??= createdValue.state;
      _subscription = createdValue.listen(_listener);
    }
  }

  void _unsubscribe() {
    if (_subscription != null) {
      _subscription.cancel();
      _subscription = null;
    }
  }

  void _listener(S value) {
    exposedValue = value;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }
}

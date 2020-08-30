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
}

class BlocStateProviderState<S> extends ProviderStateBase<Cubit<S>, S> {
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

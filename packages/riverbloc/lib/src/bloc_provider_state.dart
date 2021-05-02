part of 'bloc_provider.dart';

class _BlocProviderState<B extends BlocBase<S>, S>
    extends ProviderStateBase<B, S> {
  StreamSubscription<S>? _subscription;

  @override
  void valueChanged({B? previous}) {
    if (createdValue != previous) {
      if (_subscription != null) {
        _unsubscribe();
      }
      _subscribe();
    }
  }

  void _subscribe() {
    exposedValue = createdValue.state;
    _subscription = createdValue.stream.listen(_listener);
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
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

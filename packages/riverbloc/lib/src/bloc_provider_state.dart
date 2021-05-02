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

mixin _BlocProviderMixin<B extends BlocBase<S>, S> on RootProvider<B, S> {
  /// {@macro bloc_provider_notifier}
  ProviderBase<B, B> get notifier;

  /// {@macro bloc_provider_override_with_value}
  ProviderOverride overrideWithValue(B value) {
    return ProviderOverride(
      ValueProvider<Object?, B>((ref) => value, value),
      notifier,
    );
  }

  @override
  ProviderStateBase<B, S> createState() => _BlocProviderState<B, S>();
}

part of 'framework.dart';

/// Signature for the `shouldNotify` function which takes the previous `state`
/// and the current `state` and is responsible for returning a [bool] which
/// determines whether or not to call `ref.listen()` or `ref.watch`
/// with the current `state`.
typedef BlocUpdateCondition<S> = bool Function(S previous, S current);

// ignore: subtype_of_sealed_class
mixin _BlocProviderMixin<B extends BlocBase<S>, S> on ProviderBase<S> {
  /// {@macro bloc_provider_notifier}
  ProviderBase<B> get notifier;

  @override
  void setupOverride(SetupOverride setup) {
    setup(origin: this, override: this);
    setup(origin: notifier, override: notifier);
  }

  /// Overrides the behavior of a provider with a value.
  ///
  /// {@macro riverpod.overideWith}
  Override overrideWithValue(B bloc) {
    return ProviderOverride((setup) {
      setup(
        origin: notifier,
        override: ValueProvider<B>(bloc),
      );
      setup(origin: this, override: this);
    });
  }

  /// The bloc notifies when the state changes.
  @override
  bool updateShouldNotify(S previousState, S newState) {
    return newState != previousState;
  }

  late final _onChange = _ChangeProviderFamily<S, BlocUpdateCondition<S>>(this);

  /// {@macro bloc_provider_when}
  ProviderBase<S> when(BlocUpdateCondition<S> shouldUpdate) {
    return _onChange.call(shouldUpdate);
  }
}

// ignore: subtype_of_sealed_class
class _ChangeProvider<S> extends AutoDisposeProvider<S> {
  _ChangeProvider(
    ProviderBase<S> origin, {
    required BlocUpdateCondition<S> shouldNotify,
  }) : super((ref) {
          var previous = ref.read(origin);
          ref.listen<S>(
            origin,
            (state) {
              if (shouldNotify(previous, state)) {
                ref.state = state;
              }
              previous = state;
            },
            fireImmediately: true,
          );
          return previous;
        });
}

class _ChangeProviderFamily<S, Arg extends BlocUpdateCondition<S>>
    extends Family<S, Arg, _ChangeProvider<S>> {
  _ChangeProviderFamily(this.origin, {String? name}) : super(name);

  final ProviderBase<S> origin;

  @override
  _ChangeProvider<S> create(Arg shouldNotify) {
    return _ChangeProvider<S>(
      origin,
      shouldNotify: shouldNotify,
    );
  }
}

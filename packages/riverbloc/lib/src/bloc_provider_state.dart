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

  // TODO(kranfix) - Add a `BlocProvider.of` method that takes a context and
  //@override
  //void setupOverride(SetupOverride setup) {
  //  //super.setupOverride(setup);
  //  setup(origin: this, override: this);
  //  setup(origin: notifier, override: notifier);
  //}

  /// The bloc notifies when the state changes.
  @override
  bool updateShouldNotify(S previousState, S newState) {
    return newState != previousState;
  }
}

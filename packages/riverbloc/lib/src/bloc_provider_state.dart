part of 'bloc_provider.dart';

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
        override: Provider<B>((ref) => bloc),
      );
      setup(origin: this, override: this);
    });
  }
}

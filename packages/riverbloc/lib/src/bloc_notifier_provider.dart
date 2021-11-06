part of 'framework.dart';

/// {@macro riverpod.providerrefbase}
abstract class BlocProviderRef<B extends BlocBase<S>, S> implements Ref {
  /// The [Bloc] currently exposed by this provider.
  ///
  /// Cannot be accessed while creating the provider.
  B get bloc;
}

class _BlocProviderElement<B extends BlocBase<S>, S>
    extends ProviderElementBase<B> implements BlocProviderRef<B, S> {
  _BlocProviderElement(_NotifierProvider<B, S> provider) : super(provider);

  @override
  B get bloc => requireState;
}

// ignore: subtype_of_sealed_class
class _NotifierProvider<B extends BlocBase<S>, S>
    extends AlwaysAliveProviderBase<B> {
  _NotifierProvider(
    this._create, {
    required String? name,
    required this.dependencies,
    Family? from,
    Object? argument,
  }) : super(
          name: modifierName(name, 'notifier'),
          from: from,
          argument: argument,
        );

  final Create<B, BlocProviderRef<B, S>> _create;

  @override
  final List<ProviderOrFamily>? dependencies;

  @override
  B create(covariant BlocProviderRef<B, S> ref) {
    final bloc = _create(ref);
    ref.onDispose(bloc.close);
    return bloc;
  }

  @override
  bool updateShouldNotify(B previousState, B newState) {
    return true;
  }

  @override
  _BlocProviderElement<B, S> createElement() => _BlocProviderElement(this);
}

// ignore: subtype_of_sealed_class
/// Add [overrideWithValue] to [AutoDisposeStateNotifierProvider]
mixin BlocProviderOverrideMixin<B extends BlocBase<S>, S> on ProviderBase<S> {
  ///
  ProviderBase<B> get bloc;

  @override
  late final List<ProviderOrFamily>? dependencies = [bloc];

  @override
  ProviderBase<B> get originProvider => bloc;

  /// {@macro riverpod.overrridewithvalue}
  Override overrideWithValue(B value) {
    return ProviderOverride(
      origin: bloc,
      override: ValueProvider<B>(value),
    );
  }
}

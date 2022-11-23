// ignore_for_file: invalid_use_of_internal_member

part of 'framework.dart';

/// {@macro riverpod.providerrefbase}
abstract class AutoDisposeBlocProviderRef<B extends BlocBase<S>, S>
    extends BlocProviderRef<B, S> implements AutoDisposeRef<S> {}

// ignore: subtype_of_sealed_class
/// {@macro bloc_provider_auto_dispose}
class AutoDisposeBlocProvider<B extends BlocBase<S>, S>
    extends _BlocProviderBase<B, S> {
  /// {@macro riverpod.statenotifierprovider}
  AutoDisposeBlocProvider(
    this._createFn, {
    super.name,
    super.from,
    super.argument,
    super.dependencies,
    super.debugGetCreateSourceHash,
  });

  /// {@macro bloc_provider_scoped}
  AutoDisposeBlocProvider.scoped(String name)
      : this(
          (ref) =>
              throw UnimplementedProviderError<AutoDisposeBlocProvider<B, S>>(
            name,
          ),
          name: name,
        );

  /// {@macro riverpod.family}
  static const family = AutoDisposeStateNotifierProviderFamily.new;

  final B Function(AutoDisposeBlocProviderRef<B, S> ref) _createFn;

  @override
  B _create(AutoDisposeBlocProviderElement<B, S> ref) {
    return _createFn(ref);
  }

  @override
  AutoDisposeBlocProviderElement<B, S> createElement() {
    return AutoDisposeBlocProviderElement._(this);
  }

  @override
  late final Refreshable<B> bloc = _notifier(this);

  /// {@macro riverpod.overridewith}
  Override overrideWith(
    Create<B, AutoDisposeBlocProviderRef<B, S>> create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AutoDisposeBlocProvider<B, S>(
        create,
        from: from,
        argument: argument,
      ),
    );
  }
}

/// The element of [AutoDisposeBlocProvider].
class AutoDisposeBlocProviderElement<B extends BlocBase<S>, S>
    extends BlocProviderElement<B, S>
    with AutoDisposeProviderElementMixin<S>
    implements AutoDisposeBlocProviderRef<B, S> {
  /// The [ProviderElementBase] for [BlocProvider]
  AutoDisposeBlocProviderElement._(
    AutoDisposeBlocProvider<B, S> super.provider,
  ) : super._();
}

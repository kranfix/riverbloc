part of 'bloc_provider.dart';

// ignore: subtype_of_sealed_class
class _AutoDisposeNotifierProvider<B extends BlocBase<Object?>>
    extends AutoDisposeProviderBase<B> {
  _AutoDisposeNotifierProvider(
    this._create, {
    required String? name,
  }) : super(name == null ? null : '$name.notifier');

  final Create<B, AutoDisposeProviderRefBase> _create;
  @override
  B create(AutoDisposeProviderRefBase ref) {
    final notifier = _create(ref);
    ref.onDispose(notifier.close);
    return notifier;
  }

  @override
  bool recreateShouldNotify(B previousState, B newState) {
    return true;
  }

  @override
  AutoDisposeProviderElement<B> createElement() {
    return AutoDisposeProviderElement(this);
  }

  @override
  SetupOverride get setupOverride =>
      throw UnsupportedError('Cannot override BlocProvider.notifier');
}

// ignore: subtype_of_sealed_class
/// {@macro bloc_provider_auto_dispose}
@sealed
class AutoDisposeBlocProvider<B extends BlocBase<S>, S>
    extends AutoDisposeProviderBase<S> with _BlocProviderMixin<B, S> {
  /// {@macro bloc_provider}

  AutoDisposeBlocProvider(this._create, {String? name}) : super(name);

  final Create<B, AutoDisposeProviderRefBase> _create;

  @override
  late final AutoDisposeProviderBase<B> notifier =
      _AutoDisposeNotifierProvider(_create, name: name);

  /// {@macro bloc_provider_bloc}
  AutoDisposeProviderBase<B> get bloc => notifier;

  /// {@macro bloc_provider_stream}
  late final AutoDisposeProviderBase<AsyncValue<S>> stream =
      AutoDisposeStreamProvider<S>(
    (ref) => ref.watch(notifier).stream,
    name: name == null ? null : '$name.stream',
  );

  @override
  S create(AutoDisposeProviderElementBase<S> ref) {
    final notifier = ref.watch(this.notifier);
    ref.state = notifier.state;

    void listener(S newState) {
      ref.state = newState;
    }

    final removeListener = notifier.stream.listen(listener);
    ref.onDispose(removeListener.cancel);

    return ref.state;
  }

  @override
  bool recreateShouldNotify(S previousState, S newState) {
    return true;
  }

  /// Overrides the behavior of a provider with a another provider.
  ///
  /// {@macro riverpod.overideWith}
  Override overrideWithProvider(
    AutoDisposeBlocProvider<B, S> provider,
  ) {
    return ProviderOverride((setup) {
      setup(origin: notifier, override: provider.notifier);
      setup(origin: this, override: this);
    });
  }

  @override
  AutoDisposeProviderElementBase<S> createElement() {
    return AutoDisposeProviderElement(this);
  }
}

/// Builds a [AutoDisposeBlocProvider].
class AutoDisposeBlocProviderBuilder {
  /// Builds a [AutoDisposeBlocProviderBuilder].
  const AutoDisposeBlocProviderBuilder();

  /// {@macro riverpod.autoDispose}
  AutoDisposeBlocProvider<B, S> call<B extends BlocBase<S>, S>(
    B Function(AutoDisposeProviderRefBase ref) create, {
    String? name,
  }) {
    return AutoDisposeBlocProvider(create, name: name);
  }
}

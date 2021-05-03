part of 'bloc_provider.dart';

// ignore: subtype_of_sealed_class
class _AutoDisposeNotifierProvider<B extends BlocBase<Object?>>
    extends AutoDisposeProvider<B> {
  _AutoDisposeNotifierProvider(
    Create<B, AutoDisposeProviderReference> create, {
    required String? name,
  }) : super(
          (ref) {
            final notifier = create(ref);
            ref.onDispose(notifier.close);
            return notifier;
          },
          name: name == null ? null : '$name.notifier',
        );
}

/// {@macro bloc_provider_auto_dispose}
@sealed
class AutoDisposeBlocProvider<B extends BlocBase<S>, S>
    extends AutoDisposeProviderBase<B, S> with _BlocProviderMixin {
  /// {@macro bloc_provider}
  AutoDisposeBlocProvider(
    Create<B, AutoDisposeProviderReference> create, {
    String? name,
  })  : _create = create,
        super(name);

  final Create<B, AutoDisposeProviderReference> _create;

  /// {@macro bloc_provider_notifier}
  @override
  late final AutoDisposeProviderBase<B, B> notifier =
      _AutoDisposeNotifierProvider(_create, name: name);

  /// {@macro bloc_provider_stream}
  late final AutoDisposeProviderBase<Stream<S>, AsyncValue<S>> stream =
      AutoDisposeStreamProvider<S>(
    (ref) => ref.watch(notifier).stream,
    name: name == null ? null : '$name.stream',
  );

  /// {@macro bloc_provider_override_with_provider}
  ProviderOverride overrideWithProvider(
    AutoDisposeBlocProvider<B, S> provider,
  ) {
    return ProviderOverride(provider.notifier, notifier);
  }

  @override
  B create(covariant AutoDisposeProviderReference ref) => ref.watch(notifier);
}

/// Builds a [AutoDisposeBlocProvider].
class AutoDisposeBlocProviderBuilder {
  /// Builds a [AutoDisposeBlocProviderBuilder].
  const AutoDisposeBlocProviderBuilder();

  /// {@macro riverpod.autoDispose}
  AutoDisposeBlocProvider<B, S> call<B extends BlocBase<S>, S>(
    B Function(AutoDisposeProviderReference ref) create, {
    String? name,
  }) {
    return AutoDisposeBlocProvider(create, name: name);
  }
}

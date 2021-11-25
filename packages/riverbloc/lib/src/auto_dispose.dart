part of 'framework.dart';

/// {@macro riverpod.providerrefbase}
abstract class AutoDisposeBlocProviderRef<B extends BlocBase<Object?>>
    implements AutoDisposeRef {
  /// The [Bloc] currently exposed by this provider.
  ///
  /// Cannot be accessed while creating the provider.
  B get bloc;
}

// ignore: subtype_of_sealed_class
class _AutoDisposeNotifierProvider<B extends BlocBase<Object?>>
    extends AutoDisposeProviderBase<B> {
  _AutoDisposeNotifierProvider(
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

  final Create<B, AutoDisposeBlocProviderRef<B>> _create;

  @override
  final List<ProviderOrFamily>? dependencies;

  @override
  B create(covariant AutoDisposeBlocProviderRef<B> ref) {
    final bloc = _create(ref);
    ref.onDispose(bloc.close);
    return bloc;
  }

  @override
  bool updateShouldNotify(B previousState, B newState) {
    return true;
  }

  @override
  _AutoDisposeNotifierProviderElement<B> createElement() {
    return _AutoDisposeNotifierProviderElement(this);
  }
}

class _AutoDisposeNotifierProviderElement<B extends BlocBase<Object?>>
    extends AutoDisposeProviderElementBase<B>
    implements AutoDisposeBlocProviderRef<B> {
  _AutoDisposeNotifierProviderElement(
    _AutoDisposeNotifierProvider<B> provider,
  ) : super(provider);

  @override
  B get bloc => requireState;
}

// ignore: subtype_of_sealed_class
/// {@macro bloc_provider_auto_dispose}
@sealed
class AutoDisposeBlocProvider<B extends BlocBase<S>, S>
    extends AutoDisposeProviderBase<S>
    with
        BlocProviderOverrideMixin<B, S>,
        OverrideWithProviderMixin<B, AutoDisposeBlocProvider<B, S>> {
  /// {@macro bloc_provider_auto_dispose}
  AutoDisposeBlocProvider(
    Create<B, AutoDisposeBlocProviderRef<B>> create, {
    String? name,
    List<ProviderOrFamily>? dependencies,
    Family? from,
    Object? argument,
  })  : bloc = _AutoDisposeNotifierProvider(
          create,
          name: name,
          dependencies: dependencies,
          from: from,
          argument: argument,
        ),
        super(name: name, from: from, argument: argument);

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
  static const family = AutoDisposeBlocProviderFamilyBuilder();

  /// {@template riverbloc.auto_dispose_provider_base.notifier}
  /// Obtains the [BlocBase] associated with this [AutoDisposeBlocProvider],
  /// without listening to it.
  ///
  /// Listening to this provider may cause providers/widgets to rebuild in the
  /// event that the [BlocBase] it recreated.
  /// {@endtemplate}
  @override
  final AutoDisposeProviderBase<B> bloc;

  /// Equivalent to [bloc]
  AutoDisposeProviderBase<B> get notifier => bloc;

  /// {@macro bloc_provider_stream}
  late final AutoDisposeProviderBase<AsyncValue<S>> stream =
      AutoDisposeStreamProvider<S>(
    (ref) => ref.watch(bloc).stream,
    name: modifierName(name, 'stream'),
  );

  @override
  S create(AutoDisposeProviderElementBase<S> ref) {
    final bloc = ref.watch(this.bloc);

    void listener(S newState) => ref.setState(newState);
    final removeListener = bloc.stream.listen(listener);
    ref.onDispose(removeListener.cancel);

    return bloc.state;
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
    B Function(AutoDisposeBlocProviderRef<B> ref) create, {
    String? name,
    List<ProviderOrFamily>? dependencies,
    Family? from,
    Object? argument,
  }) {
    return AutoDisposeBlocProvider(
      create,
      name: name,
      dependencies: dependencies,
      from: from,
      argument: argument,
    );
  }
}

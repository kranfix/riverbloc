part of 'framework.dart';

/// {@template riverbloc.bloc_family_create}
/// A [FamilyCreate] for [AutoDisposeBlocProviderFamily]
/// {@endtemplate}
typedef AutoDisposeBlocFamilyCreate<B extends BlocBase<Object?>, Arg>
    = FamilyCreate<B, AutoDisposeBlocProviderRef<B>, Arg>;

// ignore: subtype_of_sealed_class
/// {@template riverbloc.auto_dispose_bloc_provider.family}
/// A class that allows building a [AutoDisposeBlocProvider] from an
/// external parameter.
/// {@endtemplate}
///
/// {@template riverbloc.auto_dispose_bloc_provider_family_scoped}
/// # AutoDisposeBlocProviderFamily.scoped
/// Creates an [AutoDisposeBlocProvider] that will be scoped and must be
/// overridden.
/// Otherwise, it will throw an [UnimplementedProviderError].
/// {@endtemplate}
@sealed
class AutoDisposeBlocProviderFamily<B extends BlocBase<S>, S, Arg>
    extends Family<S, Arg, AutoDisposeBlocProvider<B, S>> {
  /// {@macro riverbloc.auto_dispose_bloc_provider.family}
  AutoDisposeBlocProviderFamily(
    this._create, {
    String? name,
    List<ProviderOrFamily>? dependencies,
  }) : super(name: name, dependencies: dependencies);

  /// {@macro riverbloc.auto_dispose_bloc_provider_family_scoped}
  AutoDisposeBlocProviderFamily.scoped(String name)
      : this(
          (ref, arg) {
            throw UnimplementedProviderError<AutoDisposeBlocProvider<B, S>>(
              name,
            );
          },
          name: name,
        );

  final AutoDisposeBlocFamilyCreate<B, Arg> _create;

  @override
  AutoDisposeBlocProvider<B, S> create(Arg argument) {
    return AutoDisposeBlocProvider<B, S>(
      (ref) => _create(ref, argument),
      name: name,
      from: this,
      argument: argument,
    );
  }

  @override
  void setupOverride(Arg argument, SetupOverride setup) {
    final provider = call(argument);
    setup(origin: provider, override: provider);
    setup(origin: provider.bloc, override: provider.bloc);
  }

  /// {@macro riverpod.overridewithprovider}
  Override overrideWithProvider(
    AutoDisposeBlocProvider<B, S> Function(Arg argument) override,
  ) {
    return FamilyOverride<Arg>(
      this,
      (arg, setup) {
        final provider = call(arg);
        setup(origin: provider.bloc, override: override(arg).bloc);
      },
    );
  }
}

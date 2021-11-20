part of 'framework.dart';

/// {@template riverbloc.bloc_family_create}
/// A [FamilyCreate] for [BlocProviderFamily]
/// {@endtemplate}
typedef BlocFamilyCreate<B extends BlocBase<Object?>, Arg>
    = FamilyCreate<B, BlocProviderRef<B>, Arg>;

// ignore: subtype_of_sealed_class
/// {@template bloc_provider_family}
/// A class that allows building a [BlocProvider] from an external
/// parameter.
/// {@endtemplate}
///
/// {@template bloc_provider_family_scoped}
/// Creates a [BlocProvider] that will be scoped and must be overridden.
/// Otherwise, it will throw an [UnimplementedProviderError].
/// {@endtemplate}
@sealed
class BlocProviderFamily<B extends BlocBase<S>, S, Arg>
    extends Family<S, Arg, BlocProvider<B, S>> {
  /// {@macro bloc_provider_family}
  BlocProviderFamily(
    this._create, {
    String? name,
    List<ProviderOrFamily>? dependencies,
  }) : super(name: name, dependencies: dependencies);

  ///
  BlocProviderFamily.scoped(String name)
      : this(
          (ref, arg) => throw UnimplementedProviderError(name),
          name: name,
        );

  final BlocFamilyCreate<B, Arg> _create;

  @override
  BlocProvider<B, S> create(Arg argument) {
    return BlocProvider<B, S>(
      (ref) => _create(ref, argument),
      name: name,
      from: this,
      argument: argument,
    );
  }

  @override
  void setupOverride(Arg argument, SetupOverride setup) {
    final provider = call(argument);
    setup(origin: provider.bloc, override: provider.bloc);
  }

  /// {@macro riverpod.overridewithprovider}
  Override overrideWithProvider(
    BlocProvider<B, S> Function(Arg argument) override,
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

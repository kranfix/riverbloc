// ignore_for_file: invalid_use_of_internal_member

part of 'framework.dart';

// ignore: subtype_of_sealed_class
/// {@template bloc_provider_family}
/// A class that allows building a [BlocProvider] from an external
/// parameter.
/// {@endtemplate}
///
/// {@template bloc_provider_family_scoped}
/// # BlocProviderFamily.scoped
/// Creates a [BlocProvider] that will be scoped and must be overridden.
/// Otherwise, it will throw an [UnimplementedProviderError].
/// {@endtemplate}
@sealed
class BlocProviderFamily<B extends BlocBase<S>, S, Arg>
    extends FamilyBase<BlocProviderRef<B, S>, S, Arg, B, BlocProvider<B, S>> {
  /// The [Family] of [BlocProvider].
  BlocProviderFamily(
    super.create, {
    super.name,
    super.dependencies,
  }) : super(
      providerFactory: BlocProvider.internal,
      allTransitiveDependencies: computeAllTransitiveDependencies(dependencies),
      debugGetCreateSourceHash: null);

  /// {@macro bloc_provider_family_scoped}
  BlocProviderFamily.scoped(String name)
      : this(
          (ref, arg) => throw UnimplementedProviderError(name),
          name: name,
        );
}

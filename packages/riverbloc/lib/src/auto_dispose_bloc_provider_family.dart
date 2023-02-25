// ignore_for_file: invalid_use_of_internal_member

part of 'framework.dart';

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
    extends AutoDisposeFamilyBase<AutoDisposeBlocProviderRef<B, S>, S, Arg, B,
        AutoDisposeBlocProvider<B, S>> {
  /// The [Family] of [AutoDisposeBlocProvider].
  AutoDisposeBlocProviderFamily(
    super.create, {
    super.name,
    super.dependencies,
  }) : super(providerFactory: AutoDisposeBlocProvider.internal,
      debugGetCreateSourceHash: null,
      allTransitiveDependencies: computeAllTransitiveDependencies(dependencies));

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

  /// {@macro riverpod.overridewith}
  Override overrideWith(
    B Function(AutoDisposeBlocProviderRef<B, S> ref, Arg arg) create,
  ) {
    return FamilyOverrideImpl<S, Arg, AutoDisposeBlocProvider<B, S>>(
      this,
      (arg) => AutoDisposeBlocProvider<B, S>(
        (ref) => create(ref, arg),
        from: from,
        argument: arg,
      ),
    );
  }
}

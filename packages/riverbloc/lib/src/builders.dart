part of 'framework.dart';

/// Builds a [BlocProviderFamily].
class BlocProviderFamilyBuilder {
  /// Builds a [BlocProviderFamily].
  const BlocProviderFamilyBuilder();

  /// {@macro riverpod.family}
  BlocProviderFamily<B, S, Arg> call<B extends BlocBase<S>, S, Arg>(
    FamilyCreate<B, BlocProviderRef<B>, Arg> create, {
    String? name,
    List<ProviderOrFamily>? dependencies,
  }) {
    return BlocProviderFamily(
      create,
      name: name,
      dependencies: dependencies,
    );
  }

  /// {@macro riverpod.autoDispose}
  AutoDisposeBlocProviderFamilyBuilder get autoDispose {
    return const AutoDisposeBlocProviderFamilyBuilder();
  }
}

/// Builds a [AutoDisposeBlocProviderFamily].
class AutoDisposeBlocProviderFamilyBuilder {
  /// Builds a [AutoDisposeBlocProviderFamily].
  const AutoDisposeBlocProviderFamilyBuilder();

  /// {@macro riverpod.family}
  AutoDisposeBlocProviderFamily<B, S, Arg> call<B extends BlocBase<S>, S, Arg>(
    FamilyCreate<B, AutoDisposeBlocProviderRef<B>, Arg> create, {
    String? name,
    List<ProviderOrFamily>? dependencies,
  }) {
    return AutoDisposeBlocProviderFamily(
      create,
      name: name,
      dependencies: dependencies,
    );
  }
}

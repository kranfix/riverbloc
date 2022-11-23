// ignore_for_file: invalid_use_of_internal_member

part of 'framework.dart';

/// Builds a [BlocProviderFamily].
class BlocProviderFamilyBuilder {
  /// Builds a [BlocProviderFamily].
  const BlocProviderFamilyBuilder();

  /// {@macro riverpod.family}
  BlocProviderFamily<B, S, Arg> call<B extends BlocBase<S>, S, Arg>(
    FamilyCreate<B, BlocProviderRef<B, S>, Arg> create, {
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

/// Builds a [AutoDisposeBlocProvider].
class AutoDisposeBlocProviderBuilder {
  /// Builds a [AutoDisposeBlocProvider].
  const AutoDisposeBlocProviderBuilder();

  /// {@macro riverpod.autoDispose}
  AutoDisposeBlocProvider<B, S> call<B extends BlocBase<S>, S>(
    Create<B, AutoDisposeBlocProviderRef<B, S>> create, {
    String? name,
    List<ProviderOrFamily>? dependencies,
  }) {
    return AutoDisposeBlocProvider<B, S>(
      create,
      name: name,
      dependencies: dependencies,
    );
  }

  /// {@macro riverpod.family}
  AutoDisposeBlocProviderFamilyBuilder get family {
    return const AutoDisposeBlocProviderFamilyBuilder();
  }
}

/// The [Family] of [AutoDisposeBlocProvider].
class AutoDisposeBlocProviderFamilyBuilder {
  /// Builds a [AutoDisposeBlocProviderFamily].
  const AutoDisposeBlocProviderFamilyBuilder();

  /// {@macro riverpod.family}
  AutoDisposeBlocProviderFamily<B, S, Arg> call<B extends BlocBase<S>, S, Arg>(
    FamilyCreate<B, AutoDisposeBlocProviderRef<B, S>, Arg> create, {
    String? name,
    List<ProviderOrFamily>? dependencies,
  }) {
    return AutoDisposeBlocProviderFamily<B, S, Arg>(
      create,
      name: name,
      dependencies: dependencies,
    );
  }
}

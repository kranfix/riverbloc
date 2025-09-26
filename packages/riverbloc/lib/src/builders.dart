// To implement this package, it is necessary to use riverpod's inner classes
// ignore_for_file: invalid_use_of_internal_member

part of 'framework.dart';

/// Builds a [BlocProviderFamily].
class BlocProviderFamilyBuilder {
  /// Builds a [BlocProviderFamily].
  const BlocProviderFamilyBuilder();

  /// {@macro riverpod.family}
  BlocProviderFamily<B, S, ArgT>
      call<B extends StateStreamableSource<S>, S, ArgT>(
    B Function(Ref ref, ArgT param) create, {
    String? name,
    Iterable<ProviderOrFamily>? dependencies,
    Retry? retry,
    bool isAutoDispose = false,
  }) {
    return BlocProviderFamily<B, S, ArgT>(
      create,
      name: name,
      isAutoDispose: isAutoDispose,
      dependencies: dependencies,
      retry: retry,
    );
  }

  /// {@macro riverpod.autoDispose}
  AutoDisposeBlocProviderFamilyBuilder get autoDispose {
    return const AutoDisposeBlocProviderFamilyBuilder._();
  }
}

/// Builds a auto-dispose [BlocProvider].
final class AutoDisposeBlocProviderBuilder {
  const AutoDisposeBlocProviderBuilder._();

  /// {@macro riverpod.family}
  BlocProvider<B, S> call<B extends StateStreamableSource<S>, S>(
    B Function(Ref ref) create, {
    String? name,
    Iterable<ProviderOrFamily>? dependencies,
    Retry? retry,
  }) {
    return BlocProvider<B, S>(
      create,
      name: name,
      isAutoDispose: true,
      dependencies: dependencies,
      retry: retry,
    );
  }

  /// {@macro bloc_provider_scoped}
  BlocProvider<B, S> scoped<B extends StateStreamableSource<S>, S>(
    String name,
  ) {
    return BlocProvider<B, S>(
      (_) => throw UnimplementedProviderError(name),
      name: name,
      isAutoDispose: true,
    );
  }

  /// {@macro riverpod.family}
  AutoDisposeBlocProviderFamilyBuilder get family =>
      const AutoDisposeBlocProviderFamilyBuilder._();
}

/// The [Family] of auto-dispose [BlocProvider].
final class AutoDisposeBlocProviderFamilyBuilder {
  const AutoDisposeBlocProviderFamilyBuilder._();

  /// {@macro riverpod.family}
  BlocProviderFamily<B, S, ArgT>
      call<B extends StateStreamableSource<S>, S, ArgT>(
    B Function(Ref ref, ArgT param) create, {
    String? name,
    Iterable<ProviderOrFamily>? dependencies,
    Retry? retry,
  }) {
    return BlocProviderFamily<B, S, ArgT>(
      create,
      name: name,
      isAutoDispose: true,
      dependencies: dependencies,
      retry: retry,
    );
  }

  /// {@macro bloc_provider_scoped}
  BlocProviderFamily<B, S, ArgT>
      scoped<B extends StateStreamableSource<S>, S, ArgT>(
    String name,
  ) {
    return BlocProviderFamily<B, S, ArgT>(
      (_, __) => throw UnimplementedProviderError(name),
      name: name,
      isAutoDispose: true,
    );
  }
}

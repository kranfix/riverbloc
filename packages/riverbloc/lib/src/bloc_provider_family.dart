// To implement this package, it is necessary to use riverpod's inner classes
// ignore_for_file: invalid_use_of_internal_member

part of 'framework.dart';

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

/// The [Family] of [BlocProvider].
final class BlocProviderFamily<B extends StateStreamableSource<S>, S, ArgT>
    extends FunctionalFamily<S, S, ArgT, B, BlocProvider<B, S>> {
  /// The [Family] of [StateNotifierProvider].
  /// @nodoc
  @internal
  BlocProviderFamily(
    super._createFn, {
    super.name,
    super.dependencies,
    super.isAutoDispose = false,
    super.retry,
  }) : super(
          providerFactory: BlocProvider.internal,
          $allTransitiveDependencies: computeAllTransitiveDependencies(
            dependencies,
          ),
        );

  /// {@macro bloc_provider_family_scoped}
  BlocProviderFamily.scoped(String name)
      : this(
          (ref, arg) => throw UnimplementedProviderError(name),
          name: name,
        );
}

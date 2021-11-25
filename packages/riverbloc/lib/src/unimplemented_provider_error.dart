// ignore: implementation_imports
import 'package:riverpod/src/framework.dart';

/// {@template unimplemented_provider_error}
/// Error that will be throw when the provider is not
/// implemented and must be overridden.
/// {@endtemplate}
class UnimplementedProviderError<P extends ProviderOrFamily> extends Error {
  /// @{macro unimplemented_provider_error}
  UnimplementedProviderError(this.name);

  /// `name` of the provider
  final String name;

  @override
  String toString() {
    return '$P $name must be overridden';
  }
}

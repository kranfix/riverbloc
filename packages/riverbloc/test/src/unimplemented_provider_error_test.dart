import 'package:riverbloc/riverbloc.dart';
import 'package:test/test.dart';

void main() {
  test('unimplemented provider error', () async {
    final error = UnimplementedProviderError<Provider<int>>('providerName');
    expect(error.toString(), 'Provider<int> providerName must be overridden');
  });
}

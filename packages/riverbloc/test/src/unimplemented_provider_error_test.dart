import 'package:flutter_test/flutter_test.dart';
import 'package:riverbloc/riverbloc.dart';

void main() {
  testWidgets('unimplemented provider error', (tester) async {
    final error = UnimplementedProviderError<Provider<int>>('providerName');
    expect(error.toString(), 'Provider<int> providerName must be overrided');
  });
}

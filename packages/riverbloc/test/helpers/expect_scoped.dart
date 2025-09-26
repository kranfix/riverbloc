import 'package:riverbloc/riverbloc.dart';
import 'package:riverpod/misc.dart';
import 'package:test/test.dart';

void expectScoped<B extends StateStreamableSource<S>, S>(
  ProviderContainer container,
  BlocProvider<B, S> provider,
) {
  try {
    container.read(provider.bloc);
  } on ProviderException catch (e) {
    final exception = e.exception;
    if (exception is UnimplementedProviderError) {
      expect(exception.name, 'someName');
    } else {
      fail('unexpected exception $e');
    }
  } catch (e) {
    fail('unexpected exception $e');
  }
}

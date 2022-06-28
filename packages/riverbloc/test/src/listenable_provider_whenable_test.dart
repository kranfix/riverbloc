import 'package:mocktail/mocktail.dart';
import 'package:riverbloc/riverbloc.dart';
import 'package:test/test.dart';

import '../helpers/helpers.dart';

final counterProvider = StateProvider((ref) => 0);
final doubleOddPrevProvider = Provider((ref) {
  return ref.watch(
    counterProvider
        .when((prev, curr) => prev.isOdd)
        .select((value) => 2 * value),
  );
});

final counterProvider1 = StateProvider.autoDispose((ref) => 0);

void main() {
  group('AlwayAliveProviderListenable.when', () {
    test('Direct call', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final listener = Listener<int>();

      final sub = container.listen(
        counterProvider
            .when((prev, curr) => prev.isOdd)
            .select((value) => 2 * value),
        listener,
        fireImmediately: true,
      );
      final controller = container.read(counterProvider.notifier);

      verify(() => listener(null, 0)).called(1);
      expect(container.read(counterProvider), 0);
      expect(sub.read(), 0);
      verifyNever(() => listener(any(), any()));

      controller.state++;
      expect(container.read(counterProvider), 1);
      expect(sub.read(), 0);
      verifyNever(() => listener(any(), any()));

      controller.state++;
      expect(container.read(counterProvider), 2);
      expect(sub.read(), 4);
      verify(() => listener(0, 4)).called(1);

      controller.state++;
      expect(container.read(counterProvider), 3);
      expect(sub.read(), 4);
      verifyNever(() => listener(any(), any()));

      controller.state++;
      expect(container.read(counterProvider), 4);
      expect(sub.read(), 8);
      verify(() => listener(4, 8)).called(1);
    });

    test('Inside a provider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final listener = Listener<int>();

      final sub = container.listen(
        doubleOddPrevProvider,
        listener,
        fireImmediately: true,
      );
      final controller = container.read(counterProvider.notifier);

      verify(() => listener(null, 0)).called(1);
      expect(container.read(counterProvider), 0);
      expect(sub.read(), 0);
      verifyNever(() => listener(any(), any()));

      controller.state++;
      expect(container.read(counterProvider), 1);
      expect(sub.read(), 0);
      verifyNever(() => listener(any(), any()));

      controller.state++;
      expect(container.read(counterProvider), 2);
      expect(sub.read(), 4);
      verify(() => listener(0, 4)).called(1);

      controller.state++;
      expect(container.read(counterProvider), 3);
      expect(sub.read(), 4);
      verifyNever(() => listener(any(), any()));

      controller.state++;
      expect(container.read(counterProvider), 4);
      expect(sub.read(), 8);
      verify(() => listener(4, 8)).called(1);
    });
  });
}

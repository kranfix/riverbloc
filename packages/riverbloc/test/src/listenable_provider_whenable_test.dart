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
final doubleOddPrevProvider1 = Provider.autoDispose((ref) {
  final when = counterProvider1.when((prev, curr) => prev.isOdd);
  return ref.watch(when.select((value) => 2 * value));
});

void main() {
  group('AlwayAliveProviderListenable.when', () {
    test('Direct call', () {
      _test(
        listenable: counterProvider
            .when((prev, curr) => prev.isOdd)
            .select((value) => 2 * value),
        getController: (container) => container.read(counterProvider.notifier),
        getState: (container) => container.read(counterProvider),
      );
    });

    test('Inside a provider', () {
      _test(
        listenable: doubleOddPrevProvider,
        getController: (container) => container.read(counterProvider.notifier),
        getState: (container) => container.read(counterProvider),
      );
    });
  });

  group('ProviderListenable.when', () {
    test('Direct call', () {
      _test(
        listenable: counterProvider1
            .when((prev, curr) => prev.isOdd)
            .select((value) => 2 * value),
        getController: (container) => container.read(counterProvider1.notifier),
        getState: (container) => container.read(counterProvider1),
      );
    });

    test('Inside a provider', () {
      _test(
        listenable: doubleOddPrevProvider1,
        getController: (container) => container.read(counterProvider1.notifier),
        getState: (container) => container.read(counterProvider1),
      );
    });
  });
}

typedef ControllerGetter<T> = StateController<T> Function(
  ProviderContainer container,
);
typedef StateGetter<T> = T Function(ProviderContainer container);

void _test({
  required ProviderListenable<int> listenable,
  required ControllerGetter<int> getController,
  required StateGetter<int> getState,
}) {
  final container = ProviderContainer();
  addTearDown(container.dispose);

  final listener = Listener<int>();

  final sub = container.listen(
    listenable,
    listener.call,
    fireImmediately: true,
  );
  addTearDown(sub.close);
  final controller = getController(container);

  verify(() => listener(null, 0)).called(1);
  expect(getState(container), 0);
  expect(sub.read(), 0);
  verifyNever(() => listener(any(), any()));

  controller.state++;
  expect(getState(container), 1);
  expect(sub.read(), 0);
  verifyNever(() => listener(any(), any()));

  controller.state++;
  expect(getState(container), 2);
  expect(sub.read(), 4);
  verify(() => listener(0, 4)).called(1);

  controller.state++;
  expect(getState(container), 3);
  expect(sub.read(), 4);
  verifyNever(() => listener(any(), any()));

  controller.state++;
  expect(getState(container), 4);
  expect(sub.read(), 8);
  verify(() => listener(4, 8)).called(1);
}

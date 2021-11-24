import 'package:riverbloc/riverbloc.dart';
import 'package:test/test.dart';

import '../helpers/helpers.dart';

final counterProviderFamily =
    BlocProvider.family.autoDispose<CounterCubit, int, int>(
  (ref, int arg) => CounterCubit(arg),
);

void main() {
  group('Read multiple times', () {
    test(
        'in the same cycle of event-loop without listen '
        'must create different blocs', () async {
      final container = ProviderContainer();

      final counterProvider1 = counterProviderFamily(1);
      expect(counterProvider1, equals(counterProviderFamily(1)));

      await Future(() {});

      expect(counterProvider1, equals(counterProvider1));

      container.dispose();
    });

    test(
        'without listen should create different blocs '
        'after a cycle of event-loop', () async {
      final container = ProviderContainer();

      final counterProvider = counterProviderFamily(1);

      final counterBloc = container.read(counterProvider.bloc);
      final counterBloc2 = container.read(counterProvider.bloc);

      expect(counterBloc, equals(counterBloc2));
      expect(counterBloc.isClosed, false);

      await Future(() {});
      expect(counterBloc.isClosed, true);

      final counterBloc3 = container.read(counterProviderFamily(1).bloc);
      expect(counterBloc, isNot(equals(counterBloc3)));
      expect(counterBloc3.isClosed, false);

      await Future(() {});
      expect(counterBloc.isClosed, true);
      expect(counterBloc3.isClosed, true);

      container.dispose();
    });

    test('with listen should create only one bloc', () async {
      final container = ProviderContainer();

      final listener = Listener<int>();

      final sub = container.listen<int>(
        counterProviderFamily(1),
        listener,
        fireImmediately: true,
      );

      final counterBloc1 = container.read(counterProviderFamily(1).bloc);
      final counterBloc2 = container.read(counterProviderFamily(1).bloc);

      expect(counterBloc1, equals(counterBloc2));
      expect(counterBloc1.isClosed, false);

      await Future(() {});

      final counterBloc3 = container.read(counterProviderFamily(1).bloc);

      expect(counterBloc1, equals(counterBloc3));
      expect(counterBloc1.isClosed, false);

      sub.close();

      await Future(() {});

      expect(counterBloc1.isClosed, true);
    });
  });
}

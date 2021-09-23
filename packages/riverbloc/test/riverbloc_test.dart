import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverbloc/riverbloc.dart';
import 'package:riverpod/riverpod.dart';

import 'helpers/helpers.dart';

final counterBlocProvider =
    BlocProvider<CounterBloc, int>((ref) => CounterBloc(0));

final counterCubitProvider =
    BlocProvider<CounterCubit, int>((ref) => CounterCubit(0));

void main() {
  group('Provider names', () {
    test('BlocProvider.notifier with no name', () {
      final counterBlocProvider = BlocProvider<CounterBloc, int>(
        (ref) => CounterBloc(0),
      );
      expect(counterBlocProvider.notifier.name, isNull);
      expect(counterBlocProvider.stream.name, isNull);
    });

    test('BlocProvider.notifier with name', () {
      final counterBlocProvider = BlocProvider<CounterBloc, int>(
        (ref) => CounterBloc(0),
        name: 'counter',
      );
      expect(counterBlocProvider.notifier.name, 'counter.notifier');
      expect(counterBlocProvider.stream.name, 'counter.stream');
    });
  });

  group('BlocProvider.bloc', () {
    test('BlocProvider.bloc get BlocBase Object', () {
      final container = ProviderContainer();
      final counterCubit = container.read(counterCubitProvider.bloc);

      expect(counterCubit, isA<BlocBase>());
    });

    test('BlocProvider.bloc equals BlocProvider.notifier', () {
      final container = ProviderContainer();
      final bloc = container.read(counterCubitProvider.bloc);
      final notifier = container.read(counterCubitProvider.notifier);

      expect(bloc, equals(notifier));
    });
  });

  group('Bloc test', () {
    test(
        'reads bloc with default state 0 and applies increments and decrements',
        () async {
      final container = ProviderContainer();

      final counterBloc = container.read(counterBlocProvider.notifier);

      expect(counterBloc.state, 0);

      container.read(counterBlocProvider.notifier).add(Incremented());
      await Future(() {});
      expect(counterBloc.state, 1);

      container.read(counterBlocProvider.notifier).add(Incremented());
      container.read(counterBlocProvider.notifier).add(Incremented());
      await Future(() {});
      expect(counterBloc.state, 3);

      container.read(counterBlocProvider.notifier).add(Decremented());
      await Future(() {});
      expect(counterBloc.state, 2);
    });

    test('defaults to 0 and notify listeners when value changes', () async {
      final container = ProviderContainer();
      final counterBloc = container.read(counterBlocProvider.notifier);

      expect(counterBloc.state, 0);
      expect(container.read(counterBlocProvider), 0);

      for (var count = 0; count < 10; count++) {
        container.read(counterBlocProvider.notifier).add(Incremented());
        expect(container.read(counterBlocProvider), count);
        await Future(() {});
        expect(counterBloc.state, count + 1);
        expect(container.read(counterBlocProvider), count + 1);
      }
    });

    test('bloc resubscribe', () async {
      final container = ProviderContainer();
      final counterBloc = container.read(counterBlocProvider.notifier);

      expect(counterBloc.state, 0);
      expect(container.read(counterBlocProvider), 0);

      for (var i = 0; i < 2; i++) {
        counterBloc.add(Incremented());
      }
      await Future(() {});
      expect(container.read(counterBlocProvider), 2);

      final counterBloc2 = container.refresh(counterBlocProvider.notifier);
      expect(counterBloc2, isNot(equals(counterBloc)));
      expect(
        container.read(counterBlocProvider.notifier),
        equals(counterBloc2),
      );

      expect(counterBloc2.state, 0);
      expect(container.read(counterBlocProvider), 0);
    });

    test('BlocProvider with auto dispose', () async {
      final container = ProviderContainer();

      var isBlocClosed = false;

      final counterBlocProvider = BlocProvider<CounterBloc, int>(
        (ref) => CounterBloc(0, onClose: () => isBlocClosed = true),
      );
      final counterBloc = container.read(counterBlocProvider.notifier);

      expect(counterBloc.state, 0);
      expect(container.read(counterBlocProvider), 0);

      counterBloc.add(Incremented());
      await Future(() {});

      container.dispose();

      expect(isBlocClosed, true);
    });

    test('BlocProvider override with provider', () async {
      final counterBloc = CounterBloc(3);
      final counterProvider2 =
          BlocProvider<CounterBloc, int>((ref) => counterBloc);
      final container = ProviderContainer(
        overrides: [
          counterBlocProvider.overrideWithProvider(counterProvider2),
        ],
      );

      expect(container.read(counterBlocProvider.notifier), equals(counterBloc));
      expect(container.read(counterProvider2.notifier), equals(counterBloc));

      expect(counterBloc.state, 3);
      expect(container.read(counterBlocProvider), 3);
      expect(container.read(counterProvider2), 3);

      container.read(counterProvider2.notifier).add(Incremented());
      await Future(() {});
      expect(counterBloc.state, 4);
      expect(container.read(counterBlocProvider), 4);
      expect(container.read(counterProvider2), 4);

      container.read(counterBlocProvider.notifier).add(Incremented());
      await Future(() {});
      expect(counterBloc.state, 5);
      expect(container.read(counterBlocProvider), 5);
      expect(container.read(counterProvider2), 5);
    });

    test('BlocStateProvider override with value', () async {
      final bloc2 = CounterBloc(3);
      final container = ProviderContainer(
        overrides: [
          counterBlocProvider.overrideWithValue(bloc2),
        ],
      );

      expect(container.read(counterBlocProvider.notifier), equals(bloc2));

      expect(container.read(counterBlocProvider), 3);
      expect(bloc2.state, 3);

      bloc2.add(Incremented());
      await Future(() {});
      expect(container.read(counterBlocProvider), 4);
      expect(bloc2.state, 4);

      container.read(counterBlocProvider.notifier).add(Incremented());
      await Future(() {});
      expect(container.read(counterBlocProvider), 5);
      expect(bloc2.state, 5);
    });
  });

  group('Cubit test', () {
    test('reads cubit with default state 0 and increments it', () {
      final container = ProviderContainer();

      final counterCubit = container.read(counterCubitProvider.notifier);

      expect(counterCubit.state, 0);

      container.read(counterCubitProvider.notifier).increment();

      expect(counterCubit.state, 1);
    });

    test('defaults to 0 and notify listeners when value changes', () async {
      final container = ProviderContainer();

      final counterCubit = container.read(counterCubitProvider.notifier);

      expect(counterCubit.state, 0);
      expect(container.read(counterCubitProvider), 0);

      for (var count = 0; count < 10; count++) {
        container.read(counterCubitProvider.notifier).increment();
        expect(container.read(counterCubitProvider), count);
        expect(counterCubit.state, count + 1);
        await Future(() {});
        expect(container.read(counterCubitProvider), count + 1);
      }
    });

    test('cubit resubscribe', () async {
      final container = ProviderContainer();
      final counterCubit = container.read(counterCubitProvider.notifier);

      expect(counterCubit.state, 0);
      expect(container.read(counterCubitProvider), 0);

      for (var i = 0; i < 2; i++) {
        counterCubit.increment();
      }
      await Future(() {});
      expect(container.read(counterCubitProvider), 2);

      expect(
        container.refresh(counterCubitProvider),
        equals(counterCubit.state),
      );

      final counterCubit2 = container.refresh(counterCubitProvider.notifier);
      expect(counterCubit2, isNot(equals(counterCubit)));
      expect(
        container.read(counterCubitProvider.notifier),
        equals(counterCubit2),
      );

      expect(counterCubit2.state, 0);
      expect(container.read(counterCubitProvider), 0);
    });

    test('Cubit<T>.stream with non-null T', () async {
      final pod = BlocProvider<CounterCubit, int>((ref) => CounterCubit(5));
      final container = ProviderContainer();

      expect(container.read(pod.stream), equals(const AsyncLoading<int>()));

      container.read(pod.notifier).increment();
      await Future(() {});

      expect(container.read(pod.stream), equals(const AsyncData(6)));
      expect(container.read(pod), 6);
    });

    test('Cubit<T?>.stream with nullable T', () async {
      final pod = BlocProvider<NullCounterCubit, int?>(
        (ref) => NullCounterCubit(),
      );
      final container = ProviderContainer();

      expect(container.read(pod.stream), equals(const AsyncLoading<int?>()));
      expect(container.read(pod), isNull);

      container.read(pod.notifier).increment();
      await Future(() {});

      expect(container.read(pod.stream), equals(const AsyncData<int?>(0)));
      expect(container.read(pod), 0);
    });

    test('BlocProvider overrided with provider', () {
      final counterCubit = CounterCubit(3);
      final counterProvider2 =
          BlocProvider<CounterCubit, int>((ref) => counterCubit);
      final container = ProviderContainer(
        overrides: [
          counterCubitProvider.overrideWithProvider(counterProvider2),
        ],
      );

      expect(container.read(counterCubitProvider.notifier), counterCubit);
      expect(container.read(counterCubitProvider), 3);
    });

    test('BlocProvider overrided with value', () {
      final counterCubit = CounterCubit(5);
      final container = ProviderContainer(
        overrides: [
          counterCubitProvider.overrideWithValue(counterCubit),
        ],
      );
      expect(container.read(counterCubitProvider), 5);
      expect(container.read(counterCubitProvider.notifier).state, 5);
    });
  });

  group('BlocProvider.setupOverride', () {
    test('override', () {
      final cubit2 = CounterCubit(3);

      final counterCubitProvider2 = BlocProvider<CounterCubit, int>(
        (ref) => cubit2,
        name: 'cubit2',
      );

      final override =
          counterCubitProvider.overrideWithProvider(counterCubitProvider2);
      expect(override, isA<ProviderOverride>());

      final container = ProviderContainer(overrides: [override]);
      final cubit = container.read(counterCubitProvider.notifier);
      expect(cubit, equals(cubit2));
    });
  });

  group('BlocProvider.when', () {
    test('rebuilds when current is even', () async {
      final container = ProviderContainer();

      final rawListener = Listener<int>();
      final conditionedListener = Listener<int>();
      final conditionedSelectorListener = Listener<int>();

      final conditionedProvider =
          counterCubitProvider.when((prev, curr) => (prev + curr) % 5 == 0);

      final conditionedSelectorProvider =
          conditionedProvider.select((val) => 2 * val);

      final sub1 = container.listen<int>(
        counterCubitProvider,
        rawListener,
        fireImmediately: true,
      );
      final sub2 = container.listen<int>(
        conditionedProvider,
        conditionedListener,
        fireImmediately: true,
      );
      final sub3 = container.listen<int>(
        conditionedSelectorProvider,
        conditionedSelectorListener,
        fireImmediately: true,
      );

      expect(sub1.read(), 0);
      expect(sub2.read(), 0);
      expect(sub3.read(), 2 * 0);
      verify(() => rawListener(0)).called(1);
      verify(() => conditionedListener(0)).called(1);
      verify(() => conditionedSelectorListener(0)).called(1);

      final rawValues = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9];
      final conditionedValues = <int>[0, 0, 3, 0, 0, 0, 0, 8, 0];
      var currenteConditionedValue = 0;

      for (var i = 0; i < rawValues.length; i++) {
        container.read(counterCubitProvider.bloc).increment();
        await Future(() {});

        final counter = rawValues[i];
        expect(sub1.read(), counter);
        verify(() => rawListener(counter)).called(1);

        final coditionedValue = conditionedValues[i];
        if (coditionedValue == 0) {
          expect(sub2.read(), currenteConditionedValue);
          expect(sub3.read(), 2 * currenteConditionedValue);
          verifyNever(() => conditionedListener(any()));
          verifyNever(() => conditionedSelectorListener(any()));
        } else {
          currenteConditionedValue = coditionedValue;
          expect(sub2.read(), coditionedValue);
          expect(sub3.read(), 2 * coditionedValue);
          verify(() => conditionedListener(coditionedValue)).called(1);
          verify(() => conditionedSelectorListener(2 * coditionedValue))
              .called(1);
        }
      }

      sub1.close();
      sub2.close();
      sub3.close();
    });
  });
}

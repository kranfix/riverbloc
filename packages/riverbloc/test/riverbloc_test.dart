import 'package:riverbloc/riverbloc.dart';
import 'package:test/test.dart';

import 'helpers/helpers.dart';

final counterProvider = BlocProv((ref) => CounterBloc(0));

final counterCubitProvider = BlocProv((ref) => CounterCubit(0));

void main() {
  group('Provider names', () {
    test('BlocProvider.bloc with no name', () {
      final counterBlocProvider = BlocProv((ref) => CounterBloc(0));
      expect(counterBlocProvider.bloc.name, isNull);
      expect(counterBlocProvider.stream.name, isNull);
    });

    test('BlocProvider.bloc with name', () {
      final counterBlocProvider = BlocProv(
        (ref) => CounterBloc(0),
        name: 'counter',
      );
      expect(counterBlocProvider.bloc.name, 'counter.notifier');
      expect(counterBlocProvider.stream.name, 'counter.stream');
    });
  });

  group('BlocProvider.scoped', () {
    test('direct usage must throw UnimplementedProviderError', () {
      final provider = BlocProvider<CounterBloc, int>.scoped('someName');
      final container = ProviderContainer();
      expect(
        () => container.read(provider.bloc),
        throwsA(isA<UnimplementedProviderError>()),
      );

      try {
        container.read(provider.bloc);
      } catch (e) {
        if (e is UnimplementedProviderError) {
          expect(e.name, 'someName');
        } else {
          fail('unexpected exception $e');
        }
      }
    });
  });

  group('BlocProvider.notifier', () {
    test('BlocProvider.notifier gets BlocBase Object', () {
      final container = ProviderContainer();
      final counterCubit = container.read(counterCubitProvider.notifier);

      expect(counterCubit, isA<CounterCubit>());
    });

    test('BlocProvider.notifier equals BlocProvider.bloc', () {
      final container = ProviderContainer();
      final bloc = container.read(counterCubitProvider.bloc);
      final notifier = container.read(counterCubitProvider.notifier);

      expect(bloc, equals(notifier));
    });
  });

  group('ref.bloc', () {
    test('ref.bloc is same than created bloc', () {
      late CounterCubit Function() getBloc;
      final counterCubitProvider = BlocProv<CounterCubit>((ref) {
        getBloc = () => ref.bloc;
        return CounterCubit(0);
      });

      final container = ProviderContainer();

      final bloc = container.read(counterCubitProvider.bloc);
      expect(getBloc(), same(bloc));
    });
  });

  group('Bloc test', () {
    test(
        'reads bloc with default state 0 and applies increments and decrements',
        () async {
      final container = ProviderContainer();

      final counterBloc = container.read(counterProvider.bloc);

      expect(counterBloc.state, 0);

      container.read(counterProvider.bloc).add(Incremented());
      await Future(() {});
      expect(counterBloc.state, 1);

      container.read(counterProvider.bloc).add(Incremented());
      container.read(counterProvider.bloc).add(Incremented());
      await Future(() {});
      expect(counterBloc.state, 3);

      container.read(counterProvider.bloc).add(Decremented());
      await Future(() {});
      expect(counterBloc.state, 2);
    });

    test('defaults to 0 and notify listeners when value changes', () async {
      final container = ProviderContainer();
      final counterBloc = container.read(counterProvider.bloc);

      expect(counterBloc.state, 0);
      expect(container.read(counterProvider), 0);

      for (var count = 0; count < 10; count++) {
        container.read(counterProvider.bloc).add(Incremented());
        expect(container.read(counterProvider), count);
        await Future(() {});
        expect(counterBloc.state, count + 1);
        expect(container.read(counterProvider), count + 1);
      }
    });

    test('bloc resubscribe', () async {
      final container = ProviderContainer();
      final counterBloc = container.read(counterProvider.bloc);

      expect(counterBloc.state, 0);
      expect(container.read(counterProvider), 0);

      for (var i = 0; i < 2; i++) {
        counterBloc.add(Incremented());
      }
      await Future(() {});
      expect(container.read(counterProvider), 2);

      final counterBloc2 = container.refresh(counterProvider.bloc);
      expect(counterBloc2, isNot(equals(counterBloc)));
      expect(
        container.read(counterProvider.bloc),
        equals(counterBloc2),
      );

      expect(counterBloc2.state, 0);
      expect(container.read(counterProvider), 0);
    });

    test('Refresh provider must refresh notifier provider', () {
      var times = 0;
      final counterProvider = BlocProv((ref) {
        times++;
        return CounterCubit(0);
      });

      final container = ProviderContainer();

      final firstBloc = container.read(counterProvider.bloc);
      expect(times, 1);

      container.refresh(counterProvider);
      final secondBloc = container.read(counterProvider.bloc);
      expect(times, 2);
      expect(firstBloc, isNot(same(secondBloc)));
    });

    test('BlocProvider with auto dispose', () async {
      final container = ProviderContainer();

      var isBlocClosed = false;

      final counterBlocProvider = BlocProvider<CounterBloc, int>(
        (ref) => CounterBloc(0, onClose: () => isBlocClosed = true),
      );
      final counterBloc = container.read(counterBlocProvider.bloc);

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
          counterProvider.overrideWithProvider(counterProvider2),
        ],
      );

      expect(container.read(counterProvider.bloc), equals(counterBloc));
      expect(container.read(counterProvider2.bloc), equals(counterBloc));

      expect(counterBloc.state, 3);
      expect(container.read(counterProvider), 3);
      expect(container.read(counterProvider2), 3);

      container.read(counterProvider2.bloc).add(Incremented());
      await Future(() {});
      expect(counterBloc.state, 4);
      expect(container.read(counterProvider), 4);
      expect(container.read(counterProvider2), 4);

      container.read(counterProvider.bloc).add(Incremented());
      await Future(() {});
      expect(counterBloc.state, 5);
      expect(container.read(counterProvider), 5);
      expect(container.read(counterProvider2), 5);
    });

    test('BlocStateProvider override with value', () async {
      final bloc2 = CounterBloc(3);
      final container = ProviderContainer(
        overrides: [
          counterProvider.overrideWithValue(bloc2),
        ],
      );

      expect(container.read(counterProvider.bloc), equals(bloc2));

      expect(container.read(counterProvider), 3);
      expect(bloc2.state, 3);

      bloc2.add(Incremented());
      await Future(() {});
      expect(container.read(counterProvider), 4);
      expect(bloc2.state, 4);

      container.read(counterProvider.bloc).add(Incremented());
      await Future(() {});
      expect(container.read(counterProvider), 5);
      expect(bloc2.state, 5);
    });
  });

  group('Cubit test', () {
    test('reads cubit with default state 0 and increments it', () {
      final container = ProviderContainer();

      final counterCubit = container.read(counterCubitProvider.bloc);

      expect(counterCubit.state, 0);

      container.read(counterCubitProvider.bloc).increment();

      expect(counterCubit.state, 1);
    });

    test('defaults to 0 and notify listeners when value changes', () async {
      final container = ProviderContainer();

      final counterCubit = container.read(counterCubitProvider.bloc);

      expect(counterCubit.state, 0);
      expect(container.read(counterCubitProvider), 0);

      for (var count = 0; count < 10; count++) {
        container.read(counterCubitProvider.bloc).increment();
        expect(container.read(counterCubitProvider), count);
        expect(counterCubit.state, count + 1);
        await Future(() {});
        expect(container.read(counterCubitProvider), count + 1);
      }
    });

    test('cubit resubscribe', () async {
      final container = ProviderContainer();
      final counterCubit = container.read(counterCubitProvider.bloc);

      expect(counterCubit.state, 0);
      expect(container.read(counterCubitProvider), 0);

      for (var i = 0; i < 2; i++) {
        counterCubit.increment();
      }
      await Future(() {});
      expect(container.read(counterCubitProvider), 2);

      expect(
        container.refresh(counterCubitProvider),
        isNot(equals(counterCubit.state)),
      );
      expect(
        container.read(counterCubitProvider.bloc),
        isNot(equals(counterCubit)),
      );

      final counterCubit2 = container.read(counterCubitProvider.bloc);
      expect(counterCubit2.state, 0);
      expect(container.read(counterCubitProvider), 0);

      for (var i = 0; i < 2; i++) {
        counterCubit2.increment();
      }
      await Future(() {});
      expect(
        container.read(counterCubitProvider.bloc),
        equals(counterCubit2),
      );

      expect(counterCubit2.state, 2);
      expect(container.read(counterCubitProvider), 2);

      final counterCubit3 = container.refresh(counterCubitProvider.bloc);
      expect(counterCubit3.state, 0);
      expect(container.read(counterCubitProvider), 0);
      expect(container.read(counterCubitProvider.bloc), equals(counterCubit3));
      expect(counterCubit3, isNot(equals(counterCubit)));
      expect(counterCubit3, isNot(equals(counterCubit2)));
    });

    test('Cubit<T>.stream with non-null T', () async {
      final pod = BlocProvider<CounterCubit, int>((ref) => CounterCubit(5));
      final container = ProviderContainer();

      expect(container.read(pod.stream), equals(const AsyncLoading<int>()));

      container.read(pod.bloc).increment();
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

      container.read(pod.bloc).increment();
      await Future(() {});

      expect(container.read(pod.stream), equals(const AsyncData<int?>(0)));
      expect(container.read(pod), 0);
    });

    test('BlocProvider overridden with provider', () {
      final counterCubit = CounterCubit(3);
      final counterProvider2 =
          BlocProvider<CounterCubit, int>((ref) => counterCubit);
      final container = ProviderContainer(
        overrides: [
          counterCubitProvider.overrideWithProvider(counterProvider2),
        ],
      );

      expect(container.read(counterCubitProvider.bloc), counterCubit);
      expect(container.read(counterCubitProvider), 3);
    });

    test('BlocProvider overridden with value', () {
      final counterCubit = CounterCubit(5);
      final container = ProviderContainer(
        overrides: [
          counterCubitProvider.overrideWithValue(counterCubit),
        ],
      );
      expect(container.read(counterCubitProvider), 5);
      expect(container.read(counterCubitProvider.bloc).state, 5);
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
      final cubit = container.read(counterCubitProvider.bloc);
      expect(cubit, equals(cubit2));
    });
  });

  group('BlocProvider overrides itself', () {
    test('without overrideWithProvider', () async {
      final container1 = ProviderContainer();

      final container2 = ProviderContainer(
        parent: container1,
        overrides: [counterProvider],
      );

      expect(
        container1.read(counterProvider.bloc),
        isNot(equals(container2.read(counterProvider.bloc))),
      );
    });
  });

  /*
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
  */
}

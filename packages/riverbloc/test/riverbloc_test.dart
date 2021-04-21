import 'package:bloc/bloc.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverbloc/riverbloc.dart';

enum CounterEvent { inc, dec }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc(int state, {this.onClose}) : super(state);

  void Function()? onClose;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.inc:
        yield state + 1;
        break;
      case CounterEvent.dec:
      default:
        yield state - 1;
        break;
    }
  }

  @override
  Future<void> close() {
    onClose?.call();
    return super.close();
  }
}

final counterBlocProvider =
    BlocProvider<CounterBloc, int>((ref) => CounterBloc(0));

class CounterCubit extends Cubit<int> {
  CounterCubit(int state) : super(state);

  void increment() => emit(state + 1);
}

final counterCubitProvider =
    BlocProvider<CounterCubit, int>((ref) => CounterCubit(0));

void main() {
  group('BlocProvider commons', () {
    test('BlocProvider.notifier with no name', () {
      final counterBlocProvider = BlocProvider<CounterBloc, int>(
        (ref) => CounterBloc(0),
      );
      expect(counterBlocProvider.notifier.name, isNull);
    });

    test('BlocProvider.notifier with name', () {
      final counterBlocProvider = BlocProvider<CounterBloc, int>(
        (ref) => CounterBloc(0),
        name: 'counter',
      );
      expect(counterBlocProvider.notifier.name, 'counter.notifier');
    });
  });
  group('Bloc test', () {
    test(
        'reads bloc with default state 0 and applies increments and decrements',
        () async {
      final container = ProviderContainer();

      final counterBloc = container.read(counterBlocProvider.notifier);

      expect(counterBloc.state, 0);

      container.read(counterBlocProvider.notifier).add(CounterEvent.inc);
      await Future(() {});
      expect(counterBloc.state, 1);

      container.read(counterBlocProvider.notifier).add(CounterEvent.inc);
      container.read(counterBlocProvider.notifier).add(CounterEvent.inc);
      await Future(() {});
      expect(counterBloc.state, 3);

      container.read(counterBlocProvider.notifier).add(CounterEvent.dec);
      await Future(() {});
      expect(counterBloc.state, 2);
    });

    test('defaults to 0 and notify listeners when value changes', () async {
      final container = ProviderContainer();
      final counterBloc = container.read(counterBlocProvider.notifier);

      expect(counterBloc.state, 0);
      expect(container.read(counterBlocProvider), 0);

      for (var count = 0; count < 10; count++) {
        container.read(counterBlocProvider.notifier).add(CounterEvent.inc);
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
        counterBloc.add(CounterEvent.inc);
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

      counterBloc.add(CounterEvent.inc);
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

      container.read(counterProvider2.notifier).add(CounterEvent.inc);
      await Future(() {});
      expect(counterBloc.state, 4);
      expect(container.read(counterBlocProvider), 4);
      expect(container.read(counterProvider2), 4);

      container.read(counterBlocProvider.notifier).add(CounterEvent.inc);
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

      bloc2.add(CounterEvent.inc);
      await Future(() {});
      expect(container.read(counterBlocProvider), 4);
      expect(bloc2.state, 4);

      container.read(counterBlocProvider.notifier).add(CounterEvent.inc);
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

    test('bloc resubscribe', () async {
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
        equals(counterCubit),
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
}

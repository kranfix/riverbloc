import 'package:bloc/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverbloc/riverbloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit(int state) : super(state);

  void increment() => emit(state + 1);
}

final counterProvider = BlocProvider((ref) => CounterCubit(0));

void main() {
  test('reads cubit with default state 0 and increments it', () {
    final container = ProviderContainer();

    final counterCubit = container.read(counterProvider);

    expect(counterCubit.state, 0);

    container.read(counterProvider).increment();

    expect(counterCubit.state, 1);
  });

  test('defaults to 0 and notify listeners when value changes', () async {
    final container = ProviderContainer();

    final counterCubit = container.read(counterProvider);

    expect(counterCubit.state, 0);
    expect(container.read(counterProvider.state), 0);

    for (var count = 0; count < 10; count++) {
      container.read(counterProvider).increment();
      expect(container.read(counterProvider.state), count);
      expect(counterCubit.state, count + 1);
      await Future.value();
      expect(container.read(counterProvider.state), count + 1);
    }
  });

  test('bloc resubscribe', () async {
    final container = ProviderContainer();
    final counterCubit = container.read(counterProvider);

    expect(counterCubit.state, 0);
    expect(container.read(counterProvider.state), 0);

    for (var i = 0; i < 2; i++) {
      counterCubit.increment();
      await Future.value();
    }
    expect(container.read(counterProvider.state), 2);

    final counterCubit2 = container.refresh(counterProvider);
    expect(counterCubit2, isNot(equals(counterCubit)));
    expect(container.read(counterProvider), equals(counterCubit2));

    expect(counterCubit2.state, 0);
    expect(container.read(counterProvider.state), 0);
  });
}

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
}

import 'package:bloc/bloc.dart' show Cubit;

class CounterCubitBase extends Cubit<int> {
  CounterCubitBase(super.value);

  Future<void> increment([int value = 1]) async {
    for (var i = 0; i < value; i++) {
      emit(state + 1);
      await Future<void>.delayed(const Duration(seconds: 2));
    }
  }

  Future<void> decrement([int value = 1]) async {
    for (var i = 0; i < value; i++) {
      emit(state - 1);
      await Future<void>.delayed(const Duration(seconds: 2));
    }
  }
}

mixin _CounterCubitActions on CounterCubitBase {}

class CounterCubit1 = CounterCubitBase with _CounterCubitActions;
class CounterCubit2 = CounterCubitBase with _CounterCubitActions;
class CounterCubit3 = CounterCubitBase with _CounterCubitActions;

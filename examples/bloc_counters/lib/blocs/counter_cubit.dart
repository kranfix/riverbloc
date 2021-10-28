import 'package:bloc/bloc.dart' show Cubit;

class CounterCubitBase extends Cubit<int> {
  CounterCubitBase(int value) : super(value);

  void increment([int value = 1]) async {
    for (int i = 0; i < value; i++) {
      emit(state + 1);
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void decrement([int value = 1]) async {
    for (int i = 0; i < value; i++) {
      emit(state - 1);
      await Future.delayed(const Duration(seconds: 2));
    }
  }
}

mixin _CounterCubitActions on CounterCubitBase {}

class CounterCubit1 = CounterCubitBase with _CounterCubitActions;
class CounterCubit2 = CounterCubitBase with _CounterCubitActions;
class CounterCubit3 = CounterCubitBase with _CounterCubitActions;

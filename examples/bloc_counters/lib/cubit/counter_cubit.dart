import 'package:bloc/bloc.dart' show Cubit;

class CounterCubitBase extends Cubit<int> {
  CounterCubitBase(int value) : super(value);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}

mixin _CounterCubitActions on CounterCubitBase {}

class CounterCubit1 = CounterCubitBase with _CounterCubitActions;
class CounterCubit2 = CounterCubitBase with _CounterCubitActions;
class CounterCubit3 = CounterCubitBase with _CounterCubitActions;

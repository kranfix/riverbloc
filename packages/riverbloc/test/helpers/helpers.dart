import 'package:bloc/bloc.dart';

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

class CounterCubit extends Cubit<int> {
  CounterCubit(int state) : super(state);

  void increment() => emit(state + 1);
}

class NullCounterCubit extends Cubit<int?> {
  NullCounterCubit([int? state]) : super(state);

  void increment() => emit((state ?? -1) + 1);
}

import 'package:bloc/bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

class Listener<T> extends Mock {
  void call(T value);
}

class SetupOverride extends Mock {
  void call({
    required ProviderBase<dynamic> origin,
    required ProviderBase<dynamic> override,
  });
}

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
  CounterCubit(int state, {this.onClose}) : super(state);

  void Function()? onClose;

  void increment() => emit(state + 1);

  @override
  Future<void> close() {
    onClose?.call();
    return super.close();
  }
}

class NullCounterCubit extends Cubit<int?> {
  NullCounterCubit({int? state, this.onClose}) : super(state);

  void Function()? onClose;

  void increment() => emit((state ?? -1) + 1);

  @override
  Future<void> close() {
    onClose?.call();
    return super.close();
  }
}

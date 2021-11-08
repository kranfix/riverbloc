import 'package:bloc/bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverbloc/riverbloc.dart';
import 'package:riverpod/riverpod.dart';

typedef BlocProv<B extends BlocBase<int>> = BlocProvider<B, int>;
typedef AutoDisposeBlocProv<B extends BlocBase<int>>
    = AutoDisposeBlocProvider<B, int>;

class Listener<T> extends Mock {
  void call(T? prev, T value);
}

class MockSetupOverride extends Mock {
  void call({
    required ProviderBase<dynamic> origin,
    required ProviderBase<dynamic> override,
  });
}

abstract class CounterEvent {}

class Incremented extends CounterEvent {}

class Decremented extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc(int state, {this.onClose}) : super(state) {
    on<Incremented>(_onIncrement);
    on<Decremented>(_onDecrement);
  }

  void _onIncrement(CounterEvent event, Emitter<int> emit) => emit(state + 1);
  void _onDecrement(CounterEvent event, Emitter<int> emit) => emit(state - 1);

  void Function()? onClose;

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

import 'package:bloc/bloc.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart' hide BlocProvider;
import 'package:riverbloc/riverbloc.dart' show BlocProvider;
import 'package:flutter_test/flutter_test.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}

final counterProvider = BlocProvider((ref) => CounterCubit());

void main() {
  group('useRiverBloc', () {
    test('throws assertion if provider is null', () async {
      try {
        useRiverBloc(null);
        fail('should throw AssertionError');
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });
  });
}

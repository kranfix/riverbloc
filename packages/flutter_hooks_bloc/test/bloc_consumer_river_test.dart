import 'package:flutter/widgets.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart' hide BlocProvider;
import 'package:riverbloc/riverbloc.dart';
import 'package:flutter_test/flutter_test.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}

void main() {
  group('BlocConsumer.river', () {
    testWidgets('throws AssertionError if provider is null', (tester) async {
      try {
        await tester.pumpWidget(
          BlocConsumer<CounterCubit, int>.river(
            provider: null,
            listener: null,
            builder: null,
          ),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws AssertionError if listener is null', (tester) async {
      final counterProvider = BlocProvider((ref) => CounterCubit());
      try {
        await tester.pumpWidget(
          BlocConsumer<CounterCubit, int>.river(
            provider: counterProvider,
            listener: null,
            builder: null,
          ),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });
  });
}

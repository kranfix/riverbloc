import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart' hide BlocProvider;
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverbloc/riverbloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}

final counterProvider = BlocProvider((ref) => CounterCubit());

void main() {
  group('BlocBuilder.river', () {
    testWidgets('throws if initialized with null cubit and builder',
        (tester) async {
      try {
        await tester.pumpWidget(
          ProviderScope(
            child: BlocBuilder<CounterCubit, int>.river(
              provider: null,
              builder: (_, __) => const SizedBox(),
            ),
          ),
        );
        fail('provider should not be null');
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });
  });
}

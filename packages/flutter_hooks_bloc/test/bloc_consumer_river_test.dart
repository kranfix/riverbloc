import 'package:flutter/material.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart' hide BlocProvider;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverbloc/riverbloc.dart';
import 'package:flutter_test/flutter_test.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}

final counterProvider = BlocProvider((ref) => CounterCubit());

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

    testWidgets('throws AssertionError if builder is null', (tester) async {
      try {
        await tester.pumpWidget(
          BlocConsumer<CounterCubit, int>.river(
            provider: counterProvider,
            listener: (_, __) {},
            builder: null,
          ),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets(
        'accesses the bloc directly and passes initial state to builder and '
        'nothing to listener', (tester) async {
      final counterCubit = CounterCubit();
      final counterProvider = BlocProvider((ref) => counterCubit);
      final listenerStates = <int>[];
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BlocConsumer<CounterCubit, int>.river(
                provider: counterProvider,
                builder: (context, state) {
                  return Text('State: $state');
                },
                listener: (_, state) {
                  listenerStates.add(state);
                },
              ),
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(listenerStates, isEmpty);
    });

    testWidgets(
        'accesses the bloc directly '
        'and passes multiple states to builder and listener', (tester) async {
      final counterCubit = CounterCubit();
      final counterProvider = BlocProvider((ref) => counterCubit);
      final listenerStates = <int>[];
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BlocConsumer<CounterCubit, int>.river(
                provider: counterProvider,
                builder: (context, state) {
                  return Text('State: $state');
                },
                listener: (_, state) {
                  listenerStates.add(state);
                },
              ),
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(listenerStates, isEmpty);
      counterCubit.increment();
      await tester.pump();
      expect(find.text('State: 1'), findsOneWidget);
      expect(listenerStates, [1]);
    });

    testWidgets('does not trigger rebuilds when buildWhen evaluates to false',
        (tester) async {
      final counterCubit = CounterCubit();
      final counterProvider = BlocProvider((ref) => counterCubit);
      final listenerStates = <int>[];
      final builderStates = <int>[];
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BlocConsumer<CounterCubit, int>.river(
                provider: counterProvider,
                buildWhen: (previous, current) => (previous + current) % 3 == 0,
                builder: (context, state) {
                  builderStates.add(state);
                  return Text('State: $state');
                },
                listener: (_, state) {
                  listenerStates.add(state);
                },
              ),
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(builderStates, [0]);
      expect(listenerStates, isEmpty);

      counterCubit.increment();
      await tester.pump();

      expect(find.text('State: 0'), findsOneWidget);
      expect(builderStates, [0]);
      expect(listenerStates, [1]);

      counterCubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('State: 2'), findsOneWidget);
      expect(builderStates, [0, 2]);
      expect(listenerStates, [1, 2]);
    });
  });
}

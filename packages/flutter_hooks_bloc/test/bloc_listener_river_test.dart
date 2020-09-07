import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart' hide BlocProvider;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverbloc/riverbloc.dart' show BlocProvider;
import 'package:flutter_test/flutter_test.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}

final counterProvider = BlocProvider((ref) => CounterCubit());

class MyApp extends StatelessWidget {
  const MyApp({Key key, this.onListenerCalled}) : super(key: key);

  final BlocWidgetListener<int> onListenerCalled;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: HookBuilder(
          builder: (context) {
            useRiverBloc<CounterCubit, int>(
              counterProvider,
              onEmitted: (context, _, state) {
                onListenerCalled?.call(context, state);
                return false;
              },
            );
            return Column(
              children: [
                RaisedButton(
                  key: const Key('cubit_listener_reset_button'),
                  onPressed: () {
                    context.refresh(counterProvider);
                  },
                ),
                RaisedButton(
                  key: const Key('cubit_listener_increment_button'),
                  onPressed: () => context.read(counterProvider).increment(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

void main() {
  group('BlocListener.river', () {
    testWidgets('throws if initialized with null cubit, listener, and child',
        (tester) async {
      try {
        await tester.pumpWidget(
          BlocListener<Cubit, dynamic>.river(
            provider: null,
            listener: null,
            child: null,
          ),
        );
        fail('should throw AssertionError');
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with null listener and child',
        (tester) async {
      try {
        await tester.pumpWidget(
          BlocListener<CounterCubit, int>.river(
            provider: counterProvider,
            listener: null,
            child: null,
          ),
        );
        fail('should throw AssertionError');
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('renders child properly', (tester) async {
      const targetKey = Key('cubit_listener_container');
      await tester.pumpWidget(
        ProviderScope(
          child: BlocListener<CounterCubit, int>.river(
            provider: counterProvider,
            listener: (_, __) {},
            child: const SizedBox(key: targetKey),
          ),
        ),
      );
      expect(find.byKey(targetKey), findsOneWidget);
    });

    testWidgets('calls listener on single state change', (tester) async {
      final counterCubit = CounterCubit();
      final counterProvider = BlocProvider((ref) => counterCubit);
      final states = <int>[];
      const expectedStates = [1];
      await tester.pumpWidget(
        ProviderScope(
          child: BlocListener<CounterCubit, int>.river(
            provider: counterProvider,
            listener: (_, state) {
              states.add(state);
            },
            child: const SizedBox(),
          ),
        ),
      );
      counterCubit.increment();
      await tester.pump();
      expect(states, expectedStates);
    });

    testWidgets('calls listener on multiple state change', (tester) async {
      final counterCubit = CounterCubit();
      final counterProvider = BlocProvider((ref) => counterCubit);
      final states = <int>[];
      const expectedStates = [1, 2];
      await tester.pumpWidget(
        ProviderScope(
          child: BlocListener<CounterCubit, int>.river(
            provider: counterProvider,
            listener: (_, state) {
              states.add(state);
            },
            child: const SizedBox(),
          ),
        ),
      );
      counterCubit.increment();
      await tester.pump();
      counterCubit.increment();
      await tester.pump();
      expect(states, expectedStates);
    });

    testWidgets(
        'updates when the cubit is changed at runtime to a different cubit '
        'and unsubscribes from old cubit', (tester) async {
      var listenerCallCount = 0;
      int latestState;
      final incrementFinder = find.byKey(
        const Key('cubit_listener_increment_button'),
      );
      final resetCubitFinder = find.byKey(
        const Key('cubit_listener_reset_button'),
      );
      await tester.pumpWidget(ProviderScope(
        child: MyApp(
          onListenerCalled: (_, state) {
            listenerCallCount++;
            latestState = state;
          },
        ),
      ));

      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 1);
      expect(latestState, 1);

      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 2);
      expect(latestState, 2);

      await tester.tap(resetCubitFinder);
      await tester.pump();
      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 3);
      expect(latestState, 1);
    });

    testWidgets(
        'calls listenWhen on single state change with correct previous '
        'and current states', (tester) async {
      int latestPreviousState;
      var listenWhenCallCount = 0;
      final states = <int>[];
      final counterCubit = CounterCubit();
      final counterProvider = BlocProvider((ref) => counterCubit);
      const expectedStates = [1];
      await tester.pumpWidget(
        ProviderScope(
          child: BlocListener<CounterCubit, int>.river(
            provider: counterProvider,
            listenWhen: (previous, state) {
              listenWhenCallCount++;
              latestPreviousState = previous;
              states.add(state);
              return true;
            },
            listener: (_, __) {},
            child: const SizedBox(),
          ),
        ),
      );
      counterCubit.increment();
      await tester.pump();

      expect(states, expectedStates);
      expect(listenWhenCallCount, 1);
      expect(latestPreviousState, 0);
    });

    testWidgets(
        'calls listenWhen with previous listener state and current cubit state',
        (tester) async {
      int latestPreviousState;
      var listenWhenCallCount = 0;
      final states = <int>[];
      final counterCubit = CounterCubit();
      const expectedStates = [2];
      await tester.pumpWidget(
        BlocListener<CounterCubit, int>(
          cubit: counterCubit,
          listenWhen: (previous, state) {
            listenWhenCallCount++;
            if ((previous + state) % 3 == 0) {
              latestPreviousState = previous;
              states.add(state);
              return true;
            }
            return false;
          },
          listener: (_, __) {},
          child: const SizedBox(),
        ),
      );
      counterCubit.increment();
      await tester.pump();
      counterCubit.increment();
      await tester.pump();
      counterCubit.increment();
      await tester.pump();

      expect(states, expectedStates);
      expect(listenWhenCallCount, 3);
      expect(latestPreviousState, 1);
    });

    testWidgets(
        'does not call listener when listenWhen returns false on single state '
        'change', (tester) async {
      final states = <int>[];
      const expectedStates = <int>[];
      final counterCubit = CounterCubit();
      final counterProvider = BlocProvider((ref) => counterCubit);
      await tester.pumpWidget(
        ProviderScope(
          child: BlocListener<CounterCubit, int>.river(
            provider: counterProvider,
            listenWhen: (_, __) => false,
            listener: (_, state) => states.add(state),
            child: const SizedBox(),
          ),
        ),
      );
      counterCubit.increment();
      await tester.pump();

      expect(states, expectedStates);
    });

    testWidgets(
        'calls listener when listenWhen returns true on single state change',
        (tester) async {
      final states = <int>[];
      final counterCubit = CounterCubit();
      final counterProvider = BlocProvider((ref) => counterCubit);
      const expectedStates = [1];
      await tester.pumpWidget(
        ProviderScope(
          child: BlocListener<CounterCubit, int>.river(
            provider: counterProvider,
            listenWhen: (_, __) => true,
            listener: (_, state) => states.add(state),
            child: const SizedBox(),
          ),
        ),
      );
      counterCubit.increment();
      await tester.pump();

      expect(states, expectedStates);
    });

    testWidgets(
        'does not call listener when listenWhen returns false '
        'on multiple state changes', (tester) async {
      final states = <int>[];
      final counterCubit = CounterCubit();
      final counterProvider = BlocProvider((ref) => counterCubit);
      const expectedStates = <int>[];
      await tester.pumpWidget(
        ProviderScope(
          child: BlocListener<CounterCubit, int>.river(
            provider: counterProvider,
            listenWhen: (_, __) => false,
            listener: (_, state) => states.add(state),
            child: const SizedBox(),
          ),
        ),
      );
      counterCubit.increment();
      await tester.pump();
      counterCubit.increment();
      await tester.pump();
      counterCubit.increment();
      await tester.pump();
      counterCubit.increment();
      await tester.pump();

      expect(states, expectedStates);
    });

    testWidgets(
        'calls listener when listenWhen returns true on multiple state change',
        (tester) async {
      final states = <int>[];
      final counterCubit = CounterCubit();
      final counterProvider = BlocProvider((ref) => counterCubit);
      const expectedStates = [1, 2, 3, 4];
      await tester.pumpWidget(
        ProviderScope(
          child: BlocListener<CounterCubit, int>.river(
            provider: counterProvider,
            listenWhen: (_, __) => true,
            listener: (_, state) => states.add(state),
            child: const SizedBox(),
          ),
        ),
      );
      counterCubit.increment();
      await tester.pump();
      counterCubit.increment();
      await tester.pump();
      counterCubit.increment();
      await tester.pump();
      counterCubit.increment();
      await tester.pump();

      expect(states, expectedStates);
    });
  });

  group('BlocListener.river diagnostics', () {
    test('does not prints the state after the widget runtimeType', () async {
      final blocListener = BlocListener<CounterCubit, int>.river(
        provider: counterProvider,
        listener: (context, state) {},
        child: const SizedBox(),
      );
      expect(
        blocListener.asDiagnosticsNode().toString(),
        'BlocListener<CounterCubit, int>.river',
      );
    });

    test('prints the state after the widget runtimeType', () async {
      final cubit = CounterCubit();
      final counterProvider = BlocProvider((ref) => cubit);
      final blocListener = BlocListener<CounterCubit, int>.river(
        provider: counterProvider,
        listener: (context, state) {},
        child: const SizedBox(),
      );

      expect(
        blocListener.toDiagnosticsNode().toStringDeep(),
        equalsIgnoringHashCodes(
          'BlocListener<CounterCubit, int>(povider: BlocProvider<CounterCubit>#00000())\n',
        ),
      );
    });
  });
}

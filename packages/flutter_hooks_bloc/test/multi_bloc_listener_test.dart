import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}

mixin _DecrementerMixin on CounterCubit {
  void decrement() => emit(state - 1);
}

class CounterCubit2 = CounterCubit with _DecrementerMixin;

void main() {
  group('MultiBlocListener', () {
    testWidgets('throws if initialized with no listeners and no child',
        (tester) async {
      try {
        await tester.pumpWidget(
          MultiBlocListener(listeners: null, child: null),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with no listeners', (tester) async {
      try {
        await tester.pumpWidget(
          MultiBlocListener(listeners: null, child: const SizedBox()),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized listeners list is empty',
        (tester) async {
      try {
        await tester.pumpWidget(
          MultiBlocListener(
            listeners: [],
            child: const SizedBox(),
          ),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with no child', (tester) async {
      try {
        final counterCubit = CounterCubit();
        await tester.pumpWidget(
          MultiBlocListener(
            listeners: [
              BlocListener<CounterCubit, int>(
                cubit: counterCubit,
                listener: (context, state) {},
              )
            ],
            child: null,
          ),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('calls listeners on state changes', (tester) async {
      final statesA = <int>[];
      const expectedStatesA = [1, 2];
      final counterCubitA = CounterCubit();

      final statesB = <int>[];
      final expectedStatesB = [1];
      final counterCubitB = CounterCubit();

      await tester.pumpWidget(
        MultiBlocListener(
          listeners: [
            BlocListener<CounterCubit, int>(
              cubit: counterCubitA,
              listener: (context, state) => statesA.add(state),
            ),
            BlocListener<CounterCubit, int>(
              cubit: counterCubitB,
              listener: (context, state) => statesB.add(state),
            ),
          ],
          child: const SizedBox(key: Key('multiCubitListener_child')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('multiCubitListener_child')), findsOneWidget);

      counterCubitA.increment();
      await tester.pump();
      counterCubitA.increment();
      await tester.pump();
      counterCubitB.increment();
      await tester.pump();

      expect(statesA, expectedStatesA);
      expect(statesB, expectedStatesB);
    });

    testWidgets('calls listeners on state changes without explicit types',
        (tester) async {
      final statesA = <int>[];
      const expectedStatesA = [1, 2];
      final counterCubitA = CounterCubit();

      final statesB = <int>[];
      final expectedStatesB = [1];
      final counterCubitB = CounterCubit();

      await tester.pumpWidget(
        MultiBlocListener(
          listeners: [
            BlocListener(
              cubit: counterCubitA,
              listener: (BuildContext context, int state) => statesA.add(state),
            ),
            BlocListener(
              cubit: counterCubitB,
              listener: (BuildContext context, int state) => statesB.add(state),
            ),
          ],
          child: const SizedBox(key: Key('multiCubitListener_child')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('multiCubitListener_child')), findsOneWidget);

      counterCubitA.increment();
      await tester.pump();
      counterCubitA.increment();
      await tester.pump();
      counterCubitB.increment();
      await tester.pump();

      expect(statesA, expectedStatesA);
      expect(statesB, expectedStatesB);
    });

    testWidgets('throws error on non-null BlocListener.child', (tester) async {
      final counterCubit = CounterCubit();

      try {
        await tester.pumpWidget(
          MultiBlocListener(
            listeners: [
              BlocListener(
                cubit: counterCubit,
                listener: (BuildContext context, int state) {},
                child: const SizedBox(),
              ),
            ],
            child: const SizedBox(key: Key('multiCubitListener_child')),
          ),
        );
        fail('should throw AssertionError');
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });
  });

  group('BlocListenerTree', () {
    testWidgets('throws assertion on null listeners', (tester) async {
      try {
        BlocListenerTree(listeners: null);
        fail('BlocListenerTree should not have null listener');
      } catch (e) {
        expect(e, isAssertionError);
      }
    });
  });

  group('MultiBlocListener diagnostics', () {
    test('prints a tree', () async {
      final cubit2 = CounterCubit2();
      final multiListener = MultiBlocListener(
        listeners: [
          BlocListener<CounterCubit, int>(
            listener: (context, state) {},
          ),
          BlocListener<CounterCubit2, int>(
            cubit: cubit2,
            listener: (context, state) {},
          ),
        ],
        child: const SizedBox(),
      );

      expect(
        multiListener
            .toDiagnosticsNode(
                name: 'MyMultiBlocListener',
                style: DiagnosticsTreeStyle.singleLine)
            .toStringDeep(),
        equalsIgnoringHashCodes(
          'MyMultiBlocListener: MultiBlocListener(\n'
          '  ├listeners: BlocListenerTree#00000\n'
          '   ├BlocListener<CounterCubit, int>\n'
          '   └BlocListener<CounterCubit2, int>: 0\n'
          '  )',
        ),
      );
    });
  });
}

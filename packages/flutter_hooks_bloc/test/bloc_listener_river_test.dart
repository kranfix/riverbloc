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
  });
}

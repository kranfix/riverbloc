import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit(int state) : super(state);

  void increment() => emit(state + 1);

  void decrement() => emit(state - 1);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterCubit>(
      create: (_) => CounterCubit(0),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MyHomePage(title: 'BlocHook Example'),
      ),
    );
  }
}

class MyHomePage extends HookWidget {
  const MyHomePage({required this.title, Key? key}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    final valueNotifier = useValueNotifier<int>(0);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            HookBuilder(
              builder: (ctx) {
                final value = useListenable(valueNotifier).value;
                final counter = useBloc<CounterCubit, int>(
                  onEmitted: (_, prev, curr) => curr % 3 == 0,
                );

                return Column(
                  children: [
                    Text(
                      '$counter',
                      style: Theme.of(context).textTheme.headlineMedium,
                      key: const Key('counter_text'),
                    ),
                    Text(
                      '$value',
                      style: Theme.of(context).textTheme.headlineMedium,
                      key: const Key('value_text'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<CounterCubit>().increment();
          valueNotifier.value++;
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

void main() {
  testWidgets(
      'useBloc does not provide the currente state, but also the latest',
      (tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    final counterTextFinder = find.byKey(const Key('counter_text'));
    final valueTextFinder = find.byKey(const Key('value_text'));

    // Verify that our counter starts at 0.
    expect(counterTextFinder, findsOneWidget);
    expect(valueTextFinder, findsOneWidget);

    expect(tester.widget<Text>(counterTextFinder).data, '0');
    expect(tester.widget<Text>(valueTextFinder).data, '0');

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(tester.widget<Text>(counterTextFinder).data, '0');
    expect(tester.widget<Text>(valueTextFinder).data, '1');

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(tester.widget<Text>(counterTextFinder).data, '0');
    expect(tester.widget<Text>(valueTextFinder).data, '2');

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(tester.widget<Text>(counterTextFinder).data, '3');
    expect(tester.widget<Text>(valueTextFinder).data, '3');

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(tester.widget<Text>(counterTextFinder).data, '3');
    expect(tester.widget<Text>(valueTextFinder).data, '4');
  });
}

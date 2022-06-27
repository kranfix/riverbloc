// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverbloc/riverbloc.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class CounterCubit extends Cubit<int> {
  CounterCubit(super.state);

  void increment() => emit(state + 1);
}

final counterProvider =
    BlocProvider<CounterCubit, int>((ref) => CounterCubit(0));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuilds the widget if the cubit/bloc changes.
    // But does not rebuild if the state changes with the same cubit/bloc
    final counterCubit = ref.watch(counterProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'initial counterCubit.state: ${counterCubit.state}',
            ),
            Consumer(
              builder: (context, ref, __) {
                // Rebuilds on every emitted state
                final _counter = ref.watch(counterProvider);
                return Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headline4,
                );
              },
            ),
            Consumer(
              builder: (context, ref, __) {
                final _counter = ref.watch(
                  counterProvider
                      .when((prev, curr) => (curr + prev) % 5 == 0)
                      .select((state) => 2 * state),
                );
                return Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headline4,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(counterProvider.notifier).increment(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

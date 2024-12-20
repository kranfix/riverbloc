// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart';

void main() {
  runApp(const MyApp());
}

class CounterCubit extends Cubit<int> {
  CounterCubit(super.state);

  void increment() => emit(state + 1);

  void decrement() => emit(state - 1);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const MyHomePage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    debugPrint('MyHomePage');
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            HookBuilder(
              builder: (ctx) {
                debugPrint('HookBuilder');
                final counter = useBloc<CounterCubit, int>(
                  onEmitted: (_, prev, curr) {
                    debugPrint('listener: $prev $curr');
                    return curr % 3 == 0; // allows rebuild
                  },
                );
                return Text(
                  '$counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<CounterCubit>().increment(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

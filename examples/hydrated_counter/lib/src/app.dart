import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:riverbloc/riverbloc.dart';

class CounterCubit extends HydratedCubit<int> {
  CounterCubit(String id)
      : _id = id,
        super(0);

  final String _id;

  void increase() => emit(state + 1);
  void decrease() => emit(state - 1);

  @override
  String get id => _id;

  @override
  int fromJson(Map<String, dynamic> json) {
    return json['value'] as int;
  }

  @override
  Map<String, dynamic> toJson(int state) {
    return {'value': state};
  }
}

final counterProvider = BlocProvider<CounterCubit, int>(
  (_) => CounterCubit('home'),
);

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        counterProvider.overrideWith((ref) => CounterCubit('sub')),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: SizedBox(
          width: double.maxFinite,
          child: Consumer(
            builder: (_, ref, __) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(ref.watch(counterProvider).toString()),
                Wrap(
                  spacing: 12,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(counterProvider.bloc).increase(),
                      child: const Text('+1'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(counterProvider.bloc).decrease(),
                      child: const Text('-1'),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<dynamic>(builder: (_) => const SubPage()),
                  ),
                  child: const Text('Move to next page'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubPage extends StatelessWidget {
  const SubPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        counterProvider.overrideWith((ref) => CounterCubit('sub')),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Sub')),
        body: SizedBox(
          width: double.maxFinite,
          child: Consumer(
            builder: (_, ref, __) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(ref.watch(counterProvider).toString()),
                Wrap(
                  spacing: 12,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(counterProvider.bloc).increase(),
                      child: const Text('+1'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(counterProvider.bloc).decrease(),
                      child: const Text('-1'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

![Coverage](https://raw.githubusercontent.com/kranfix/riverbloc/master/packages/riverbloc/coverage_badge.svg?sanitize=true)

![Banner](https://raw.githubusercontent.com/kranfix/riverbloc/master/resources/riverbloc_banner.png)

An implementation of `BlocProvider` based on #[riverpod](https://pub.dev/packages/riverpod) providers.
The goal of this package is to make easy the migration from `flutter_bloc` to
`flutter_riverpod`.

If you are interested in `hooks` with `bloc`, see also
[flutter_hooks_bloc](https://pub.dev/packages/flutter_hooks_bloc)

## Usage

It's similar to `StateNotiferProvider` but with `Bloc` instead of `StateNotifier`.

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit(int state) : super(state);

  void increment() => emit(state + 1);
}

final counterProvider = BlocProvider<CounterCubit, int>(
  (ref) => CounterCubit(0),
);

class MyHomePage extends ConsumerWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuilds the widget if the cubit/bloc changes.
    // But does not rebuild if the state changes with the same cubit/bloc
    final counterCubit = ref.watch(counterProvider.bloc);
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
            Consumer(builder: (context, watch, __) {
              // Rebuilds in every emitted state
              final _counter = ref.watch(counterProvider);
              return Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              );
            }),
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
        onPressed: () => ref.read(counterProvider.bloc).increment(),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
```

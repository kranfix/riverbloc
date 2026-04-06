# flutter_hooks_bloc

![Coverage](https://raw.githubusercontent.com/kranfix/riverbloc/master/packages/flutter_hooks_bloc/coverage_badge.svg?sanitize=true)

A `flutter_bloc` reimplementation based on `flutter_hooks` for
`BlocBuilder`, `BlocListener`, `BlocConsumer` and `MultiBlocListener`.

## Usage as flutter_bloc

**MultiBlocListener, BlocBuilder, BlocListener and BlocConsumer**

They work exactly the same as the original. See the `flutter_bloc`
[documentation](https://bloclibrary.dev/#/flutterbloccoreconcepts).

## useBloc

The `useBloc` hook allows listening to state changes and optionally
rebuilding the widget.

```dart
// BlocHookListener<S> = bool Function(BuildContext context, S previous, S current)

S useBloc<B extends StateStreamable<S>, S>({
  /// Bloc or cubit to subscribe to. If null, it is inferred from
  /// the current BuildContext.
  B? bloc,

  /// Called on every state emission. Return true to trigger a rebuild,
  /// false to behave like a listener only.
  BlocHookListener<S>? onEmitted,
});
```

It can be used inside a `HookBuilder`:

```dart
HookBuilder(
  builder: (context) {
    final counter = useBloc<CounterCubit, int>(
      onEmitted: (context, previous, current) {
        print('listener: $previous -> $current');
        return true; // rebuild the widget
      },
    );
    return Text(
      '$counter',
      style: Theme.of(context).textTheme.headlineMedium,
    );
  },
);
```

Or inside a widget that extends `HookWidget` directly:

```dart
class CounterText extends HookWidget {
  const CounterText({super.key});

  @override
  Widget build(BuildContext context) {
    final count = useBloc<CounterCubit, int>();
    return Text('$count');
  }
}
```

## Alternative to MultiBlocBuilder

`flutter_bloc` has no `MultiBlocBuilder` because combining multiple
bloc states in a type-safe way is hard. `useBloc` solves this naturally:

```dart
class MyMultiBlocBuilder extends HookWidget {
  const MyMultiBlocBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilds when CubitA emits
    final stateA = useBloc<CubitA, int>(
      onEmitted: (context, previous, current) => true,
    );

    // Rebuilds when BlocB emits, and also calls a listener
    final stateB = useBloc<BlocB, String>(
      onEmitted: (context, previous, current) {
        if (current != previous) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(current)),
          );
        }
        return true;
      },
    );

    // Always rebuilds when CubitC emits
    final stateC = useBloc<CubitC, double>();

    return Column(
      children: [
        Text('$stateA'),
        Text('$stateB'),
        Text('$stateC'),
      ],
    );
  }
}
```

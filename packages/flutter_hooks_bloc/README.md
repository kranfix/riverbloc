# flutter_hooks_bloc

![Coverage](https://raw.githubusercontent.com/kranfix/riverbloc/master/packages/flutter_hooks_bloc/coverage_badge.svg?sanitize=true)

A flutter_bloc reimplementation based on flutter_hooks for
`BlocBuilder`, `BlocListener`, `BlocConsumer` and `MultiBlocListener`.

## Usage

### MultiBlocListener, BlocBuilder, BlocListener and BlocConsumer

They work exactly the same as the original. See the `flutter_bloc`
[documentation](https://bloclibrary.dev/#/flutterbloccoreconcepts).

### useBloc

The `useBloc` function allow

```dart
C useBloc<C extends Cubit<S>, S>({
  /// cubit to subscribe. if it is null, it will be infered
  C cubit,

  /// If `listener` callback is not null, every time the state changes, it will
  /// be executed and the contect, the previus and current state will be passed
  /// as parameters
  BlocHookListener<S> listener,

  /// If `buildWhen` callback is not null, will return a `bool` that
  /// indicates wheter the widget will rebuild on state changes.
  BlocBuilderCondition<S> buildWhen,

  /// If `allowRebuild`, the widget will rebuild if `buildWhen` is null or
  /// if its evaluation result is `true`.
  bool allowRebuild = false, //
});
```

It can be used into a HookBuilder:

```dart
HookBuilder(builder: (ctx) {
  print('HookBuilder');
  final counter = useBloc<CounterCubit, int>(
    listener: (_, prev, curr) => print('listener: $prev $curr'),
    allowRebuild: true,
  ).state;
  return Text(
    '$counter',
    style: Theme.of(context).textTheme.headline4,
  );
});
```

And also into a widget that extends a HookWidget:

```dart
class BlocBuilder<C extends Cubit<S>, S> extends HookWidget
    with CubitComposer<C>, BlocBuilderInterface<C, S> {
  const BlocBuilder({
    Key key,
    this.cubit,
    @required this.builder,
    this.buildWhen,
  })  : assert(builder != null),
        super(key: key);

  @override
  final C cubit;

  @override
  final BlocWidgetBuilder<S> builder;

  @override
  final BlocBuilderCondition<S> buildWhen;

  @override
  Widget build(BuildContext context) {
    final _cubit =
        useBloc<C, S>(cubit: cubit, buildWhen: buildWhen, allowRebuild: true);
    return builder(context, _cubit.state);
  }
}
```

### BlocListenable

In `flutter_bloc`, `MultiBlocListener` listeners are `BlocListener`s,
but it is unnecessarily a `Widget` and has an overload of functionalities.
An alternative could be `BlocListenable`, that has the same API than
`BlocListener`, but it has a light implementation and can be used indifferently.

```dart
MultiBlocListener(
  listeners: [
    BlocListenable<CubitA, StateA>(
      cubit: cubitA,
      lisenWhen: (StateA previousState, StateA state){
        // return `true` for listen
      }
      listener: (BuildContext context, StateA state){
        // your implementation
      }
    ),
    BlocListenable<CubitB, StateB>(
      cubit: cubitA,
      lisenWhen: (StateB previousState, StateB state){
        // return `true` for listen
      }
      listener: (BuildContext context, StateB state){
        // your implementation
      }
    ),
  ],
  child: const YourCustomWidet(),
)
```

# flutter_hooks_bloc

![Coverage](https://raw.githubusercontent.com/kranfix/riverbloc/master/packages/flutter_hooks_bloc/coverage_badge.svg?sanitize=true)

A flutter_bloc reimplementation based on flutter_hooks for
`BlocBuilder`, `BlocListener`, `BlocConsumer` and `MultiBlocListener`.

## Usage as flutter_bloc

**MultiBlocListener, BlocBuilder, BlocListener and BlocConsumer**

They work exactly the same as the original. See the `flutter_bloc`
[documentation](https://bloclibrary.dev/#/flutterbloccoreconcepts).

**useBloc**

The `useBloc` hook function allows to listen state changes and rebuild
the widget if necessary.

```dart
S useBloc<B extends BlocBase<S>, S>({
  /// bloc or cubit to subscribe. if it is null, it will be infered
  B? bloc,

  /// If `onEmitted` is not provided or its invocation returns `true`,
  /// the widget will rebuild.
  BlocHookListener<S>? onEmitted,
});
```

It can be used into a HookBuilder:

```dart
HookBuilder(builder: (ctx) {
  print('HookBuilder');
  final counter = useBloc<CounterCubit, int>(
    onEmitted: (_, prev, curr) {
      print('listener: $prev $curr');
      return true;
    }
  );
  return Text(
    '$counter',
    style: Theme.of(context).textTheme.headline4,
  );
});
```

And also into a widget that extends a HookWidget:

```dart
class BlocBuilder<B extends BlocBase<S>, S> extends BlocWidget<B, S> {
  const BlocBuilder({
    Key? key,
    this.bloc,
    @required this.builder,
    this.buildWhen,
  })  : assert(builder != null),
        super(key: key);

  @override
  final B? bloc;

  @override
  final BlocWidgetBuilder<S> builder;

  @override
  final BlocBuilderCondition<S>? buildWhen;

  @override
  Widget build(BuildContext context) {
    final state = useBloc<B, S>(
      bloc: cubit,
      onEmitted: (context, previous, state) {
        return buildWhen?.call(previous, state) ?? true;
      }
    );
    return builder(context, state);
  }
}
```

And a `BlocWidget<B, S>` y defined as following:

```dart
abstract class BlocWidget<B extends BlocBase<S>, S extends Object>
    extends HookWidget {}
```

# Alternative to MultiBlocBuilder

The issue with `MultiBlocBuilder` is that it could be either type safety or
have an unliminit number of inputs (expending to much code).
But with `useBloc` comes to the rescue.

```dart
class MyMultiBlocBuilder extends HookWidget {
  const MyMultiBlocBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    // onEmitted is called every time that the state is emitter in a cubit/bloc
    final stateA = useBloc<CubitA, int>(onEmitted: (context, previousState, state){
      // with true, the widget rebuild, otherwise, it behave like a BlocListener
      return buildWhenA?.call(previousState, state) ?? true;
    });

    final stateB = useBloc<BlocB, String>(onEmitted: (context, previousState, state){
      // If you also want to have a BlocListener behavior, you can add some code here
      if(listenWhen?.call(previousState, state) ?? true){
        listener(context, state);
      }
      return buildWhenB?.call(previousState, state) ?? true;
    });

    // always rebuild when cubit emits a new state
    final stateC = useBloc<CubitC, double>();

    return Column(
      children: [
        Text('${stateAA}'),
        Text('${statecB}'),
        Text('${stateC}'),
      ],
    );
  }
}
```

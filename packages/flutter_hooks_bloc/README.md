# flutter_hooks_bloc

![Coverage](https://raw.githubusercontent.com/kranfix/riverbloc/master/packages/flutter_hooks_bloc/coverage_badge.svg?sanitize=true)

A flutter_bloc reimplementation based on flutter_hooks for
`BlocBuilder`, `BlocListener`, `BlocConsumer` and `MultiBlocListener`.

And also work with `riverbloc` with the `BlocBuilder.river()`,
`BlocListener.river()` and `BlocConsumer.river()` constructors.

## Usage as flutter_bloc

**MultiBlocListener, BlocBuilder, BlocListener and BlocConsumer**

They work exactly the same as the original. See the `flutter_bloc`
[documentation](https://bloclibrary.dev/#/flutterbloccoreconcepts).

**useBloc**

The `useBloc` hook function allows to listen state changes and rebuild
the widget if necessary.

```dart
C useBloc<C extends Cubit<S>, S>({
  /// cubit to subscribe. if it is null, it will be infered
  C cubit,

  /// If `onEmitted` is not provided or its invocation returns `true`,
  /// the widget will rebuild.
  BlocHookListener<S> onEmitted,
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
    final _cubit = useBloc<C, S>(
      cubit: cubit,
      onEmitted: (context, previous, state) {
        return buildWhen?.call(previous, state) ?? true;
      }
    );
    return builder(context, _cubit.state);
  }
}
```

# Alternative to MultiBlocBuilder

The issue with `MultiBlocBuilder` is that it could be either type safety or
have an unliminit number of inputs (expending to much code).
But with `useBloc` comes to the rescue.

```dart
class MyMultiBlocBuilder extends HookWidget {
  const MyMultiBlocBuilder({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    // onEmitted is called every time that the state is emitter in a cubit/bloc
    final cubitA = useBloc<CubitA, int>(onEmitted: (context, previousState, state){
      // with true, the widget rebuild, otherwise, it behave like a BlocListener
      return buildWhenA?.call(previousState, state) ?? true;
    });

    final blocB = useBloc<BlocB, String>(onEmitted: (context, previousState, state){
      // If you also want to have a BlocListener behavior, you can add some code here
      if(listenWhen?.call(previousState, state) ?? true){
        listener(context, state);
      }
      return buildWhenB?.call(previousState, state) ?? true;
    });

    // always rebuild when cubit emits a new state
    final cubitC = useBloc<CubitC, double>();

    return Column(
      children: [
        Text('${cubitA.state}'),
        Text('${blocB.state}'),
        Text('${cubitC.state}'),
      ],
    );
  }
}
```

## Usage with riverbloc

The `useRiverBloc` hook function allows to listen state changes and rebuild
the widget if necessary.

```dart
C useRiverBloc<C extends Cubit<S>, S>(
  /// subscribe to a riverbloc [BlocProvider]`
  BlocProvider<C> provider, {

  /// If `onEmitted` is not provided or its invocation returns `true`,
  /// the widget will rebuild.
  BlocHookListener<S> onEmitted,
});
```

```dart
import 'package:flutter_hooks_bloc/flutter_riverbloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() :  super(0);

  void increment() => emit(state + 1);
}

final counterProvider = BlocProvider((ref) => CounterCubit());

ProviderScope(
  child: HookBuilder(
    builder: (context){
      final _cubit = useRiverBloc<C, S>(
        counterProvider,
        onEmitted: (context, previous, state) {
          return state % 3 == 0;
        }
      );
      return Text('State: ${_cubit.state}');
    },
  )
);
```

import 'package:bloc/bloc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:meta/meta.dart';

// ignore: implementation_imports
import 'package:riverpod/src/framework.dart';

part 'bloc_provider_state.dart';
part 'bloc_notifier_provider.dart';
part 'auto_dispose.dart';

// ignore: subtype_of_sealed_class
/// {@template bloc_provider}
/// # BlocProvider
///
/// Similar to [StateNotifierProvider] but for [BlocBase] ([Bloc] and [Cubit])
///
/// ```
/// class CounterCubit extends Cubit<int> {
///   CounterCubit(int state) : super(state);
///
///   void increment() => emit(state + 1);
/// }
///
/// final counterCubitProvider =
///     BlocProvider<CounterCubit, int>((ref) => CounterCubit(0));
///
/// class MyHomePage extends ConsumerWidget {
///   const MyHomePage({Key? key, required this.title}) : super(key: key);
///
///   final String title;
///
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     // Rebuilds the widget if the cubit/bloc changes.
///     // But does not rebuild if the state changes with the same cubit/bloc
///     final counterCubit = ref.watch(counterCubitProvider.notifier);
///     return Scaffold(
///       appBar: AppBar(
///         title: Text(title),
///       ),
///       body: Center(
///         child: Column(
///           mainAxisAlignment: MainAxisAlignment.center,
///           children: <Widget>[
///             Text(
///               'initial counterCubit.state: ${counterCubit.state}',
///             ),
///             Consumer(builder: (context, ref, __) {
///               // Rebuilds on every emitted state
///               final _counter = ref.watch(counterCubitProvider);
///               return Text(
///                 '$_counter',
///                 style: Theme.of(context).textTheme.headline4,
///               );
///             }),
///           ],
///         ),
///       ),
///       floatingActionButton: FloatingActionButton(
///         onPressed: () => ref.read(counterCubitProvider.notifier).increment(),
///         tooltip: 'Increment',
///         child: Icon(Icons.add),
///       ),
///     );
///   }
/// }
/// ```
/// {@endtemplate}
///
/// {@template bloc_provider_notifier}
/// ## `BlocProvider.notifier`
/// `BlocBase` object getter, it can be either `Bloc`
/// or `Cubit`.
///
/// Usage:
///
/// ```dart
/// Consumer(builder: (context, ref, __) {
///   return ElevatedButton(
///     style: style,
///     onPressed: () {
///       ref.read(counterBlocProvider.notifier).increment();
///     },
///     child: const Text('Press me'),
///   );
/// }),
/// ```
/// {@endtemplate}
///
/// {@template bloc_provider_bloc}
/// ## `BlocProvider.bloc`
/// `BlocBase` object getter, it can be either `Bloc`
/// or `Cubit`.
///
/// Usage:
///
/// ```dart
/// Consumer(builder: (context, ref, __) {
///   return ElevatedButton(
///     style: style,
///     onPressed: () {
///       ref.read(counterBlocProvider.bloc).increment();
///     },
///     child: const Text('Press me'),
///   );
/// }),
/// ```
/// {@endtemplate}
///
/// {@template bloc_provider_stream}
/// ## `BlocProvider.stream`
/// Listen to the `Bloc.stream` or `Cubit.stream`
/// {@endtemplate}
///
/// {@template bloc_provider_override_with_provider}
/// ## `BlocProvider.overrideWithProvider`
///
/// With pure dart:
///
/// ```dart
/// final counterProvider = BlocProvider((ref) => CounterCubit(0));
/// final counterCubit = CounterCubit(3);
/// final counterProvider2 = BlocProvider((ref) => counterCubit);
/// final container = ProviderContainer(
///   overrides: [
///     counterProvider.overrideWithProvider(counterProvider2),
///   ],
/// );
///
/// // reads `counterProvider2` and returns `counterCubit`
/// container.read(counterProvider.notifier);
///
/// // reads the `counterProvider2` `state` and returns `3`
/// container.read(counterProvider);
/// ```
///
/// With Flutter:
///
/// ```dart
/// final counterProvider = BlocProvider((ref) => CounterCubit(0));
/// final counterCubit = CounterCubit(3);
/// final counterProvider2 = BlocProvider((ref) => counterCubit);
///
/// ProviderScope(
///   overrides: [
///     counterProvider.overrideWithProvider(counterProvider2),
///   ],
///   child: Consumer(
///     builder: (context, ref, _) {
///       final countCubit = ref.watch(counterProvider.notifier);
///       return Container();
///     },
///   ),
/// );
/// ```
/// {@endtemplate}
///
/// {@template bloc_provider_override_with_value}
/// ## `BlocProvider.overrideWithValue`
///
/// With pure dart:
///
/// ```dart
/// final counterProvider = BlocProvider((ref) => CounterCubit(0));
/// final counterCubit = CounterCubit(3);
/// final container = ProviderContainer(
///   overrides: [
///     counterProvider.overrideWithValue(counterCubit),
///   ],
/// );
///
/// // reads `counterProvider` and returns `counterCubit`
/// container.read(counterProvider.notifier);
///
/// // reads the `counterProvider.state` and returns `3`
/// container.read(counterProvider);
/// ```
///
/// With Flutter:
///
/// ```dart
/// final counterProvider = BlocProvider((ref) => CounterCubit(0));
/// final counterCubit = CounterCubit(3);
///
/// ProviderScope(
///   overrides: [
///     counterProvider.overrideWithValue(counterCubit),
///   ],
///   child: Consumer(
///     builder: (context, ref, _) {
///       final countCubit = ref.watch(counterProvider.notifier);
///       return Container();
///     },
///   ),
/// );
/// ```
/// {@endtemplate}
///
/// {@template bloc_provider_auto_dispose}
/// ## Auto Dispose
/// Marks the provider as automatically disposed when no-longer listened.
///
/// ```dart
/// final counterProvider1 = BlocProvider.autoDispose((ref) => CounterCubit(0));
///
/// final counterProvider2 - AutoDisposeBlocProvider((ref) => CounterCubit(0));
/// ```
/// The `maintainState` property is a boolean (`false` by default) that allows
/// the provider to tell Riverpod if the state of the provider should be
/// preserved even if no-longer listened.
///
/// ```dart
/// final myProvider = BlocProvider.autoDispose((ref) {
///   final asyncValue = ref.watch(myFutureProvider);
///   final firstState = asyncValue.data!.value;
///   ref.maintainState = true;
///   return CounterBloc(firstState);
/// });
/// ```
///
/// This way, if the `asyncValue` has no data, the provider won't create
/// correctly the state and if the UI leaves the screen and re-enters it,
/// the `asyncValue` will be readed again to retry creating the state.
/// {@endtemplate}
class BlocProvider<B extends BlocBase<S>, S> extends AlwaysAliveProviderBase<S>
    with _BlocProviderMixin<B, S> {
  /// {@macro bloc_provider}
  BlocProvider(this._create, {String? name}) : super(name);

  /// {@macro bloc_provider_auto_dispose}
  static const autoDispose = AutoDisposeBlocProviderBuilder();

  final Create<B, ProviderRefBase> _create;

  /// {@macro bloc_provider_notifier}
  @override
  late final AlwaysAliveProviderBase<B> notifier =
      _NotifierProvider(_create, name: name);

  /// {@macro bloc_provider_bloc}
  AlwaysAliveProviderBase<B> get bloc => notifier;

  /// {@macro bloc_provider_stream}
  late final AlwaysAliveProviderBase<AsyncValue<S>> stream = StreamProvider<S>(
    (ref) => ref.watch(notifier).stream,
    name: name == null ? null : '$name.stream',
  );

  @override
  bool recreateShouldNotify(S previousState, S newState) {
    return newState != previousState;
  }

  /// Overrides the behavior of a provider with a another provider.
  ///
  /// {@macro riverpod.overideWith}
  Override overrideWithProvider(
    BlocProvider<B, S> provider,
  ) {
    return ProviderOverride((setup) {
      setup(origin: notifier, override: provider.notifier);
    });
  }

  @override
  S create(ProviderElementBase<S> ref) {
    final notifier = ref.watch(this.notifier);

    ref.state = notifier.state;

    void listener(S newState) {
      ref.state = newState;
    }

    final removeListener = notifier.stream.listen(listener);
    ref.onDispose(removeListener.cancel);

    return ref.state;
  }

  @override
  ProviderElementBase<S> createElement() => ProviderElement(this);
}

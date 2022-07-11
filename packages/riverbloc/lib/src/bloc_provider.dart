part of 'framework.dart';

// ignore: subtype_of_sealed_class
/// {@template bloc_provider}
/// # BlocProvider
///
/// Similar to [StateNotifierProvider] but for [BlocBase] ([Bloc] and [Cubit])
///
/// ```dart
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
///         onPressed: () {
///           ref.read(counterCubitProvider.notifier).increment();
///         }
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
/// {@template bloc_provider_scoped}
/// Creates a [BlocProvider] that needs to be overridden
///
/// With pure dart:
///
/// ```dart
/// final blocProvider = BlocProvider<CounterBloc, int>.scoped('blocProvider');
///
/// final container = ProviderContainer(
///   overrides: [
///     blocProvider
///         .overrideWithProvider(BlocProvider((ref) => CounterBloc(0))),
///   ],
/// );
///
/// final counter = container.read(blocProvider); // counter = 0
/// ```
///
/// With Flutter:
///
/// ```dart
/// final blocProvider = BlocProvider<CounterBloc, int>.scoped('blocProvider');
///
/// class MyApp extends StatelessWidget {
///   const MyApp({Key? key}) : super(key: key);
///
///   @override
///   Widget build(BuildContext context) {
///     return ProviderScope(
///       overrides: [
///         blocProvider
///             .overrideWithProvider(BlocProvider((ref) => CounterBloc(0))),
///       ],
///       child: Consumer(
///         builder: (context, ref, child) {
///           final counter = ref.watch(blocProvider);  // counter = 0
///           return Text('$counter');
///         }
///       )
///     );
///   }
/// }
/// ```
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
///
/// {@template bloc_provider_when}
/// ## `BlocProvider.when`
///
/// For conditional rebuilds, you can use the `when` property.
///
/// ```dart
/// ref.watch(
///   counterBlocProvider
///     .when((previous, current) => current > previous)),
/// );
///
/// ref.watch(
///   blocProvider
///     .when((prev, curr) => true)
///     .select((state) => state.field),
///   (field) { /* do something */ }
/// );
/// ```
///
/// or for conditional listening:
///
/// ```dart
/// ref.listen(
///   counterBlocProvider
///     .when((previous, current) => current > previous)),
/// );
///
/// ref.listen(
///   blocProvider
///     .when((prev, curr) => true)
///     .select((state) => state.field),
///   (field) { /* do something*/ }
/// );
/// ```
/// {@endtemplate}
class BlocProvider<B extends BlocBase<S>, S> extends AlwaysAliveProviderBase<S>
    with
        BlocProviderOverrideMixin<B, S>,
        OverrideWithProviderMixin<B, BlocProvider<B, S>> {
  /// {@macro bloc_provider}
  BlocProvider(
    Create<B, BlocProviderRef<B>> create, {
    super.name,
    List<ProviderOrFamily>? dependencies,
    super.from,
    super.argument,
  }) : bloc = _NotifierProvider(
          create,
          name: name,
          dependencies: dependencies,
          from: from,
          argument: argument,
        );

  /// {@macro bloc_provider_scoped}
  BlocProvider.scoped(String name)
      : this(
          (ref) => throw UnimplementedProviderError<BlocProvider<B, S>>(name),
          name: name,
        );

  /// {@macro bloc_provider_auto_dispose}
  static const autoDispose = AutoDisposeBlocProviderBuilder();

  /// {@macro riverpod.family}
  static const family = BlocProviderFamilyBuilder();

  /// {@macro bloc_provider_notifier}
  AlwaysAliveProviderBase<B> get notifier => bloc;

  /// {@macro bloc_provider_bloc}
  @override
  final AlwaysAliveProviderBase<B> bloc;

  @override
  S create(ProviderElementBase<S> ref) {
    final bloc = ref.watch(this.bloc);

    void listener(S newState) => ref.setState(newState);
    final sub = bloc.stream.listen(listener);
    ref.onDispose(sub.cancel);

    return bloc.state;
  }

  @override
  ProviderElementBase<S> createElement() => ProviderElement(this);
}

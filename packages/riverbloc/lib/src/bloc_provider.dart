part of '../riverbloc.dart';

/// {@template bloc_provider}
/// # BlocProvider
///
/// Similar to [StateNotifierProvider] but for bloc
///
/// ```
/// class CounterCubit extends Cubit<int> {
///   CounterCubit(int state) : super(state);
///
///   void increment() => emit(state + 1);
/// }
///
/// final counterProvider =
///     BlocProvider<CounterCubit, int>((ref) => CounterCubit(0));
///
/// class MyHomePage extends ConsumerWidget {
///   const MyHomePage({Key? key, required this.title}) : super(key: key);
///
///   final String title;
///
///   @override
///   Widget build(BuildContext context, ScopedReader watch) {
///     // Rebuilds the widget if the cubit/bloc changes.
///     // But does not rebuild if the state changes with the same cubit/bloc
///     final counterCubit = watch(counterProvider.notifier);
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
///             Consumer(builder: (context, watch, __) {
///               // Rebuilds on every emitted state
///               final _counter = watch(counterProvider);
///               return Text(
///                 '$_counter',
///                 style: Theme.of(context).textTheme.headline4,
///               );
///             }),
///           ],
///         ),
///       ),
///       floatingActionButton: FloatingActionButton(
///         onPressed: () => context.read(counterProvider.notifier).increment(),
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
/// Listen if the `Bloc` or `Cubit` when is recreated
///
/// Usasge:
///
/// ```dart
/// Consumer(builder: (context, watch, __) {
///   // Rebuilds if the cubit or bloc is recreated
///   final _cubit = watch(counterProvider.notifier);
///   return Text(
///     '${_cubit.state}',
///     style: Theme.of(context).textTheme.headline4,
///   );
/// }),
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
///     builder: (context, watch, _) {
///       final countCubit = watch(counterProvider.notifier);
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
///     builder: (context, watch, _) {
///       final countCubit = watch(counterProvider.notifier);
///       return Container();
///     },
///   ),
/// );
/// ```
/// {@endtemplate}
@sealed
class BlocProvider<B extends BlocBase<S>, S>
    extends AlwaysAliveProviderBase<B, S> {
  /// {@macro bloc_provider}
  BlocProvider(
    Create<B, ProviderReference> create, {
    String? name,
  })  : _create = create,
        super(name);

  final Create<B, ProviderReference> _create;

  /// {@macro bloc_provider_notifier}
  late final AlwaysAliveProviderBase<B, B> notifier =
      _NotifierProvider(_create, name: name);

  /// {@macro bloc_provider_override_with_provider}
  ProviderOverride overrideWithProvider(covariant BlocProvider<B, S> provider) {
    return ProviderOverride(provider.notifier, notifier);
  }

  /// {@macro bloc_provider_override_with_value}
  ProviderOverride overrideWithValue(B value) {
    return ProviderOverride(
      ValueProvider<Object?, B>((ref) => value, value),
      notifier,
    );
  }

  @override
  ProviderStateBase<B, S> createState() => _BlocProviderState<B, S>();

  @override
  B create(ProviderReference ref) => ref.watch(notifier);
}

class _BlocProviderState<B extends BlocBase<S>, S>
    extends ProviderStateBase<B, S> {
  StreamSubscription<S>? _subscription;

  @override
  void valueChanged({B? previous}) {
    if (createdValue != previous) {
      if (_subscription != null) {
        _unsubscribe();
      }
      _subscribe();
    }
  }

  void _subscribe() {
    exposedValue = createdValue.state;
    _subscription = createdValue.stream.listen(_listener);
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _listener(S value) {
    exposedValue = value;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }
}

// ignore: subtype_of_sealed_class
class _NotifierProvider<B extends BlocBase<Object?>> extends Provider<B> {
  _NotifierProvider(
    Create<B, ProviderReference> create, {
    required String? name,
  }) : super(
          (ref) {
            final notifier = create(ref);
            ref.onDispose(notifier.close);
            return notifier;
          },
          name: name == null ? null : '$name.notifier',
        );
}

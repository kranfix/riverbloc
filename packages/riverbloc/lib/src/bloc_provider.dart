import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:meta/meta.dart';

// ignore: implementation_imports
import 'package:riverpod/src/framework.dart';

/// {@template bloc_provider}
/// Similar to Provider but for bloc
///
/// ```
/// class CounterCubit extends Cubit<int> {
///   CounterCubit(int state) : super(state);
///
///   void increment() => emit(state + 1);
/// }
///
/// final counterProvider = BlocProvider((ref) => CounterCubit(0));
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
///     final counterCubit = watch(counterProvider);
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
///               final _counter = watch(counterProvider.state);
///               return Text(
///                 '$_counter',
///                 style: Theme.of(context).textTheme.headline4,
///               );
///             }),
///           ],
///         ),
///       ),
///       floatingActionButton: FloatingActionButton(
///         onPressed: () => context.read(counterProvider).increment(),
///         tooltip: 'Increment',
///         child: Icon(Icons.add),
///       ),
///     );
///   }
/// }
/// ```
/// {@endtemplate}
@sealed
class BlocProvider<B extends BlocBase<Object>>
    extends AlwaysAliveProviderBase<B, B> {
  /// {@macro bloc_provider}
  BlocProvider(
    Create<B, ProviderReference> create, {
    String? name,
  }) : super(create, name);

  BlocStateProvider<Object?>? _state;

  ///
  /// With pure dart:
  ///
  /// ```dart
  /// final counterProvider = BlocProvider((ref) => CounterCubit(0));
  /// final counterCubit = CounterCubit(0);
  /// final counterProvider2 = BlocProvider((ref) => counterCubit);
  /// final container = ProviderContainer(
  ///   overrides: [
  ///     counterProvider.overrideWithProvider(counterProvider2),
  ///   ],
  /// );
  ///
  /// // reads `counterProvider2` and returns `counterCubit`
  /// container.read(counterProvider);
  /// ```
  ///
  /// With Flutter:
  ///
  /// ```dart
  /// final counterProvider = BlocProvider((ref) => CounterCubit(0));
  /// final counterCubit = CounterCubit(0);
  /// final counterProvider2 = BlocProvider((ref) => counterCubit);
  ///
  /// ProviderScope(
  ///   overrides: [
  ///     counterProvider.overrideWithProvider(counterProvider2),
  ///   ],
  ///   child: Consumer(
  ///     builder: (context, watch, _) {
  ///       final countCubit = watch(counterProvider);
  ///       return Container();
  ///     },
  ///   ),
  /// );
  /// ```
  @override
  ProviderOverride overrideWithProvider(covariant BlocProvider<B> provider) {
    return ProviderOverride(provider, this);
  }

  @override
  ProviderStateBase<B, B> createState() => _BlocProviderState<B, Object>();
}

class _BlocProviderState<B extends BlocBase<S>, S>
    extends ProviderStateBase<B, B> {
  @override
  void valueChanged({B? previous}) {
    if (createdValue != exposedValue) {
      exposedValue = createdValue;
    }
  }
}

/// Adds [state] to [BlocProvider].
///
/// Usasge:
///
/// ```dart
/// Consumer(builder: (context, watch, __) {
///   // Rebuilds in every emitted state
///   final _counter = watch(counterProvider.state);
///   return Text(
///     '$_counter',
///     style: Theme.of(context).textTheme.headline4,
///   );
/// }),
/// ```
extension BlocStateProviderX<S extends Object> on BlocProvider<BlocBase<S>> {
  /// Returns a provider for the `state` value.
  BlocStateProvider<S> get state {
    _state ??= BlocStateProvider<S>._(this);
    return _state as BlocStateProvider<S>;
  }
}

/// The [BlocStateProvider] watch a [Cubit] or [Bloc] and subscribe to its
/// `state` and rebuilds every time that it is emitted.
class BlocStateProvider<S extends Object>
    extends AlwaysAliveProviderBase<BlocBase<S>, S> {
  BlocStateProvider._(this._provider)
      : super(
          (ref) => ref.watch(_provider),
          _provider.name != null ? '${_provider.name}.state' : null,
        );

  final BlocProvider<BlocBase<S>> _provider;

  @override
  Override overrideWithValue(S value) {
    return ProviderOverride(
      ValueProvider<BlocBase<S>, S>((ref) => ref.watch(_provider), value),
      this,
    );
  }

  @override
  _BlocStateProviderState<S> createState() => _BlocStateProviderState();
}

class _BlocStateProviderState<S> extends ProviderStateBase<BlocBase<S>, S> {
  StreamSubscription<S>? _subscription;

  @override
  void valueChanged({BlocBase<S>? previous}) {
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

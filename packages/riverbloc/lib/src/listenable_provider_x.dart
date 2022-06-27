import 'package:riverpod/riverpod.dart';

/// Signature to decide `when` a [ProviderListenable] will rebuild.
///
/// See also:
/// - [ProviderListenable.select]
typedef ListenWhen<S> = bool Function(S previous, S current);

/// {@template riverbloc.ProviderListenableWhenable.when}
/// Provides a [when] method like `listenWhen` or `buildWhen` in the
/// common `BlocListener` or `BlocBuilder`
/// {@endtemplate}
extension ProviderListenableWhenable<S> on ProviderListenable<S> {
  /// {@macro riverbloc.ProviderListenableWhenable.when}
  ///
  /// ```dart
  ///
  /// class CounterCubit extends Cubit<int> {
  ///   CounterCubit(super.state);
  ///
  ///   void increment() => emit(state + 1);
  /// }
  ///
  /// final counterProvider =
  ///     BlocProvider<CounterCubit, int>((ref) => CounterCubit(0));
  ///
  /// Consumer(
  ///   builder: (context, ref, __) {
  ///     final _counter = ref.watch(
  ///       counterProvider
  ///           .when((prev, curr) => (curr + prev) % 5 == 0)
  ///           .select((state) => 2 * state),
  ///     );
  ///     return Text(
  ///       '$_counter',
  ///       style: Theme.of(context).textTheme.headline4,
  ///     );
  ///   },
  /// )
  /// ```
  ProviderListenable<S> when(ListenWhen<S> filter) {
    _Ref<S>? val;
    return select((curr) {
      val = val?.update(curr) ?? _Ref(curr, filter);
      return val!.aux;
    }).select((_) => val!.last);
  }
}

class _Ref<T> {
  const _Ref(this.last, this.when, {this.aux = false});

  final T last;
  final ListenWhen<T> when;
  final bool aux;

  _Ref<T> update(T curr) => _Ref(curr, when, aux: aux ^ when(last, curr));
}

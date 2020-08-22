import 'package:riverpod/riverpod.dart';
import 'package:bloc/bloc.dart';
import 'package:riverpod/src/framework.dart';

class BlocProvider<C extends Cubit<Object>>
    extends AlwaysAliveProviderBase<C, C> {
  BlocProvider(
    Create<C, ProviderReference> create, {
    String name,
  }) : super(create, name);

  /// {@macro riverpod.family}
  static const family = BlocProviderFamilyBuilder();

  /// {@macro riverpod.autoDispose}
  static const autoDispose = AutoDisposeBlocProviderBuilder();

  AlwaysAliveProviderBase<C, Object> _state;

  @override
  _BlocProviderState<C, C> createState() => _BlocProviderState();

  //@override
  //_BlocProviderState<C> createState() => _BlocProviderState();
}

/// Adds [state] to [BlocProvider.autoDispose].
//extension BlocStateProviderX<C extends Cubit<S>, S>
//    on StateNotifierProvider<C> {
//  /// {@macro riverpod.statenotifierprovider.state.provider}
//  BlocStateProvider<S> get state {
//    _state ??= BlocStateProvider<S>._(this);
//    return _state as StateNotifierStateProvider<Value>;
//  }
//}

class _BlocProviderState<C extends Cubit<S>, S>
    extends ProviderStateBase<C, S> {
  @override
  void valueChanged({C previous}) {
    // TODO: implement valueChanged
  }
}

/// {@template riverpod.streamprovider.family}
/// A class that allows building a [StreamProvider] from an external parameter.
/// {@endtemplate}
class BlocProviderFamily<C extends Cubit<Object>, A>
    extends Family<C, AsyncValue<T>, A, ProviderReference, BlocProvider<C>> {
  /// {@macro riverpod.streamprovider.family}
  BlocProviderFamily(
    C Function(ProviderReference ref, A a) create, {
    String name,
  }) : super(create, name);

  @override
  BlocProvider<C> create(
    A value,
    Cubit<C> Function(ProviderReference ref, A param) builder,
    String name,
  ) {
    return StreamProvider((ref) => builder(ref, value), name: name);
  }
}

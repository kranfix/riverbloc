import 'package:bloc/bloc.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart' hide BlocProvider;
import 'package:flutter_hooks_bloc/src/bloc_listener.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverbloc/riverbloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}

//class MyBlocListener<C extends Cubit<S>, S> extends BlocListenerBase<C, S> {
//  const MyBlocListener() : super(listener: null);
//
//  const MyBlocListener.river({
//    BlocProvider<C> provider,
//    BlocWidgetListener<S> listener,
//  }) : super.river(provider: provider, listener: listener);
//}

void main() {
  //group('BlocListenerBase', () {
  //  test('throws when super.listener is null', () {
  //    try {
  //      MyBlocListener();
  //    } catch (e) {
  //      expect(e, isAssertionError);
  //    }
  //  });
  //});

  group('BlocListenerBase.river', () {
    //test('throws when super.provider is null', () {
    //  try {
    //    MyBlocListener.river(
    //      provider: null,
    //      listener: null,
    //    );
    //  } catch (e) {
    //    expect(e, isAssertionError);
    //  }
    //});

    //test('throws when super.provider is null', () {
    //  final counterProvider = BlocProvider((ref) => CounterCubit());
    //  try {
    //    MyBlocListener.river(
    //      provider: counterProvider,
    //      listener: null,
    //    );
    //  } catch (e) {
    //    expect(e, isAssertionError);
    //  }
    //});
  });
}

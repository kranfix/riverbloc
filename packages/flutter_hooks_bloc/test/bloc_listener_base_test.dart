import 'package:bloc/bloc.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart' hide BlocProvider;
import 'package:flutter_hooks_bloc/src/bloc_listener.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverbloc/riverbloc.dart';

class MyBlocListener<C extends Cubit<S>, S> extends BlocListenerBase<C, S> {
  const MyBlocListener() : super(listener: null);
}

void main() {
  group('BlocListenerBase', () {
    test('throws when super.listener is null', () {
      try {
        MyBlocListener();
      } catch (e) {
        expect(e, isAssertionError);
      }
    });
  });
}

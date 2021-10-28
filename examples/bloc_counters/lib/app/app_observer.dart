import 'dart:developer';

import 'package:bloc/bloc.dart';

class MyBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);

    log('${bloc.runtimeType}: $event', name: 'onEvent');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log('${bloc.runtimeType}: $transition', name: 'onTrasition');
  }

  @override
  void onChange(BlocBase bloc, Change state) {
    if (bloc is Cubit) {
      super.onChange(bloc, state);
      log('${bloc.runtimeType}: $state', name: 'onChange');
    }
  }
}

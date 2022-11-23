import 'dart:developer';

import 'package:bloc/bloc.dart';

class MyBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);

    log('${bloc.runtimeType}: $event', name: 'onEvent');
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    log('${bloc.runtimeType}: $transition', name: 'onTrasition');
  }

  @override
  void onChange(
    BlocBase<dynamic> bloc,
    Change<dynamic> change,
  ) {
    if (bloc is Cubit) {
      super.onChange(bloc, change);
      log('${bloc.runtimeType}: $change', name: 'onChange');
    }
  }
}

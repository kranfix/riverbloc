import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_timer/ticker.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  static const int _duration = 5;

  StreamSubscription<int>? _tickerSubscription;

  TimerBloc({required Ticker ticker})
      : _ticker = ticker,
        super(TimerInitial(_duration)) {
    on<TimerStarted>(_mapTimerStartedToState);
    on<TimerPaused>(_mapTimerPausedToState);
    on<TimerResumed>(_mapTimerResumedToState);
    on<TimerReset>(_mapTimerResetToState);
    on<TimerTicked>(_mapTimerTickedToState);
  }

  @override
  void onTransition(Transition<TimerEvent, TimerState> transition) {
    print(transition);
    super.onTransition(transition);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  void _mapTimerStartedToState(TimerStarted start, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(start.duration));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: start.duration)
        .listen((duration) => add(TimerTicked(duration: duration)));
  }

  void _mapTimerPausedToState(TimerPaused pause, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();
      emit(TimerRunPause(state.duration));
    }
  }

  void _mapTimerResumedToState(TimerResumed resume, Emitter<TimerState> emit) {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      emit(TimerRunInProgress(state.duration));
    }
  }

  void _mapTimerResetToState(TimerReset reset, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(TimerInitial(_duration));
  }

  void _mapTimerTickedToState(TimerTicked tick, Emitter<TimerState> emit) {
    final event = tick.duration > 0
        ? TimerRunInProgress(tick.duration)
        : TimerRunComplete();
    emit(event);
  }
}

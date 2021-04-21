import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timer/bloc/timer_bloc.dart';
import 'package:riverbloc/riverbloc.dart';
import 'package:flutter_timer/ticker.dart';
//import 'package:wave/wave.dart';
//import 'package:wave/config.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

// ignore: top_level_function_literal_block
final timerProvider = BlocProvider<TimerBloc, TimerState>((ref) {
  return TimerBloc(ticker: Ticker());
});

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromRGBO(109, 234, 255, 1),
        accentColor: Color.fromRGBO(72, 74, 126, 1),
        brightness: Brightness.dark,
      ),
      title: 'Flutter Timer',
      home: Timer(),
    );
  }
}

class Timer extends StatelessWidget {
  static const TextStyle timerTextStyle = TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Timer')),
      body: Stack(
        children: [
          const Background(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 100.0),
                child: Center(
                  child: Consumer(builder: (context, watch, _) {
                    final state = watch(timerProvider);
                    final String minutesStr = ((state.duration / 60) % 60)
                        .floor()
                        .toString()
                        .padLeft(2, '0');
                    final String secondsStr = (state.duration % 60)
                        .floor()
                        .toString()
                        .padLeft(2, '0');
                    return Text(
                      '$minutesStr:$secondsStr',
                      style: Timer.timerTextStyle,
                    );
                  }),
                ),
              ),
              Actions(),
            ],
          ),
        ],
      ),
    );
  }
}

class Actions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    watch(timerProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _mapStateToActionButtons(
        timerBloc: watch(timerProvider.notifier),
      ),
    );
  }

  List<Widget> _mapStateToActionButtons({required TimerBloc timerBloc}) {
    final TimerState currentState = timerBloc.state;
    if (currentState is TimerInitial) {
      return [
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: () =>
              timerBloc.add(TimerStarted(duration: currentState.duration)),
        ),
      ];
    }
    if (currentState is TimerRunInProgress) {
      return [
        FloatingActionButton(
          child: Icon(Icons.pause),
          onPressed: () => timerBloc.add(TimerPaused()),
        ),
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(TimerReset()),
        ),
      ];
    }
    if (currentState is TimerRunPause) {
      return [
        FloatingActionButton(
          child: Icon(Icons.play_arrow),
          onPressed: () => timerBloc.add(TimerResumed()),
        ),
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(TimerReset()),
        ),
      ];
    }
    if (currentState is TimerRunComplete) {
      return [
        FloatingActionButton(
          child: Icon(Icons.replay),
          onPressed: () => timerBloc.add(TimerReset()),
        ),
      ];
    }
    return [];
  }
}

class Background extends StatelessWidget {
  const Background();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(125, 170, 206, 1),
    );
    // TODO: Send PR to Wave to update example
    //return WaveWidget(
    //  config: CustomConfig(
    //    gradients: [
    //      [
    //        Color.fromRGBO(72, 74, 126, 1),
    //        Color.fromRGBO(125, 170, 206, 1),
    //        Color.fromRGBO(184, 189, 245, 0.7)
    //      ],
    //      [
    //        Color.fromRGBO(72, 74, 126, 1),
    //        Color.fromRGBO(125, 170, 206, 1),
    //        Color.fromRGBO(172, 182, 219, 0.7)
    //      ],
    //      [
    //        Color.fromRGBO(72, 73, 126, 1),
    //        Color.fromRGBO(125, 170, 206, 1),
    //        Color.fromRGBO(190, 238, 246, 0.7)
    //      ],
    //    ],
    //    durations: [19440, 10800, 6000],
    //    heightPercentages: [0.03, 0.01, 0.02],
    //    gradientBegin: Alignment.bottomCenter,
    //    gradientEnd: Alignment.topCenter,
    //  ),
    //  size: Size(double.infinity, double.infinity),
    //  waveAmplitude: 25,
    //  backgroundColor: Colors.blue[50],
    //);
  }
}

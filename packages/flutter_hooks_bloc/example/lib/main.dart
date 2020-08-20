import 'package:flutter/material.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart';

void main() {
  runApp(MyApp());
}

class CounterCubit extends Cubit<int> {
  CounterCubit(int state) : super(state);

  void increment() => emit(state + 1);

  void decrement() => emit(state - 1);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<CounterCubit>(
      create: (_) => CounterCubit(0),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(title: 'BlocHook Example'),
      ),
    );
  }
}

class MyHomePage extends HookWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    print('MyHomePage');
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            HookBuilder(builder: (ctx) {
              print('HookBuilder');
              final counter = useBloc<CounterCubit, int>(
                listener: (_, prev, curr) => print('listener: $prev $curr'),
                allowRebuild: true,
              ).state;
              return Text(
                '$counter',
                style: Theme.of(context).textTheme.headline4,
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.bloc<CounterCubit>().increment(),
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

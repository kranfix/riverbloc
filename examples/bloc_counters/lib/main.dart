import 'cubit/counter_cubit.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CounterCubit1(0)),
        BlocProvider(create: (_) => CounterCubit2(0)),
        BlocProvider(create: (_) => CounterCubit3(0)),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(title: 'Bloc Counters'),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CounterCubit1, int>(
          listener: (context, state) => print('CounterCubit1: $state'),
        ),
        BlocListener<CounterCubit2, int>(
          listener: (context, state) => print('CounterCubit2: $state'),
        ),
        BlocListener<CounterCubit3, int>(
          listener: (context, state) => print('CounterCubit3: $state'),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              BlocBuilder<CounterCubit1, int>(
                builder: (_, state) => CounterItem<CounterCubit1>(state: state),
              ),
              BlocBuilder<CounterCubit2, int>(
                builder: (_, state) => CounterItem<CounterCubit2>(state: state),
              ),
              BlocConsumer<CounterCubit3, int>(
                listener: (_, state) => print('CounterCubit3: $state'),
                builder: (_, state) => CounterItem<CounterCubit3>(state: state),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CounterItem<C extends CounterCubitBase> extends StatelessWidget {
  const CounterItem({Key key, @required this.state})
      : assert(state != null),
        super(key: key);

  final int state;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$C.state:'),
        const Expanded(
          child: SizedBox(),
        ),
        IconButton(
          icon: Icon(Icons.arrow_left),
          onPressed: () => context.bloc<C>().decrement(),
        ),
        Text('$state'),
        IconButton(
          icon: Icon(Icons.arrow_right),
          onPressed: () => context.bloc<C>().increment(),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('state', state, defaultValue: null));
  }
}

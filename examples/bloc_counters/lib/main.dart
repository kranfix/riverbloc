// ignore_for_file: avoid_print

import 'package:bloc_counters/app/app_observer.dart';
import 'package:bloc_counters/blocs/counter_bloc.dart';
import 'package:bloc_counters/blocs/counter_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart';

void main() {
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CounterCubit1(0)),
        BlocProvider(create: (_) => CounterCubit2(0)),
        BlocProvider(create: (_) => CounterCubit3(0)),
        BlocProvider(create: (_) => CounterBloc()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MyHomePage(title: 'Bloc Counters'),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({required this.title, super.key});

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
        BlocListener<CounterBloc, int>(
          listener: (context, state) => print('CounterBloc: $state'),
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
              BlocConsumer<CounterBloc, int>(
                listener: (_, state) => print('CounterBloc: $state'),
                builder: (_, state) =>
                    CounterBlocItem<CounterBloc>(state: state),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CounterItem<C extends CounterCubitBase> extends StatelessWidget {
  const CounterItem({required this.state, super.key});

  final int state;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$C.state:',
          style: const TextStyle(fontSize: 24),
        ),
        const Expanded(
          child: SizedBox(),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_left),
          onPressed: () => context.read<C>().decrement(3),
        ),
        Text(
          '$state',
          style: const TextStyle(fontSize: 24),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right),
          onPressed: () => context.read<C>().increment(3),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('state', state, defaultValue: null));
  }
}

class CounterBlocItem<B extends CounterBloc> extends StatelessWidget {
  const CounterBlocItem({required this.state, super.key});

  final int state;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$B.state:',
          style: const TextStyle(fontSize: 24),
        ),
        const Expanded(
          child: SizedBox(),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_left),
          onPressed: () => context.read<B>().add(const Decremented(3)),
        ),
        Text(
          '$state',
          style: const TextStyle(fontSize: 24),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_right),
          onPressed: () => context.read<B>().add(const Incremented(3)),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('state', state, defaultValue: null));
  }
}

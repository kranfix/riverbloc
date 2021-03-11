import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks_bloc/flutter_riverbloc.dart';
import 'package:flutter_test/flutter_test.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}

class MyCounterApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyCounterAppState();
}

class MyCounterAppState extends State<MyCounterApp> {
  final CounterCubit _cubit = CounterCubit();
  late BlocProvider<CounterCubit> counterProvider;

  @override
  void initState() {
    super.initState();
    counterProvider = BlocProvider((ref) => _cubit);
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          key: const Key('myCounterApp'),
          body: Column(
            children: <Widget>[
              BlocBuilder<CounterCubit, int>(
                bloc: _cubit,
                buildWhen: (previousState, state) {
                  return (previousState + state) % 3 == 0;
                },
                builder: (context, count) {
                  return Text(
                    '$count',
                    key: const Key('myCounterAppTextCondition'),
                  );
                },
              ),
              BlocBuilder<CounterCubit, int>(
                bloc: _cubit,
                builder: (context, count) {
                  return Text(
                    '$count',
                    key: const Key('myCounterAppText'),
                  );
                },
              ),
              ElevatedButton(
                key: const Key('myCounterAppIncrementButton'),
                onPressed: _cubit.increment,
                child: null,
              )
            ],
          ),
        ),
      ),
    );
  }
}

final counterProvider = BlocProvider((ref) => CounterCubit());

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(ThemeData.light());

  void setDarkTheme() => emit(ThemeData.dark());
  void setLightTheme() => emit(ThemeData.light());
}

class DarkThemeCubit extends Cubit<ThemeData> {
  DarkThemeCubit() : super(ThemeData.dark());

  void setDarkTheme() => emit(ThemeData.dark());
  void setLightTheme() => emit(ThemeData.light());
}

class MyThemeApp extends StatefulWidget {
  MyThemeApp({
    Key? key,
    required Cubit<ThemeData> themeCubit,
    required Function onBuild,
  })   : _themeCubit = themeCubit,
        _onBuild = onBuild,
        super(key: key);

  final Cubit<ThemeData> _themeCubit;
  final Function _onBuild;

  @override
  State<MyThemeApp> createState() => MyThemeAppState(
        themeCubit: _themeCubit,
        onBuild: _onBuild,
      );
}

class MyThemeAppState extends State<MyThemeApp> {
  MyThemeAppState({
    required Cubit<ThemeData> themeCubit,
    required Function onBuild,
  })   : _themeCubit = themeCubit,
        _onBuild = onBuild;

  Cubit<ThemeData> _themeCubit;
  bool change = false;
  final Function _onBuild;

  late BlocProvider<Cubit<ThemeData>> themeProvider;

  @override
  void initState() {
    super.initState();
    themeProvider = BlocProvider((ref) {
      if (change) {
        _themeCubit =
            _themeCubit is ThemeCubit ? DarkThemeCubit() : ThemeCubit();
      }
      return _themeCubit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: BlocBuilder<Cubit<ThemeData>, ThemeData>.river(
        provider: themeProvider,
        builder: ((context, theme) {
          _onBuild();
          return MaterialApp(
            key: const Key('material_app'),
            theme: theme,
            home: Column(
              children: [
                RaisedButton(
                  key: const Key('raised_button_1'),
                  onPressed: () {
                    //setState(() {
                    // change = true;
                    //});
                    change = true;
                    context.refresh(themeProvider);
                  },
                ),
                RaisedButton(
                  key: const Key('raised_button_2'),
                  onPressed: () {
                    setState(() {
                      change = false;
                    });
                    context.refresh(themeProvider);
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

void main() {
  group('BlocBuilder.river', () {
    testWidgets('passes initial state to widget', (tester) async {
      final themeCubit = ThemeCubit();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(themeCubit: themeCubit, onBuild: () => numBuilds++),
      );

      final materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.light());
      expect(numBuilds, 1);
    });

    testWidgets('receives events and sends state updates to widget',
        (tester) async {
      final themeCubit = ThemeCubit();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(themeCubit: themeCubit, onBuild: () => numBuilds++),
      );

      themeCubit.setDarkTheme();

      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);
    });

    testWidgets('rebuilds many times without buildWhen', (tester) async {
      final themeCubit = ThemeCubit();
      final themeProvider = BlocProvider((ref) => themeCubit);
      var numBuilds = 0;
      await tester.pumpWidget(
        ProviderScope(
          child: BlocBuilder<ThemeCubit, ThemeData>.river(
            provider: themeProvider,
            builder: (context, theme) {
              numBuilds++;
              return MaterialApp(
                key: const Key('material_app'),
                theme: theme,
                home: const SizedBox(),
              );
            },
          ),
        ),
      );

      themeCubit.setDarkTheme();

      await tester.pumpAndSettle();

      var materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);

      themeCubit.setLightTheme();

      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.light());
      expect(numBuilds, 3);
    });

    testWidgets(
        'updates when the cubit is changed at runtime to a different cubit and'
        'unsubscribes from old cubit', (tester) async {
      final themeCubit = ThemeCubit();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(themeCubit: themeCubit, onBuild: () => numBuilds++),
      );

      await tester.pumpAndSettle();

      var materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.light());
      expect(numBuilds, 1);

      await tester.tap(find.byKey(const Key('raised_button_1')));
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);

      themeCubit.setLightTheme();
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);
    });

    testWidgets(
        'does not update when the cubit is changed at runtime to same cubit '
        'and stays subscribed to current cubit', (tester) async {
      final themeCubit = DarkThemeCubit();
      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(themeCubit: themeCubit, onBuild: () => numBuilds++),
      );

      await tester.pumpAndSettle();

      var materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 1);

      await tester.tap(find.byKey(const Key('raised_button_2')));
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 2);

      themeCubit.setLightTheme();
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.light());
      expect(numBuilds, 3);
    });

    testWidgets('shows latest state instead of initial state', (tester) async {
      final themeCubit = ThemeCubit()..setDarkTheme();
      await tester.pumpAndSettle();

      var numBuilds = 0;
      await tester.pumpWidget(
        MyThemeApp(themeCubit: themeCubit, onBuild: () => numBuilds++),
      );

      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(
        find.byKey(const Key('material_app')),
      );

      expect(materialApp.theme, ThemeData.dark());
      expect(numBuilds, 1);
    });

    testWidgets('with buildWhen only rebuilds when buildWhen evaluates to true',
        (tester) async {
      await tester.pumpWidget(MyCounterApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('myCounterApp')), findsOneWidget);

      final incrementButtonFinder =
          find.byKey(const Key('myCounterAppIncrementButton'));
      expect(incrementButtonFinder, findsOneWidget);

      final counterText1 =
          tester.widget<Text>(find.byKey(const Key('myCounterAppText')));
      expect(counterText1.data, '0');

      final conditionalCounterText1 = tester
          .widget<Text>(find.byKey(const Key('myCounterAppTextCondition')));
      expect(conditionalCounterText1.data, '0');

      await tester.tap(incrementButtonFinder);
      await tester.pumpAndSettle();

      final counterText2 =
          tester.widget<Text>(find.byKey(const Key('myCounterAppText')));
      expect(counterText2.data, '1');

      final conditionalCounterText2 = tester
          .widget<Text>(find.byKey(const Key('myCounterAppTextCondition')));
      expect(conditionalCounterText2.data, '0');

      await tester.tap(incrementButtonFinder);
      await tester.pumpAndSettle();

      final counterText3 =
          tester.widget<Text>(find.byKey(const Key('myCounterAppText')));
      expect(counterText3.data, '2');

      final conditionalCounterText3 = tester
          .widget<Text>(find.byKey(const Key('myCounterAppTextCondition')));
      expect(conditionalCounterText3.data, '2');

      await tester.tap(incrementButtonFinder);
      await tester.pumpAndSettle();

      final counterText4 =
          tester.widget<Text>(find.byKey(const Key('myCounterAppText')));
      expect(counterText4.data, '3');

      final conditionalCounterText4 = tester
          .widget<Text>(find.byKey(const Key('myCounterAppTextCondition')));
      expect(conditionalCounterText4.data, '2');
    });
  });
}

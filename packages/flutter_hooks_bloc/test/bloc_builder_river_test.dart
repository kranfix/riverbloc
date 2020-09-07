import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks_bloc/flutter_hooks_bloc.dart' hide BlocProvider;
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverbloc/riverbloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
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
    Key key,
    @required Cubit<ThemeData> themeCubit,
    @required Function onBuild,
  })  : _themeCubit = themeCubit,
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
    @required Cubit<ThemeData> themeCubit,
    @required Function onBuild,
  })  : _themeCubit = themeCubit,
        _onBuild = onBuild;

  Cubit<ThemeData> _themeCubit;
  bool change = false;
  final Function _onBuild;

  BlocProvider<Cubit<ThemeData>> themeProvider;

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
                    change = true;
                    context.refresh(themeProvider);
                  },
                ),
                RaisedButton(
                  key: const Key('raised_button_2'),
                  onPressed: () {
                    change = false;
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
    testWidgets('throws if initialized with null cubit and builder',
        (tester) async {
      try {
        await tester.pumpWidget(
          ProviderScope(
            child: BlocBuilder<CounterCubit, int>.river(
              provider: null,
              builder: (_, __) => const SizedBox(),
            ),
          ),
        );
        fail('provider should not be null');
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with null builder', (tester) async {
      try {
        await tester.pumpWidget(
          BlocBuilder<CounterCubit, int>.river(
            provider: counterProvider,
            builder: null,
          ),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

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
  });
}

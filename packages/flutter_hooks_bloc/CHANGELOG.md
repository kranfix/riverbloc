## [0.9.0]

- Renaming `BlocListenableBase` to `NesteableBlocListener`.
- `BlocListener` is has `debugFillProperties`.
- `MultiBlocListener` is has `debugFillProperties`.
- Fix in `useBloc` documentation.

## [0.8.0]

- `useBloc` use `onEmitted` instead `listener` and `buildWhen`

## [0.7.0]

- Removing BlocListenable in favor of only BlocListener
- Removing CubitComposer in favor of BlocWidget
- Dedicating a file `flutter_bloc.dart` for reexport wished widgets
- `flutter_hooks` dependency updated
- `useBloc` rebuilds `HookWidget` by default

## [0.6.0]

- Unexporting `flutter_hooks` by default
- Removing BlocBuilderInterface
- Fixing useBloc description in README

## [0.5.0]

- Some documentation added
- Refactor for reducing the quantity of mixins and extensions
- Converting some public API to private
- Optimization in check if all `BlocListener`s have no child
  in a `MultiBlocListener`

## [0.4.0]

- useBloc
- BlocConsumer
- BlocListener
- BlocBuilder

## [0.17.0] - 2021-11-26

- Upgraded bloc to 8.1.3
- Upgraded flutter_hooks to 0.20.3

## [0.16.0] - 2021-10-20

- Using bloc 7.2
- Fix rebuild of state
- breaking: `useBloc<B, S>` returns `S` instead of `B`
- Updating README docs

## [0.15.0+1] - 2021-07-04

- Updating README docs

## [0.15.0] - 2021-07-04

- Upgrading dependencies.

## [0.14.0] - 2021-03-18

- Removing `riverbloc` dependece.
- `breaking` removing the `river` constructors

## [0.13.0] - 2021-03-18

- Using `bloc 7.0.0` and `riverbloc 0.2.2`.
- Using `BlocBase` clase.

## [0.12.2] - 2021-03-11

- Fixing typo renaming `Nesteable` to `Nestable`.
- Adding documentation for `Nestable`.

## [0.12.1] - 2021-03-11

- Using last version of flutter_bloc (7.0.0-nullsafety.5) and pedantic (1.11.0)

## [0.12.0] - 2021-03-11

- Upgrading to null-safety

## [0.11.0]

- Adding `userRiverBloc()` hook function.
- Adding contructors for using riverbloc with the bloc widgets:
  - `BlocListener.river()`
  - `BlocBuilder.river()`
  - `BlocConsumer.river()`
- New library `flutter_riverbloc`:
  ```dart
  import 'package:flutter_hooks_bloc/flutter_riverbloc.dart';
  ```

## [0.10.0]

- Adding documentation for a imaginary `MultiBlocBuilder`.
- Refactor class templates to depends on state runtimeType.
- Protecting HookWidget.use()

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

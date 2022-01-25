- ## [2.0.0-dev.0] - 2022-01-25

- Upgraded to `riverpod-2.0.0-dev.0`.

- ## [1.0.0+2] - 2021-11-25

- Removed `BlocFamilyCreate`.
- Removed `AutoDisposeBlocFamilyCreate`.

## [1.0.0+1] - 2021-11-25

- Added library docs.
- Fix for bad name in some documentation macros

## [1.0.0] - 2021-11-24

- Updated riverpod: 1.0.0
- Updated bloc: 8.0.0
- `ref.refresh(myBlocProvider)` is equivalent to `ref.refresh(myBlocProvider.bloc)`.
- Added `BlocProviderFamily`
- Added `AutoDisposeBlocProviderFamily`.
- Builders `BlocProvider.autodispose`, `BlocProvider.family` and `BlocProvider.family.autodispose`.

## [0.5.0] - 2021-05-02

- Adding `BlocProvider.autoDispose`.

## [0.4.0] - 2021-04-21

- Adding `BlocProvider.stream`

## [0.3.0+1] - 2021-04-21

- Fixing readme example

## [0.3.0] - 2021-04-21

- `breaking`: `BlocProvider` has a `notifier` like `StateNotifierProvider`

## [0.2.5] - 2021-04-19

- Upgrading riverpod to 0.14.0+1

## [0.2.4] - 2021-03-2

- New riverbloc logo (thanks to @SergioEric)

## [0.2.3] - 2021-03-18

- Adding Very Good Analysis

## [0.2.2] - 2021-03-18

- Upgrading dependency to bloc 7.0.0 (stable)
- Using the new `BlocBase` class.

## [0.2.1] - 2021-03-07

- Updating meta dependency

## [0.2.0] - 2021-03-07

- Null-safety added
- Using Bloc instead of Cubit because Cubit now extends Bloc.
- Adding test for Bloc.

## [0.1.2] - 2020-10-08

- BlocProvider as sealed class
- analysis options with no includes

## [0.1.1] - 2020-10-08

- Upgrading to `riverpod-0.11.0`

## [0.1.0] - 2020-09-05

- Upgrading dependenies `riverpod-0.8.0` and `bloc-6.0.3`
- Fix: `BlocProvider.refresh` effect on `BlocStateProvider`
- Override to a BlocProvider with provider

## [0.0.1+1] - 2020-08-30

- Better documentation
- Coverage badge

## [0.0.1] - 2020-08-30

- BlocProvider and BlocSateProvider

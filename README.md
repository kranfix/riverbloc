# Bloc Alternatives libraries

A collection of dart & flutter packages to work with
[Bloc](https://pub.dev/packages/bloc)

## Packages

**[flutter_hooks_bloc](packages/flutter_hooks_bloc)**

A reimplementation of [flutter_bloc](https://pub.dev/packages/flutter_bloc)
based on [flutter_hooks](https://pub.dev/packages/flutter_hooks).

Advantages:

- Now you can use a `useBloc` hook function.
- Bloc widgets has less compostion in te widget tree.
- Widget inspector gives information about bloc/cubit.
- It's easy to create a widget with a `MultiBlocBuilder` behavior.

**[riverbloc](packages/riverbloc)**

Expose a `BlocProvider` based on [Riverpod](https://pub.dev/packages/riverpod)
and can be use with
[flutter_riverpod](https://pub.dev/packages/flutter_riverpod) or
[hooks_riverpod](https://pub.dev/packages/hooks_riverpod) instead of
[flutter_bloc](https://pub.dev/packages/flutter_bloc).

With this package, `MultiBlocProvider` is not necessary anymore.
No more `FlutterError/ProviderNotFoundException` on `context.bloc()` invocation.

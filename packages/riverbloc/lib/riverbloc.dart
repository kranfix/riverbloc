/// Riverbloc exposes providers for [Bloc] and [Cubit] instances bases in
/// `riverpod` package instead of `provider` package.
///
/// Providers:
/// - [BlocProvider]
/// - [AutoDisposeBlocProvider]
/// - [BlocProviderFamily]
/// - [AutoDisposeBlocProviderFamily]
library riverbloc;

import 'package:bloc/bloc.dart';
import 'package:riverbloc/src/framework.dart';

export 'package:bloc/bloc.dart';
export 'package:riverpod/riverpod.dart';
export 'src/framework.dart';
export 'src/unimplemented_provider_error.dart';

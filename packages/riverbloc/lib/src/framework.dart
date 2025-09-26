// We need internal implementations of riverpod to implement this package
// ignore_for_file: implementation_imports
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:riverbloc/src/unimplemented_provider_error.dart';
import 'package:riverpod/legacy.dart';
import 'package:riverpod/src/common/listenable.dart';
import 'package:riverpod/src/common/result.dart';
import 'package:riverpod/src/framework.dart';

part 'bloc_provider.dart';
part 'bloc_provider_state.dart';
part 'builders.dart';
part 'bloc_provider_family.dart';

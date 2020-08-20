import 'bloc_hook.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide BlocBuilder;
import 'package:flutter_hooks/flutter_hooks.dart';

mixin BlocBuilderInterface<C extends Cubit<S>, S> on CubitComposer<C> {
  BlocWidgetBuilder<S> get builder;
  BlocBuilderCondition<S> get buildWhen;
}

class BlocBuilder<C extends Cubit<S>, S> extends HookWidget
    with CubitComposer<C>, BlocBuilderInterface<C, S> {
  const BlocBuilder({
    Key key,
    this.cubit,
    @required this.builder,
    this.buildWhen,
  })  : assert(builder != null),
        super(key: key);

  @override
  final C cubit;

  @override
  final BlocWidgetBuilder<S> builder;

  @override
  final BlocBuilderCondition<S> buildWhen;

  @override
  Widget build(BuildContext context) {
    final _cubit =
        useBloc<C, S>(cubit: cubit, buildWhen: buildWhen, allowRebuild: true);
    return builder(context, _cubit.state);
  }
}

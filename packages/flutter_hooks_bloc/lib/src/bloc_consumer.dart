import 'bloc_hook.dart';
import 'bloc_builder.dart';
import 'bloc_listener.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide BlocConsumer;
import 'package:flutter_hooks/flutter_hooks.dart';

class BlocConsumer<C extends Cubit<S>, S> extends HookWidget
    with
        CubitComposer<C>,
        BlocListenerInterface<C, S>,
        BlocBuilderInterface<C, S> {
  const BlocConsumer({
    Key key,
    this.cubit,
    this.listenWhen,
    this.listener,
    this.buildWhen,
    @required this.builder,
  })  : assert(listener != null),
        assert(builder != null),
        super(key: key);

  final C cubit;
  final BlocListenerCondition<S> listenWhen;
  final BlocWidgetListener<S> listener;
  final BlocBuilderCondition<S> buildWhen;
  final BlocWidgetBuilder<S> builder;

  @override
  Widget build(BuildContext context) {
    final _cubit = useBloc<C, S>(
      cubit: cubit,
      listener: listenerCallback,
      buildWhen: buildWhen,
      allowRebuild: true,
    );
    return builder(context, _cubit.state);
  }
}

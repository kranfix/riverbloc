// ignore_for_file: invalid_use_of_internal_member

part of 'framework.dart';

/// {@macro riverpod.providerrefbase}
abstract class BlocProviderRef<B extends BlocBase<S>, S> implements Ref<S> {
  /// The [Bloc] currently exposed by this provider.
  ///
  /// Cannot be accessed while creating the provider.
  B get bloc;
}

/// The element of [StateNotifierProvider].
class BlocProviderElement<B extends BlocBase<S>, S>
    extends ProviderElementBase<S> implements BlocProviderRef<B, S> {
  BlocProviderElement._(_BlocProviderBase<B, S> super.provider);

  @override
  B get bloc => _blocNotifier.value;
  final _blocNotifier = ProxyElementValueNotifier<B>();

  void Function()? _removeListener;

  @override
  void create({required bool didChangeDependency}) {
    final provider = this.provider as _BlocProviderBase<B, S>;

    final notifier =
        _blocNotifier.result = Result.guard(() => provider._create(this));

    setState(notifier.requireState.state);

    final sub = notifier.requireState.stream.listen(setState);

    _removeListener = sub.cancel;
  }

  @override
  bool updateShouldNotify(S previous, S next) {
    return previous != next;
  }

  @override
  void runOnDispose() {
    super.runOnDispose();

    _removeListener?.call();
    _removeListener = null;

    final notifier = _blocNotifier.result?.stateOrNull;
    if (notifier != null) {
      runGuarded(notifier.close);
    }
    _blocNotifier.result = null;
  }

  @override
  void visitChildren({
    required void Function(ProviderElementBase<dynamic> element) elementVisitor,
    required void Function(ProxyElementValueNotifier<dynamic> element)
        notifierVisitor,
  }) {
    super.visitChildren(
      elementVisitor: elementVisitor,
      notifierVisitor: notifierVisitor,
    );
    notifierVisitor(_blocNotifier);
  }
}

ProviderElementProxy<S, B> _notifier<B extends BlocBase<S>, S>(
  _BlocProviderBase<B, S> that,
) {
  return ProviderElementProxy<S, B>(
    that,
    (element) {
      return (element as BlocProviderElement<B, S>)._blocNotifier;
    },
  );
}

// ignore: subtype_of_sealed_class
abstract class _BlocProviderBase<B extends BlocBase<S>, S>
    extends ProviderBase<S> {
  const _BlocProviderBase({
    required super.name,
    required super.from,
    required super.argument,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
  });

  /// Obtains the [Bloc] associated with this provider, without listening
  /// to state changes.
  ///
  /// This is typically used to invoke methods on a [Bloc]. For example:
  ///
  /// ```dart
  /// Button(
  ///   onTap: () => ref.read(counterProvider.bloc).add(Increment()),
  /// )
  /// ```
  ///
  /// This listenable will notify its state if the [Bloc] or [Cubit] instance
  /// changes.
  /// This may happen if the provider is refreshed or one of its dependencies
  /// has changes.
  ProviderListenable<B> get bloc;

  B _create(covariant BlocProviderElement<B, S> ref);
}

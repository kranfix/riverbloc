part of 'framework.dart';

// ignore: subtype_of_sealed_class
class _NotifierProvider<B extends BlocBase<Object?>> extends Provider<B> {
  _NotifierProvider(
    Create<B, ProviderRefBase> create, {
    required String? name,
  }) : super(
          (ref) {
            final notifier = create(ref);
            ref.onDispose(notifier.close);
            return notifier;
          },
          name: modifierName(name, 'notifier'),
        );
}

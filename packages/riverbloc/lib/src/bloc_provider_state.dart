part of 'framework.dart';

/// Signature for the `shouldNotify` function which takes the previous `state`
/// and the current `state` and is responsible for returning a [bool] which
/// determines whether or not to call `ref.listen()` or `ref.watch`
/// with the current `state`.
typedef BlocUpdateCondition<S> = bool Function(S previous, S current);

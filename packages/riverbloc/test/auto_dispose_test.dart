import 'package:mocktail/mocktail.dart';
import 'package:riverbloc/riverbloc.dart';
import 'package:test/test.dart';

import 'helpers/helpers.dart';

void main() {
  group('AutoDispose Provider names', () {
    test('AutoDispose BlocProvider.bloc with no name', () {
      final counterBlocProvider = BlocProvider.autoDispose<CounterBloc, int>(
        (ref) => CounterBloc(0),
      );
      expect(counterBlocProvider.name, isNull);

      final counterCubitProvider = BlocProvider.autoDispose<CounterCubit, int>(
        (ref) => CounterCubit(0),
      );
      expect(counterCubitProvider.name, isNull);
    });

    test('BlocProvider.notifier with name', () {
      final counterBlocProvider = BlocProvider<CounterBloc, int>(
        (ref) => CounterBloc(0),
        name: 'counterBloc',
      );
      expect(counterBlocProvider.name, 'counterBloc');

      final counterCubitProvider = BlocProvider.autoDispose<CounterCubit, int>(
        (ref) => CounterCubit(0),
        name: 'counterCubit',
      );
      expect(counterCubitProvider.name, 'counterCubit');
    });
  });

  group('AutoDisposeBlocProvider.scoped', () {
    test('direct usage must throw UnimplementedProviderError', () {
      final container = ProviderContainer.test();

      final provider =
          BlocProvider.autoDispose.scoped<CounterBloc, int>('someName');

      expectScoped(container, provider);
    });
  });

  group('refresh', () {
    test(
        'Reading the same provider twice synchronously must return '
        'the same blocs', () {
      final container = ProviderContainer.test();
      final counterCubitProvider = BlocProv((ref) => CounterCubit(0));
      final bloc1 = container.read(counterCubitProvider.bloc);
      final bloc2 = container.read(counterCubitProvider.bloc);
      expect(bloc1, same(bloc2));
    });

    test(
        'Reading the same provider twice asynchronously must return '
        'different blocs', () async {
      final container = ProviderContainer.test();
      final counterCubitProvider =
          BlocProv.autoDispose<CounterCubit, int>((ref) => CounterCubit(0));
      final bloc1 = container.read(counterCubitProvider.bloc);

      await Future(() {});
      final bloc2 = container.read(counterCubitProvider.bloc);
      expect(bloc1, isNot(same(bloc2)));
    });

    test('listening the provider must refresh the bloc', () async {
      final container = ProviderContainer.test();
      final counterCubitProvider =
          BlocProv.autoDispose<CounterCubit, int>((ref) => CounterCubit(0));

      final listener = Listener<CounterCubit>();

      final sub = container.listen<CounterCubit>(
        counterCubitProvider.bloc,
        listener.call,
        fireImmediately: true,
      );

      final bloc1 = container.read(counterCubitProvider.bloc);
      verify(() => listener(null, bloc1)).called(1);

      final bloc2 = container.refresh(counterCubitProvider.bloc);
      verify(() => listener(null, bloc2)).called(1);
      expect(bloc1, isNot(equals(bloc2)));

      sub.close();
    });
  });

  group('AlwaysAlive vs AutoDispose', () {
    test('BlocProvider', () async {
      var closeCounter1 = 0;
      var closeCounter2 = 0;
      void onClose1() => closeCounter1++;
      void onClose2() => closeCounter2++;

      final listener1 = Listener<int>();
      final listener2 = Listener<int>();

      final counterProvider1 = BlocProvider<CounterCubit, int>(
        (ref) => CounterCubit(0, onClose: onClose1),
      );
      final counterProvider2 = BlocProvider.autoDispose<CounterCubit, int>(
        (ref) => CounterCubit(0, onClose: onClose2),
      );

      final container = ProviderContainer.test();

      final sub1 = container.listen<int>(counterProvider1, listener1.call);

      final sub2 = container.listen<int>(counterProvider2, listener2.call);

      expect(sub1.read(), 0);
      expect(sub2.read(), 0);

      container.read(counterProvider1.bloc).increment();
      container.read(counterProvider2.bloc).increment();
      await Future(() {});
      expect(sub1.read(), 1);
      verify(() => listener1(0, 1)).called(1);
      expect(sub2.read(), 1);
      verify(() => listener2(0, 1)).called(1);

      verifyNoMoreInteractions(listener1);
      verifyNoMoreInteractions(listener2);

      expect(closeCounter1, 0);
      expect(closeCounter2, 0);
      sub1.close();
      sub2.close();
      await Future(() {});
      expect(closeCounter1, 0);
      expect(closeCounter2, 1);

      expect(container.read(counterProvider1), 1);
      expect(container.read(counterProvider2), 0);

      await Future(() {});
      expect(closeCounter1, 0);
      expect(closeCounter2, 2);

      container.read(counterProvider1.bloc).increment();
      container.read(counterProvider2.bloc).increment();
      await Future(() {});
      expect(closeCounter1, 0);
      expect(closeCounter2, 3);

      expect(container.read(counterProvider1), 2);
      expect(container.read(counterProvider2), 0);

      await Future(() {});
      expect(closeCounter1, 0);
      expect(closeCounter2, 4);
    });
  });

  group('AutoDispose BlocProvider override', () {
    test('Override with provider', () async {
      var closeCounter1 = 0;
      var closeCounter2 = 0;
      void onClose1() => closeCounter1++;
      void onClose2() => closeCounter2++;
      final counterProvider1 = BlocProvider.autoDispose<CounterCubit, int>(
        (ref) => CounterCubit(0, onClose: onClose1),
      );

      final container = ProviderContainer.test(
        overrides: [
          counterProvider1
              .overrideWith((ref) => CounterCubit(5, onClose: onClose2)),
        ],
      );

      final listener = Listener<int>();
      final sub = container.listen<int>(counterProvider1, listener.call);

      expect(sub.read(), 5);
      container.read(counterProvider1.bloc).increment();
      await Future(() {});
      expect(sub.read(), 6);

      expect(closeCounter1, 0);
      expect(closeCounter2, 0);
      sub.close();
      await Future(() {});
      expect(closeCounter1, 0);
      expect(closeCounter2, 1);
    });
  });

  group('BlocProvider.bloc', () {
    final counterCubitProvider = BlocProvider.autoDispose<CounterCubit, int>(
      (ref) => CounterCubit(0),
    );

    test('BlocProvider.bloc get BlocBase Object', () {
      final container = ProviderContainer.test();
      final counterCubit = container.read(counterCubitProvider.bloc);

      expect(counterCubit, isA<BlocBase<int>>());
    });
  });

  group('AutoDisposeBlocProvider overrides itself', () {
    final counterProvider = BlocProvider.autoDispose<CounterBloc, int>(
      (ref) => CounterBloc(0),
    );
    test('without overrideWithProvider', () async {
      final container1 = ProviderContainer.test();

      final container2 = ProviderContainer.test(
        parent: container1,
        overrides: [counterProvider],
      );

      expect(
        container1.read(counterProvider.bloc),
        isNot(equals(container2.read(counterProvider.bloc))),
      );
    });
  });
}

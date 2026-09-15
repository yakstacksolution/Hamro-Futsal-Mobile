import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/utils/bloc_safe_add.dart';

/// The crash: a screen hands off to a dialog, sheet or pushed page, is
/// disposed while that work is in flight, and the result asks its bloc — now
/// closed — to refresh. Bloc throws `Bad state: Cannot add new events after
/// calling close`, which is reported as a fatal error.
class _CounterBloc extends Bloc<int, int> {
  _CounterBloc() : super(0) {
    on<int>((int event, Emitter<int> emit) => emit(state + event));
  }
}

void main() {
  test('adding to a closed bloc throws — this is the crash', () async {
    final _CounterBloc bloc = _CounterBloc();
    await bloc.close();
    expect(() => bloc.add(1), throwsStateError);
  });

  test('addIfOpen drops the event instead of throwing', () async {
    final _CounterBloc bloc = _CounterBloc();
    await bloc.close();
    expect(() => bloc.addIfOpen(1), returnsNormally);
  });

  test('addIfOpen still delivers while the bloc is open', () async {
    final _CounterBloc bloc = _CounterBloc();
    addTearDown(bloc.close);

    bloc.addIfOpen(5);
    await expectLater(bloc.stream, emits(5));
    expect(bloc.state, 5);
  });
}

import 'package:flutter_bloc/flutter_bloc.dart';

extension SafeBlocAdd<E, S> on Bloc<E, S> {
  void addIfOpen(E event) {
    if (isClosed) return;
    add(event);
  }
}

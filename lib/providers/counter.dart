import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

class CounterState {
  int _value = 0;
  void inc() => _value++;
  void dec() => _value--;
  int get value => _value;
  bool diff(CounterState old) {
    return old.value != _value;
  }
}

class CounterProvider extends InheritedWidget {
  final CounterState state = CounterState();
  CounterProvider({required Widget child}) : super(child: child);
  static CounterProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CounterProvider>();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    // TODO: implement updateShouldNotify
    return true; // assistir novamente a aula nº 222, aprender sobre inheritedWidget.
  }
}

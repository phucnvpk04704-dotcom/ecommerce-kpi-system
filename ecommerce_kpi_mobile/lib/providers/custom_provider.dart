import 'package:flutter/material.dart';

class ChangeNotifierProvider<T extends ChangeNotifier> extends StatefulWidget {
  final T Function(BuildContext context) create;
  final Widget child;

  const ChangeNotifierProvider({
    super.key,
    required this.create,
    required this.child,
  });

  @override
  State<ChangeNotifierProvider<T>> createState() => _ChangeNotifierProviderState<T>();

  static T of<T extends ChangeNotifier>(BuildContext context, {bool listen = true}) {
    if (listen) {
      final provider = context.dependOnInheritedWidgetOfExactType<_InheritedNotifierProvider<T>>();
      if (provider == null) {
        throw FlutterError('No ChangeNotifierProvider<$T> found in context');
      }
      return provider.notifier;
    } else {
      final provider = context.getElementForInheritedWidgetOfExactType<_InheritedNotifierProvider<T>>()?.widget as _InheritedNotifierProvider<T>?;
      if (provider == null) {
        throw FlutterError('No ChangeNotifierProvider<$T> found in context');
      }
      return provider.notifier;
    }
  }
}

class _ChangeNotifierProviderState<T extends ChangeNotifier> extends State<ChangeNotifierProvider<T>> {
  late T _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = widget.create(context);
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _notifier,
      builder: (context, child) {
        return _InheritedNotifierProvider<T>(
          notifier: _notifier,
          child: widget.child,
        );
      },
    );
  }
}

class _InheritedNotifierProvider<T extends ChangeNotifier> extends InheritedWidget {
  final T notifier;

  const _InheritedNotifierProvider({
    super.key,
    required this.notifier,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedNotifierProvider<T> oldWidget) {
    return true;
  }
}

class Consumer<T extends ChangeNotifier> extends StatelessWidget {
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;

  const Consumer({
    super.key,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      ChangeNotifierProvider.of<T>(context, listen: true),
      child,
    );
  }
}

extension ProviderExtension on BuildContext {
  T read<T extends ChangeNotifier>() {
    return ChangeNotifierProvider.of<T>(this, listen: false);
  }
  T watch<T extends ChangeNotifier>() {
    return ChangeNotifierProvider.of<T>(this, listen: true);
  }
}

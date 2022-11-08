import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gtfs_inspector/input/input.dart';
import 'package:gtfs_inspector/inspect/inspect.dart';

part '../router/router.dart';

class App extends StatelessWidget {
  const App({super.key});

  static const inputDecorationTheme = InputDecorationTheme(
    border: OutlineInputBorder(),
    helperMaxLines: 5,
    errorMaxLines: 5,
  );

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.indigo,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      inputDecorationTheme: inputDecorationTheme,
      brightness: Brightness.light,
    );
    final darkTheme = ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.indigo,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      inputDecorationTheme: inputDecorationTheme,
      brightness: Brightness.dark,
    );

    return MaterialApp.router(
      theme: lightTheme,
      darkTheme: darkTheme,
      routerConfig: _router,
    );
  }
}

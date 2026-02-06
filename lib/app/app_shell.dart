import 'package:flutter/material.dart';

import '../shared/widgets/app_bottom_nav.dart';

/// Shell that wraps main tab content and shows bottom navigation.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.currentPath,
    required this.child,
  });

  final String currentPath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNav(currentPath: currentPath),
    );
  }
}

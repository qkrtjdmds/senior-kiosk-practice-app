import 'package:flutter/material.dart';

class PageScaffold extends StatelessWidget {
  const PageScaffold({required this.child, this.title, super.key});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(title: Text(title!), leading: const SizedBox.shrink()),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

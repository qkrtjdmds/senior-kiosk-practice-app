import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_routes.dart';

class PageScaffold extends StatelessWidget {
  const PageScaffold({
    required this.child,
    this.title,
    this.showBackButton = true,
    this.backRoute,
    this.actions,
    super.key,
  });

  final Widget child;
  final String? title;
  final bool showBackButton;
  final String? backRoute;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              toolbarHeight:
                  56 +
                  (MediaQuery.textScalerOf(context).scale(1) - 1).clamp(
                        0,
                        0.5,
                      ) *
                      64,
              automaticallyImplyLeading: false,
              leadingWidth: showBackButton ? 56 : 0,
              leading: showBackButton
                  ? IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(backRoute ?? AppRoutes.home);
                        }
                      },
                      icon: const Icon(Icons.arrow_back),
                      tooltip: '이전 화면으로 돌아가기',
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                    )
                  : null,
              titleSpacing: showBackButton ? 0 : 24,
              title: Text(
                title!,
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.fade,
              ),
              actions: actions,
            ),
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

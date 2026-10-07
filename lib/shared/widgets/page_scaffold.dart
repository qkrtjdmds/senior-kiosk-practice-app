import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_routes.dart';
import '../../app/app_theme.dart';

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
    void goBack() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(backRoute ?? AppRoutes.home);
      }
    }

    return PopScope(
      canPop: !showBackButton || context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && showBackButton) goBack();
      },
      child: Scaffold(
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
                        onPressed: goBack,
                        icon: const Icon(Icons.arrow_back),
                        tooltip: '이전 화면으로 돌아가기',
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                      )
                    : null,
                titleSpacing: showBackButton ? 0 : AppSpacing.lg,
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
              padding: EdgeInsets.fromLTRB(
                MediaQuery.sizeOf(context).width <= 340 ? 16 : 20,
                20,
                MediaQuery.sizeOf(context).width <= 340 ? 16 : 20,
                36,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../learning/widgets/learning_widgets.dart';
import 'cafe_order_provider.dart';

class CafeKioskScaffold extends StatelessWidget {
  const CafeKioskScaffold({
    required this.stageLabel,
    required this.cartCount,
    required this.onBack,
    required this.onCart,
    required this.child,
    this.orderSummary,
    this.bottom,
    super.key,
  });

  final String stageLabel;
  final int cartCount;
  final VoidCallback onBack;
  final VoidCallback onCart;
  final String? orderSummary;
  final Widget child;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F4),
      appBar: AppBar(
        toolbarHeight: 68,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFAF9F4),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const Border(bottom: BorderSide(color: learningSageBorder)),
        leading: IconButton(
          onPressed: onBack,
          tooltip: '이전 화면으로 돌아가기',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: const Icon(Icons.arrow_back),
        ),
        titleSpacing: 4,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '카페 주문',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF23413C),
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              stageLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          Semantics(
            label: '장바구니 보기, 현재 $cartCount개',
            button: true,
            child: IconButton(
              onPressed: onCart,
              tooltip: '장바구니 보기',
              constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                backgroundColor: colors.primary,
                textColor: colors.onPrimary,
                child: const Icon(Icons.shopping_cart_outlined, size: 28),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (orderSummary != null && orderSummary!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                color: learningSageSurface.withValues(alpha: 0.55),
                child: Text(
                  orderSummary!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF23413C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Expanded(child: child),
            if (bottom != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAF9F4),
                  border: Border(top: BorderSide(color: learningSageBorder)),
                ),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}

class CafeCategoryTabs extends StatelessWidget {
  const CafeCategoryTabs({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final CafeCategory selected;
  final ValueChanged<CafeCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final category in CafeCategory.values)
            InkWell(
              onTap: () => onSelected(category),
              child: Container(
                constraints: const BoxConstraints(minHeight: 54),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected == category
                          ? const Color(0xFF23413C)
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  category.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: selected == category
                        ? const Color(0xFF23413C)
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: selected == category
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CafeMenuCard extends StatelessWidget {
  const CafeMenuCard({
    required this.item,
    required this.onPressed,
    this.recommended = false,
    super.key,
  });

  final CafeMenuItem item;
  final VoidCallback onPressed;
  final bool recommended;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: recommended
          ? learningSageSurface.withValues(alpha: 0.7)
          : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 44, color: colors.primary),
              const SizedBox(height: 10),
              Text(
                item.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              Text(
                formatPracticePrice(item.practicePrice),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (recommended) ...[
                const SizedBox(height: 4),
                Text(
                  '이 메뉴를 골라보세요',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CafeOptionCard extends StatelessWidget {
  const CafeOptionCard({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.selected = false,
    this.recommended = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool selected;
  final bool recommended;

  @override
  Widget build(BuildContext context) {
    final active = selected || recommended;
    return Material(
      color: active ? learningSageSurface : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 92),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? const Color(0xFF23413C) : learningSageBorder,
              width: active ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: const Color(0xFF23413C)),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                softWrap: true,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF23413C),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CafePracticeNotice extends StatelessWidget {
  const CafePracticeNotice({
    required this.message,
    this.icon = Icons.info_outline,
    super.key,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      color: learningSageSurface.withValues(alpha: 0.72),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: const Color(0xFF23413C)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              softWrap: true,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: const Color(0xFF23413C)),
            ),
          ),
        ],
      ),
    );
  }
}

class CafeSelectionRow extends StatelessWidget {
  const CafeSelectionRow({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? learningSageSurface : Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: learningSageBorder)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 30, color: const Color(0xFF23413C)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? const Color(0xFF23413C) : learningSageBorder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CafeCartItemCard extends StatelessWidget {
  const CafeCartItemCard({
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
    super.key,
  });

  final CafeCartItem item;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.menu.icon, size: 34, color: const Color(0xFF23413C)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.menu.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.temperature.label} · ${item.size.label} · ${item.dineOption.label}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                tooltip: '${item.menu.name} 삭제',
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 10,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: learningSageBorder),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QuantityButton(
                      label: '−',
                      tooltip: '수량 줄이기',
                      onPressed: onDecrease,
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        '${item.quantity}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    _QuantityButton(
                      label: '+',
                      tooltip: '수량 늘리기',
                      onPressed: onIncrease,
                    ),
                  ],
                ),
              ),
              Text(
                formatPracticePrice(item.totalPrice),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF23413C),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: learningSageBorder),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.label,
    required this.tooltip,
    required this.onPressed,
  });

  final String label;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      icon: Text(label, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

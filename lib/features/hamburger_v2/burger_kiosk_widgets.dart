import 'package:flutter/material.dart';

const burgerIvory = Color(0xFFFAF9F4);
const burgerGreen = Color(0xFF23413C);
const burgerBeige = Color(0xFFF1E9DC);
const burgerOrange = Color(0xFFB56B3C);

class BurgerKioskScaffold extends StatelessWidget {
  const BurgerKioskScaffold({
    super.key,
    required this.child,
    required this.onBack,
    this.summary,
    this.cartCount = 0,
    this.bottom,
  });
  final Widget child;
  final VoidCallback onBack;
  final String? summary;
  final int cartCount;
  final Widget? bottom;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: burgerIvory,
    appBar: AppBar(
      leading: IconButton(
        tooltip: '이전 화면으로 돌아가기',
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back),
      ),
      title: const Text('햄버거 주문'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Badge(
            label: Text('$cartCount'),
            isLabelVisible: cartCount > 0,
            child: const Icon(Icons.shopping_cart_outlined),
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1),
      ),
    ),
    body: SafeArea(
      child: Column(
        children: [
          if (summary?.isNotEmpty == true)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: burgerBeige,
              child: Text(
                summary!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Expanded(child: child),
        ],
      ),
    ),
    bottomNavigationBar: bottom == null
        ? null
        : SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: bottom,
            ),
          ),
  );
}

class BurgerChoice extends StatelessWidget {
  const BurgerChoice({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.selected = false,
    this.subtitle,
  });
  final String label;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;
  @override
  Widget build(BuildContext context) => Material(
    color: selected ? burgerBeige : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: selected ? burgerGreen : const Color(0xFFD8D4C9),
        width: selected ? 2 : 1,
      ),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 76),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: burgerGreen, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      softWrap: true,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (subtitle != null) Text(subtitle!, softWrap: true),
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check_circle, color: burgerGreen),
            ],
          ),
        ),
      ),
    ),
  );
}

class BurgerMenuTile extends StatelessWidget {
  const BurgerMenuTile({
    super.key,
    required this.name,
    required this.description,
    required this.price,
    required this.onTap,
  });

  final String name;
  final String description;
  final String price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFFD8D4C9)),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.lunch_dining_outlined,
              color: burgerGreen,
              size: 34,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: burgerGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              price,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );
}

class BurgerInlineNotice extends StatelessWidget {
  const BurgerInlineNotice(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    color: burgerBeige,
    child: Text(
      text,
      softWrap: true,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: burgerGreen),
    ),
  );
}

String won(int value) =>
    '${value.toString().replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (_) => ',')}원';

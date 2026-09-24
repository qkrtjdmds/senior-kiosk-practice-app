import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_routes.dart';
import '../../shared/widgets/page_scaffold.dart';

const _sageSurface = Color(0xFFEDF2EA);
const _sageBorder = Color(0xFFBAC9B7);
const _deepGreen = Color(0xFF214C3F);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: '한걸음 디지털',
      showBackButton: false,
      actions: [
        IconButton(
          onPressed: () => context.push(AppRoutes.accessibilitySettings),
          icon: const Icon(Icons.settings_outlined),
          tooltip: '화면 설정',
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
        const SizedBox(width: 8),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '오늘도 천천히 연습해 볼까요?',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          const _HomeMessageCard(),
          const SizedBox(height: 24),
          _HomeFeatureCard(
            title: '카페 키오스크 연습',
            message: '화면을 보며 주문 순서를 연습해요',
            icon: Icons.local_cafe_outlined,
            onPressed: () => context.go(AppRoutes.cafeStart),
          ),
          const SizedBox(height: 14),
          _ProgressCard(onPressed: () => context.go(AppRoutes.progress)),
          const SizedBox(height: 28),
          Text('다른 연습', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          _PracticeGrid(
            items: [
              _PracticeItem(
                title: '병원 접수',
                icon: Icons.local_hospital_outlined,
                onPressed: () => context.go(AppRoutes.hospitalStart),
              ),
              _PracticeItem(
                title: '사진 보내기',
                icon: Icons.photo_outlined,
                onPressed: () => context.go(AppRoutes.photoStart),
              ),
              _PracticeItem(
                title: '기차표 예매',
                icon: Icons.train_outlined,
                onPressed: () => context.go(AppRoutes.trainStart),
              ),
              _PracticeItem(
                title: '햄버거 주문',
                icon: Icons.lunch_dining_outlined,
                onPressed: () => context.go(AppRoutes.hamburgerStart),
              ),
              _PracticeItem(
                title: 'ATM 출금',
                icon: Icons.account_balance_outlined,
                onPressed: () => context.go(AppRoutes.atmStart),
              ),
              _PracticeItem(
                title: '서류 발급',
                icon: Icons.description_outlined,
                onPressed: () => context.go(AppRoutes.civilDocumentStart),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _HomeMessageCard extends StatelessWidget {
  const _HomeMessageCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 82),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: _sageSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _sageBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.eco_outlined, size: 34, color: _deepGreen),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('오늘의 연습', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 3),
                Text(
                  '한 단계씩 따라 해보세요.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeFeatureCard extends StatelessWidget {
  const _HomeFeatureCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 104),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _sageBorder, width: 1.5),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final largeText =
                  MediaQuery.textScalerOf(context).scale(1) > 1.15;
              final compact = constraints.maxWidth < 360 || largeText;
              final details = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: largeText
                          ? 17
                          : compact
                          ? 20
                          : 22,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    message,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _HomeIconBox(icon: icon, size: 48),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 20,
                          color: _deepGreen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    details,
                  ],
                );
              }
              return Row(
                children: [
                  _HomeIconBox(icon: icon, size: 56),
                  const SizedBox(width: 14),
                  Expanded(child: details),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 22,
                    color: _deepGreen,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 88),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _sageBorder),
          ),
          child: Row(
            children: [
              const _HomeIconBox(icon: Icons.emoji_events_outlined, size: 54),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '나의 디지털 걸음',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '기록과 포인트 보기',
                      softWrap: true,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
                color: _deepGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeIconBox extends StatelessWidget {
  const _HomeIconBox({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _sageSurface,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, size: size * 0.56, color: _deepGreen),
    );
  }
}

class _PracticeItem {
  const _PracticeItem({
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPressed;
}

class _PracticeGrid extends StatelessWidget {
  const _PracticeGrid({required this.items});

  final List<_PracticeItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final cardWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: cardWidth,
                child: _CompactPracticeCard(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _CompactPracticeCard extends StatelessWidget {
  const _CompactPracticeCard({required this.item});

  final _PracticeItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: item.onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.fromLTRB(12, 14, 10, 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _sageBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _HomeIconBox(icon: item.icon, size: 46),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 17,
                    color: _deepGreen,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

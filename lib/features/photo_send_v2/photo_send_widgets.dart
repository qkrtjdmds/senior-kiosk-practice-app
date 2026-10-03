import 'package:flutter/material.dart';

import 'photo_send_models.dart';

const photoIvory = Color(0xFFFAF9F4);
const photoNavy = Color(0xFF24364B);
const photoSage = Color(0xFFE5EDE5);
const photoBorder = Color(0xFFD5DAD4);

class PhotoSendScaffold extends StatelessWidget {
  const PhotoSendScaffold({
    super.key,
    required this.child,
    required this.onBack,
    this.step,
    this.bottom,
  });

  final Widget child;
  final VoidCallback onBack;
  final int? step;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) onBack();
    },
    child: Scaffold(
      backgroundColor: photoIvory,
      appBar: AppBar(
        backgroundColor: photoIvory,
        leading: IconButton(
          tooltip: '이전 화면으로 돌아가기',
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('사진 보내기 연습'),
        bottom: step == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(36),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: step! / 10,
                          minHeight: 6,
                          color: photoNavy,
                          backgroundColor: photoSage,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('$step / 10'),
                    ],
                  ),
                ),
              ),
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                decoration: const BoxDecoration(
                  color: photoIvory,
                  border: Border(top: BorderSide(color: photoBorder)),
                ),
                child: bottom,
              ),
            ),
    ),
  );
}

class PhotoInlineNotice extends StatelessWidget {
  const PhotoInlineNotice(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    color: photoSage,
    child: Text(text, softWrap: true),
  );
}

class PhotoChoiceRow extends StatelessWidget {
  const PhotoChoiceRow({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.selected = false,
  });
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: subtitle == null ? title : '$title, $subtitle',
    child: InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? photoSage : Colors.white,
          border: Border(bottom: BorderSide(color: photoBorder)),
        ),
        child: Row(
          children: [
            Icon(icon, color: photoNavy, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle!, softWrap: true),
                  ],
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.chevron_right,
              color: photoNavy,
            ),
          ],
        ),
      ),
    ),
  );
}

class PracticePhotoTile extends StatelessWidget {
  const PracticePhotoTile({
    super.key,
    required this.photo,
    required this.selectionNumber,
    required this.onTap,
    required this.onPreview,
  });
  final PracticePhoto photo;
  final int? selectionNumber;
  final VoidCallback onTap;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selectionNumber != null,
    label: selectionNumber == null
        ? '${photo.name} 사진, 선택되지 않음'
        : '${photo.name} 사진, ${selectionNumber!}번째로 선택됨',
    child: Material(
      color: photo.color,
      child: InkWell(
        onTap: onTap,
        onLongPress: onPreview,
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(photo.icon, size: 46, color: photoNavy),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      photo.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 7,
              right: 7,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: selectionNumber == null
                    ? Colors.white
                    : photoNavy,
                child: selectionNumber == null
                    ? const Icon(Icons.add, size: 20, color: photoNavy)
                    : Text(
                        '$selectionNumber',
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ),
            Positioned(
              left: 4,
              bottom: 4,
              child: IconButton(
                tooltip: '${photo.name} 크게 보기',
                onPressed: onPreview,
                icon: const Icon(Icons.zoom_in),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget photoPrimaryButton(String label, VoidCallback? onPressed) =>
    FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: photoNavy,
        foregroundColor: Colors.white,
        disabledBackgroundColor: photoBorder,
        minimumSize: const Size.fromHeight(58),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      child: Text(label, textAlign: TextAlign.center, softWrap: true),
    );

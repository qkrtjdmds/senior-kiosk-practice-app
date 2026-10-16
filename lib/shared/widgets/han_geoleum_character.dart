import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

enum HanGeoleumMood { welcome, guide, cheer, retry, celebrate, empty, help }

class HanGeoleumCharacter extends StatelessWidget {
  const HanGeoleumCharacter({
    this.mood = HanGeoleumMood.guide,
    this.size = 88,
    this.accessoryIds = const {},
    super.key,
  });
  final HanGeoleumMood mood;
  final double size;
  final Set<String> accessoryIds;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _HanGeoleumPainter(mood, accessoryIds)),
    ),
  );
}

class _HanGeoleumPainter extends CustomPainter {
  const _HanGeoleumPainter(this.mood, this.accessoryIds);
  final HanGeoleumMood mood;
  final Set<String> accessoryIds;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .035
      ..strokeCap = StrokeCap.round;
    final body = Rect.fromCenter(
      center: Offset(size.width * .5, size.height * .56),
      width: size.width * .68,
      height: size.height * .61,
    );
    canvas.drawOval(body, Paint()..color = AppColors.sageContainer);
    canvas.drawOval(body, outline);
    if (accessoryIds.contains('accessory_bag') && size.width >= 64) {
      _drawBag(canvas, size, outline);
    }
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .42, size.height * .12),
        width: size.width * .24,
        height: size.height * .12,
      ),
      Paint()..color = AppColors.sage,
    );
    if (accessoryIds.contains('accessory_hat')) {
      _drawHat(canvas, size, outline);
    }
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .57, size.height * .15),
        width: size.width * .20,
        height: size.height * .10,
      ),
      Paint()..color = AppColors.sage,
    );
    final face = Paint()..color = AppColors.primary;
    canvas.drawCircle(
      Offset(size.width * .39, size.height * .51),
      size.width * .035,
      face,
    );
    if (accessoryIds.contains('accessory_glasses')) {
      _drawGlasses(canvas, size, outline);
    }
    canvas.drawCircle(
      Offset(size.width * .61, size.height * .51),
      size.width * .035,
      face,
    );
    final smile = mood != HanGeoleumMood.retry;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * .41, size.height * .63)
        ..quadraticBezierTo(
          size.width * .5,
          smile ? size.height * .71 : size.height * .60,
          size.width * .59,
          size.height * .63,
        ),
      outline,
    );
    if (mood == HanGeoleumMood.cheer || mood == HanGeoleumMood.celebrate) {
      canvas.drawLine(
        Offset(size.width * .15, size.height * .30),
        Offset(size.width * .05, size.height * .20),
        outline,
      );
      canvas.drawLine(
        Offset(size.width * .85, size.height * .30),
        Offset(size.width * .95, size.height * .20),
        outline,
      );
    }
    if (accessoryIds.contains('accessory_scarf')) {
      _drawScarf(canvas, size, outline);
    }
  }

  void _drawHat(Canvas canvas, Size size, Paint outline) {
    final fill = Paint()..color = const Color(0xFF6E8296);
    final crown = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * .26,
        size.height * .19,
        size.width * .48,
        size.height * .16,
      ),
      Radius.circular(size.width * .07),
    );
    canvas.drawRRect(crown, fill);
    canvas.drawRRect(crown, outline);
    canvas.drawLine(
      Offset(size.width * .20, size.height * .35),
      Offset(size.width * .80, size.height * .35),
      outline,
    );
  }

  void _drawGlasses(Canvas canvas, Size size, Paint outline) {
    final glasses = Paint()
      ..color = const Color(0xFF3D5264)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .026;
    for (final x in [.39, .61]) {
      canvas.drawCircle(
        Offset(size.width * x, size.height * .51),
        size.width * .09,
        glasses,
      );
    }
    canvas.drawLine(
      Offset(size.width * .48, size.height * .51),
      Offset(size.width * .52, size.height * .51),
      glasses,
    );
  }

  void _drawScarf(Canvas canvas, Size size, Paint outline) {
    final scarf = Paint()..color = const Color(0xFFB7836F);
    final band = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * .28,
        size.height * .74,
        size.width * .44,
        size.height * .10,
      ),
      Radius.circular(size.width * .04),
    );
    canvas.drawRRect(band, scarf);
    canvas.drawRRect(band, outline);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .58,
          size.height * .80,
          size.width * .10,
          size.height * .15,
        ),
        Radius.circular(size.width * .025),
      ),
      scarf,
    );
  }

  void _drawBag(Canvas canvas, Size size, Paint outline) {
    final bag = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * .72,
        size.height * .64,
        size.width * .22,
        size.height * .23,
      ),
      Radius.circular(size.width * .04),
    );
    canvas.drawRRect(bag, Paint()..color = const Color(0xFFC99A62));
    canvas.drawRRect(bag, outline);
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * .76,
        size.height * .57,
        size.width * .14,
        size.height * .16,
      ),
      3.3,
      2.7,
      false,
      outline,
    );
  }

  @override
  bool shouldRepaint(_HanGeoleumPainter oldDelegate) =>
      oldDelegate.mood != mood ||
      oldDelegate.accessoryIds.length != accessoryIds.length ||
      !oldDelegate.accessoryIds.containsAll(accessoryIds);
}

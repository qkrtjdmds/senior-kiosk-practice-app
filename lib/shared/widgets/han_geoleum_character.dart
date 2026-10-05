import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

enum HanGeoleumMood { welcome, guide, cheer, retry, celebrate, empty, help }

class HanGeoleumCharacter extends StatelessWidget {
  const HanGeoleumCharacter({
    this.mood = HanGeoleumMood.guide,
    this.size = 88,
    super.key,
  });
  final HanGeoleumMood mood;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _HanGeoleumPainter(mood)),
    ),
  );
}

class _HanGeoleumPainter extends CustomPainter {
  const _HanGeoleumPainter(this.mood);
  final HanGeoleumMood mood;

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
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .42, size.height * .12),
        width: size.width * .24,
        height: size.height * .12,
      ),
      Paint()..color = AppColors.sage,
    );
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
  }

  @override
  bool shouldRepaint(_HanGeoleumPainter oldDelegate) =>
      oldDelegate.mood != mood;
}

class RecentPracticeRecord {
  const RecentPracticeRecord({
    required this.learningName,
    required this.modeName,
    required this.points,
    required this.completedAt,
    this.detail,
  });

  final String learningName;
  final String modeName;
  final int points;
  final DateTime completedAt;
  final String? detail;

  Map<String, Object> toJson() {
    return {
      'learningName': learningName,
      'modeName': modeName,
      'points': points,
      'completedAt': completedAt.toIso8601String(),
      'detail': ?detail,
    };
  }

  factory RecentPracticeRecord.fromJson(Map<String, dynamic> json) {
    return RecentPracticeRecord(
      learningName: json['learningName'] as String? ?? '디지털 연습',
      modeName: json['modeName'] as String? ?? '따라 해보기',
      points: json['points'] as int? ?? 0,
      completedAt:
          DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.now(),
      detail: json['detail'] as String?,
    );
  }
}

String formatRecentPracticeTime(DateTime completedAt, DateTime now) {
  final completedDate = DateTime(
    completedAt.year,
    completedAt.month,
    completedAt.day,
  );
  final today = DateTime(now.year, now.month, now.day);
  final difference = today.difference(completedDate).inDays;
  final period = completedAt.hour < 12 ? '오전' : '오후';
  final hour = completedAt.hour % 12 == 0 ? 12 : completedAt.hour % 12;
  final minute = completedAt.minute.toString().padLeft(2, '0');
  final time = '$period $hour:$minute';

  if (difference == 0) return '오늘 $time';
  if (difference == 1) return '어제 $time';
  return '${completedAt.month}월 ${completedAt.day}일 $time';
}

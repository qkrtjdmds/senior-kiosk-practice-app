import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../learning/learning_progress_provider.dart';
import '../learning/widgets/learning_widgets.dart';
import 'civil_document_mission.dart';

class CivilDocumentPracticePage extends StatefulWidget {
  const CivilDocumentPracticePage({super.key});

  @override
  State<CivilDocumentPracticePage> createState() =>
      _CivilDocumentPracticePageState();
}

class _CivilDocumentPracticePageState extends State<CivilDocumentPracticePage> {
  int _step = 1;
  bool _isCompleting = false;

  Future<void> _restart() async {
    final progress = context.read<LearningProgressProvider>();
    if (progress.isCivilDocumentSoloMode) {
      await progress.startCivilDocumentLearning(CivilDocumentLearningMode.solo);
      if (mounted) setState(() => _step = 1);
      return;
    }
    await progress.startCivilDocumentLearning(CivilDocumentLearningMode.guided);
    if (mounted) setState(() => _step = 1);
  }

  void _previous() {
    if (_step == 1) {
      final progress = context.read<LearningProgressProvider>();
      context.go(
        progress.isCivilDocumentSoloMode
            ? AppRoutes.civilDocumentMission
            : AppRoutes.civilDocumentStart,
      );
      return;
    }
    setState(() => _step -= 1);
  }

  void _finish() {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    context.go(AppRoutes.civilDocumentComplete);
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgressProvider>();
    final isSolo = progress.isCivilDocumentSoloMode;
    final guidance = switch (_step) {
      1 => isSolo ? '오늘 발급할 서류를 선택해보세요.' : '먼저 필요한 서류를 골라볼까요?',
      2 => isSolo ? '오늘의 발급 내용을 선택해보세요.' : '서류에 표시할 내용을 골라볼까요?',
      3 => isSolo ? '오늘 필요한 발급 부수를 선택해보세요.' : '필요한 서류 수를 골라볼까요?',
      4 => '마지막으로 발급 내용을 확인해볼까요?',
      _ => '마지막으로 발급된 서류를 챙겨볼까요?',
    };
    final question = switch (_step) {
      1 => '어떤 서류를 발급하시겠어요?',
      2 => '어떤 내용으로 발급할까요?',
      3 => '몇 부를 발급할까요?',
      4 => '발급 내용을 확인해볼까요?',
      _ => '무엇을 할까요?',
    };

    return LearningStepLayout(
      title: '무인민원발급기 연습',
      step: _step,
      totalSteps: 5,
      customPanel: true,
      guidance: guidance,
      question: question,
      onBack: _previous,
      onPrevious: _previous,
      onRestart: _restart,
      onHint: isSolo ? () => CivilDocumentMission.showHint(context) : null,
      onHome: isSolo ? () => context.go(AppRoutes.home) : null,
      child: _CivilDocumentPanel(child: _buildStep(progress)),
    );
  }

  Widget _buildStep(LearningProgressProvider progress) {
    switch (_step) {
      case 1:
        return Column(
          children: [
            LearningChoiceCard(
              label: '주민등록등본',
              icon: Icons.description_outlined,
              highlighted: !progress.isCivilDocumentSoloMode,
              onPressed: () => setState(() => _step = 2),
            ),
            const SizedBox(height: 14),
            LearningChoiceCard(
              label: '가족관계증명서',
              icon: Icons.groups_outlined,
              secondary: true,
              onPressed: () => _showDocumentGuide(progress),
            ),
            const SizedBox(height: 14),
            LearningChoiceCard(
              label: '건강보험 자격확인서',
              icon: Icons.health_and_safety_outlined,
              secondary: true,
              onPressed: () => _showDocumentGuide(progress),
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            LearningChoiceCard(
              label: progress.isCivilDocumentSoloMode
                  ? '기본 내용'
                  : '기본 내용으로 발급할게요',
              icon: Icons.article_outlined,
              highlighted: !progress.isCivilDocumentSoloMode,
              onPressed: () {
                progress.selectCivilDocumentContent('기본 내용');
                setState(() => _step = 3);
              },
            ),
            const SizedBox(height: 14),
            LearningChoiceCard(
              label: '자세한 내용으로 발급할게요',
              icon: Icons.subject_outlined,
              onPressed: () => _selectContent(progress, '자세한 내용'),
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            LearningChoiceCard(
              label: '한 부',
              icon: Icons.filter_1_outlined,
              highlighted: !progress.isCivilDocumentSoloMode,
              onPressed: () {
                progress.selectCivilDocumentCopies('한 부');
                setState(() => _step = 4);
              },
            ),
            const SizedBox(height: 14),
            LearningChoiceCard(
              label: '두 부',
              icon: Icons.filter_2_outlined,
              onPressed: () => _selectCopies(progress, '두 부'),
            ),
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _IssueSummary(
              content: progress.civilDocumentContent ?? '',
              copies: progress.civilDocumentCopies ?? '',
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () => setState(() => _step = 5),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text(
                progress.isCivilDocumentSoloMode ? '맞아요, 발급할게요' : '발급 확인',
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(72),
              ),
            ),
          ],
        );
      default:
        return LearningChoiceCard(
          label: progress.isCivilDocumentSoloMode ? '서류를 챙겼어요' : '서류를 챙길게요',
          icon: Icons.description_outlined,
          highlighted: !progress.isCivilDocumentSoloMode,
          onPressed: _finish,
        );
    }
  }

  void _selectContent(LearningProgressProvider progress, String content) {
    if (progress.isCivilDocumentSoloMode &&
        content != CivilDocumentMission.content) {
      _showMissionReminder();
      return;
    }
    progress.selectCivilDocumentContent(content);
    setState(() => _step = 3);
  }

  void _selectCopies(LearningProgressProvider progress, String copies) {
    if (progress.isCivilDocumentSoloMode &&
        copies != CivilDocumentMission.copies) {
      _showMissionReminder();
      return;
    }
    progress.selectCivilDocumentCopies(copies);
    setState(() => _step = 4);
  }

  void _showDocumentGuide(LearningProgressProvider progress) {
    if (progress.isCivilDocumentSoloMode) {
      _showMissionReminder();
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('이번 연습에서는 주민등록등본을 발급해볼게요.')));
  }

  void _showMissionReminder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '이번 미션 내용을 다시 살펴볼까요?\n'
          '힌트 보기를 누르면 발급 내용을 확인할 수 있어요.',
        ),
      ),
    );
  }
}

class _CivilDocumentPanel extends StatelessWidget {
  const _CivilDocumentPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.primary, width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.print_outlined, size: 34, color: colors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '연습용 민원발급기 화면',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Icon(Icons.description_outlined),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: child,
          ),
          const SizedBox(height: 14),
          Container(
            height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: colors.onSurface,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueSummary extends StatelessWidget {
  const _IssueSummary({required this.content, required this.copies});

  final String content;
  final String copies;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const _SummaryRow(label: '서류', value: '주민등록등본'),
          _SummaryRow(label: '내용', value: content),
          _SummaryRow(label: '발급 부수', value: copies),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}

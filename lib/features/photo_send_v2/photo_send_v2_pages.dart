import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../daily_mission/daily_mission.dart';
import '../daily_mission/daily_mission_provider.dart';
import '../learning/learning_progress_provider.dart';
import 'photo_send_models.dart';
import 'photo_send_provider.dart';
import 'photo_send_widgets.dart';

class PhotoSendV2StartPage extends StatelessWidget {
  const PhotoSendV2StartPage({super.key});

  @override
  Widget build(BuildContext context) => PhotoSendScaffold(
    onBack: () => context.go(AppRoutes.home),
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
      children: [
        Text('사진 보내기 연습', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 10),
        const Text('가상 메신저에서 받을 사람과 사진을 안전하게 확인해요.'),
        const SizedBox(height: 22),
        const PhotoInlineNotice('실제 연락처나 갤러리를 열지 않고 사진도 전송하지 않아요.'),
        const SizedBox(height: 24),
        photoPrimaryButton('따라 해보기', () {
          context.read<LearningProgressProvider>().selectPhotoMode(
            PhotoLearningMode.guided,
          );
          context.read<PhotoSendProvider>().begin(PhotoSendMode.guided);
          context.go(AppRoutes.photoStepOne);
        }),
        const SizedBox(height: 14),
        const Text('화면의 안내를 보며 하나씩 연습해요.', textAlign: TextAlign.center),
        const SizedBox(height: 22),
        OutlinedButton(
          onPressed: () {
            final progress = context.read<LearningProgressProvider>();
            progress.selectPhotoMode(PhotoLearningMode.solo);
            context.read<PhotoSendProvider>().begin(
              PhotoSendMode.solo,
              completedCount: progress.photoSoloCompletionCount,
            );
            context.go(AppRoutes.photoMission);
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(58),
          ),
          child: const Text('혼자 해보기'),
        ),
        const SizedBox(height: 14),
        const Text('오늘의 목표를 기억하고 직접 사진을 골라봐요.', textAlign: TextAlign.center),
      ],
    ),
  );
}

class PhotoSendV2MissionPage extends StatefulWidget {
  const PhotoSendV2MissionPage({super.key});
  @override
  State<PhotoSendV2MissionPage> createState() => _PhotoSendV2MissionPageState();
}

class _PhotoSendV2MissionPageState extends State<PhotoSendV2MissionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final progress = context.read<LearningProgressProvider>();
      context.read<PhotoSendProvider>().begin(
        PhotoSendMode.solo,
        completedCount: progress.photoSoloCompletionCount,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PhotoSendProvider>();
    return PhotoSendScaffold(
      onBack: () {
        context.read<DailyMissionProvider>().cancelActiveMission();
        context.go(AppRoutes.photoStart);
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '오늘의 사진 보내기 목표',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 18),
          PhotoInlineNotice(p.scenario.title),
          const SizedBox(height: 14),
          Text('받는 사람: ${contactById(p.scenario.contactId).name}'),
          Text('앨범: ${p.scenario.album}'),
          Text(
            '사진: ${p.scenario.photoIds.map((id) => photoById(id).name).join(' → ')}',
          ),
          const SizedBox(height: 24),
          photoPrimaryButton('혼자 사진 보내기', () {
            final daily = context.read<DailyMissionProvider>();
            if (daily.activeMissionId != 'photo_solo_complete') {
              context.read<LearningProgressProvider>().selectPhotoMode(
                PhotoLearningMode.solo,
              );
            }
            context.go(AppRoutes.photoStepOne);
          }),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: p.toggleHint,
            child: Text(p.hintVisible ? '힌트 닫기' : '힌트 보기'),
          ),
          if (p.hintVisible) ...[
            const SizedBox(height: 10),
            const PhotoInlineNotice(
              '받는 사람 → 사진 버튼 → 앨범 → 사진 → 미리보기 → 보내기 순서예요.',
            ),
          ],
        ],
      ),
    );
  }
}

class PhotoSendV2FlowPage extends StatelessWidget {
  const PhotoSendV2FlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PhotoSendProvider>();
    return PhotoSendScaffold(
      step: p.step.index + 1,
      modeLabel: practiceSessionLabel(
        isFreePractice: p.isFreePractice,
        isSolo: p.isSolo,
      ),
      onBack: () => _back(context, p),
      bottom: _bottom(context, p),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        children: [
          Text(
            _question(p.step),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            p.isFreePractice
                ? '보낼 사람과 사진을 자유롭게 골라보세요.'
                : p.isSolo
                ? '미션을 기억하고 직접 골라보세요.'
                : '화면 안내를 보며 천천히 선택해 보세요.',
          ),
          if (p.notice != null) ...[
            const SizedBox(height: 12),
            PhotoInlineNotice(p.notice!),
          ],
          if (p.isSolo && p.hintVisible) ...[
            const SizedBox(height: 12),
            PhotoInlineNotice('힌트: ${p.scenario.title}'),
          ],
          const SizedBox(height: 20),
          ..._content(context, p),
        ],
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    PhotoSendProvider p,
  ) => switch (p.step) {
    PhotoSendStep.recipient => [
      for (final contact in practiceContacts)
        PhotoChoiceRow(
          title: contact.name,
          subtitle: '${contact.relation} · ${contact.lastMessage}',
          icon: contact.isGroup ? Icons.groups_outlined : Icons.person_outline,
          selected: p.recipient?.id == contact.id,
          onTap: () => p.chooseRecipient(contact),
        ),
    ],
    PhotoSendStep.chat => [
      _chatPreview(context, p),
      const SizedBox(height: 14),
      const PhotoInlineNotice('상단의 이름이 보내려는 사람과 같은지 확인해 주세요.'),
    ],
    PhotoSendStep.addPhoto => [
      _chatPreview(context, p),
      const SizedBox(height: 18),
      PhotoChoiceRow(
        title: '사진 추가 버튼',
        subtitle: '연습용 앨범을 열어요.',
        icon: Icons.add_photo_alternate_outlined,
        onTap: p.openAddPhoto,
      ),
    ],
    PhotoSendStep.permission => [
      const PhotoInlineNotice('실제 권한을 요청하지 않는 교육 화면이에요. 필요한 사진만 허용할 수도 있어요.'),
      const SizedBox(height: 12),
      PhotoChoiceRow(
        title: '선택한 사진만 허용',
        subtitle: '고른 사진만 앱에서 볼 수 있어요.',
        icon: Icons.photo_library_outlined,
        selected: p.permission == PhotoPermissionChoice.selectedOnly,
        onTap: () => p.choosePermission(PhotoPermissionChoice.selectedOnly),
      ),
      PhotoChoiceRow(
        title: '모든 사진 허용',
        subtitle: '필요하지 않다면 선택하지 않아도 돼요.',
        icon: Icons.collections_outlined,
        selected: p.permission == PhotoPermissionChoice.allPhotos,
        onTap: () => p.choosePermission(PhotoPermissionChoice.allPhotos),
      ),
      PhotoChoiceRow(
        title: '허용하지 않음',
        subtitle: '설정에서 나중에 바꿀 수 있어요.',
        icon: Icons.block_outlined,
        selected: p.permission == PhotoPermissionChoice.denied,
        onTap: () => p.choosePermission(PhotoPermissionChoice.denied),
      ),
    ],
    PhotoSendStep.album => [
      for (final album in practiceAlbums)
        PhotoChoiceRow(
          title: album,
          subtitle: '${p.photosForAlbum(album).length}개의 연습용 사진',
          icon: Icons.photo_album_outlined,
          selected: p.album == album,
          onTap: () => p.chooseAlbum(album),
        ),
    ],
    PhotoSendStep.photos => [
      Semantics(
        liveRegion: true,
        child: Text('선택한 사진 ${p.selectedPhotoIds.length}장 · 최대 3장'),
      ),
      const SizedBox(height: 12),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemCount: p.photosForAlbum(p.album!).length,
        itemBuilder: (context, index) {
          final photo = p.photosForAlbum(p.album!)[index];
          final selected = p.selectedPhotoIds.indexOf(photo.id);
          return PracticePhotoTile(
            photo: photo,
            selectionNumber: selected < 0 ? null : selected + 1,
            onTap: () => p.togglePhoto(photo.id),
            onPreview: () => _showPhoto(context, photo),
          );
        },
      ),
      const SizedBox(height: 10),
      const Text('돋보기 버튼이나 길게 누르기로 크게 볼 수 있어요.'),
    ],
    PhotoSendStep.preview => [
      for (final photo in p.selectedPhotos) ...[
        _largePhoto(photo),
        const SizedBox(height: 12),
      ],
    ],
    PhotoSendStep.review => [
      const PhotoInlineNotice('누구에게 보내는지 다시 확인해 주세요.'),
      const SizedBox(height: 14),
      _summary(context, p),
      if (p.recipient!.isGroup) ...[
        const SizedBox(height: 12),
        const PhotoInlineNotice('단체 채팅에서는 여러 사람이 사진을 볼 수 있어요.'),
      ],
      const SizedBox(height: 16),
      OutlinedButton(
        onPressed: () => p.goTo(PhotoSendStep.photos),
        child: const Text('사진 다시 선택'),
      ),
      OutlinedButton(
        onPressed: () => p.goTo(PhotoSendStep.recipient),
        child: const Text('받는 사람 다시 선택'),
      ),
    ],
    PhotoSendStep.sending => [
      const Center(child: CircularProgressIndicator()),
      const SizedBox(height: 20),
      const Text('연습용 사진을 보내는 중이에요.', textAlign: TextAlign.center),
      const Text('실제 파일이나 네트워크는 사용하지 않아요.', textAlign: TextAlign.center),
    ],
    PhotoSendStep.result => [
      _chatPreview(context, p, showPhotos: true),
      const SizedBox(height: 16),
      const PhotoInlineNotice('가상 전송이 완료됐어요. 실제 사진은 전송되지 않았어요.'),
      const SizedBox(height: 16),
      OutlinedButton(
        onPressed: p.toggleSafety,
        child: Text(p.safetyExpanded ? '안전 안내 닫기' : '잘못 보냈을 때 어떻게 하나요?'),
      ),
      if (p.safetyExpanded) ...[
        const SizedBox(height: 10),
        const PhotoInlineNotice(
          '받는 사람을 먼저 확인하세요. 메신저마다 내 화면에서 삭제와 모두에게서 삭제가 다를 수 있어요. 개인정보·금융정보·신분증·비밀번호 사진은 보내지 마세요.',
        ),
      ],
    ],
  };

  Widget? _bottom(BuildContext context, PhotoSendProvider p) {
    final hint = p.isSolo && p.step != PhotoSendStep.sending
        ? TextButton.icon(
            onPressed: p.toggleHint,
            icon: const Icon(Icons.lightbulb_outline),
            label: Text(p.hintVisible ? '힌트 닫기' : '힌트 보기'),
          )
        : null;
    VoidCallback? action;
    String label = '다음으로';
    switch (p.step) {
      case PhotoSendStep.recipient:
      case PhotoSendStep.addPhoto:
      case PhotoSendStep.permission:
      case PhotoSendStep.album:
      case PhotoSendStep.sending:
        action = null;
      case PhotoSendStep.chat:
        action = p.confirmChat;
        label = '이 채팅방이 맞아요';
      case PhotoSendStep.photos:
        action = p.selectedPhotoIds.isEmpty ? null : p.finishPhotoSelection;
        label = '선택한 사진 미리보기';
      case PhotoSendStep.preview:
        action = p.confirmPreview;
        label = '받는 사람과 사진 확인';
      case PhotoSendStep.review:
        action = () async {
          if (p.confirmReview()) await p.sendVirtually();
        };
        label = '보내기';
      case PhotoSendStep.result:
        action = () {
          p.confirmResult();
          if (p.canComplete) context.go(AppRoutes.photoComplete);
        };
        label = '연습 완료하기';
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [?hint, photoPrimaryButton(label, action)],
    );
  }

  void _back(BuildContext context, PhotoSendProvider p) {
    if (p.sending) {
      p.showNotice('전송 연습이 끝날 때까지 잠시 기다려 주세요.');
      return;
    }
    if (p.step == PhotoSendStep.recipient) {
      context.read<DailyMissionProvider>().cancelActiveMission();
      context.go(AppRoutes.photoStart);
      return;
    }
    p.goTo(PhotoSendStep.values[p.step.index - 1]);
  }

  String _question(PhotoSendStep step) => switch (step) {
    PhotoSendStep.recipient => '누구에게 사진을 보낼까요?',
    PhotoSendStep.chat => '채팅방의 이름을 확인해 볼까요?',
    PhotoSendStep.addPhoto => '사진 추가 버튼을 찾아볼까요?',
    PhotoSendStep.permission => '사진 접근 범위를 골라볼까요?',
    PhotoSendStep.album => '사진이 있는 앨범을 골라볼까요?',
    PhotoSendStep.photos => '보낼 사진을 순서대로 골라보세요.',
    PhotoSendStep.preview => '선택한 사진을 크게 확인해 볼까요?',
    PhotoSendStep.review => '보내기 전에 마지막으로 확인해요.',
    PhotoSendStep.sending => '가상 전송 중이에요.',
    PhotoSendStep.result => '사진이 채팅방에 표시됐어요.',
  };

  Widget _chatPreview(
    BuildContext context,
    PhotoSendProvider p, {
    bool showPhotos = false,
  }) => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.account_circle_outlined, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                p.recipient!.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        const Divider(height: 26),
        Text(p.recipient!.lastMessage),
        if (showPhotos) ...[
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: photoSage,
              child: Text('가상 사진 ${p.selectedPhotoIds.length}장을 보냈어요.'),
            ),
          ),
        ],
        const SizedBox(height: 22),
        const Divider(),
        const Row(
          children: [
            Icon(Icons.add_photo_alternate_outlined),
            SizedBox(width: 12),
            Expanded(child: Text('메시지 입력 영역')),
            Icon(Icons.send_outlined),
          ],
        ),
      ],
    ),
  );

  Widget _summary(BuildContext context, PhotoSendProvider p) => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(p.recipient!.name, style: Theme.of(context).textTheme.titleLarge),
        Text(p.recipient!.relation),
        const Divider(height: 26),
        Text('사진 ${p.selectedPhotoIds.length}장'),
        Text(p.selectedPhotos.map((item) => item.name).join(' · ')),
        const SizedBox(height: 12),
        const Text('실제 전송이 아닌 연습 화면입니다.'),
      ],
    ),
  );

  Widget _largePhoto(PracticePhoto photo) => Container(
    height: 220,
    color: photo.color,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(photo.icon, size: 88, color: photoNavy),
        Text(photo.name),
      ],
    ),
  );

  void _showPhoto(BuildContext context, PracticePhoto photo) =>
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('${photo.name} 크게 보기'),
          content: SizedBox(height: 220, child: _largePhoto(photo)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('사진 목록으로'),
            ),
          ],
        ),
      );
}

class PhotoSendV2CompletePage extends StatefulWidget {
  const PhotoSendV2CompletePage({super.key});
  @override
  State<PhotoSendV2CompletePage> createState() =>
      _PhotoSendV2CompletePageState();
}

class _PhotoSendV2CompletePageState extends State<PhotoSendV2CompletePage> {
  bool _awarded = false;
  bool _badge = false;
  bool _daily = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _award());
  }

  Future<void> _award() async {
    if (_awarded || !mounted) return;
    final p = context.read<PhotoSendProvider>();
    if (!p.canComplete) {
      context.go(AppRoutes.photoStart);
      return;
    }
    _awarded = true;
    if (p.isFreePractice) {
      if (mounted) setState(() {});
      return;
    }
    final progress = context.read<LearningProgressProvider>();
    if (p.isSolo) {
      final before = progress.photoSoloCompletionCount;
      final badge = await progress.completePhotoSoloLearning();
      var daily = false;
      if (progress.photoSoloCompletionCount > before && mounted) {
        daily = await context
            .read<DailyMissionProvider>()
            .completeActiveMission(MissionContentType.photo);
      }
      if (mounted) {
        setState(() {
          _badge = badge;
          _daily = daily;
        });
      }
    } else {
      await progress.completePhotoLearning();
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PhotoSendProvider>();
    return PhotoSendScaffold(
      onBack: () => context.go(AppRoutes.home),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PracticeCompletionHeader(
            title: p.isFreePractice ? '자유 연습을 마쳤어요' : '사진 보내기 연습 완료',
            description: '실제 사진이 전송된 것은 아니에요.',
            modeLabel: practiceSessionLabel(
              isFreePractice: p.isFreePractice,
              isSolo: p.isSolo,
              dailyMission: _daily,
            ),
          ),
          const SizedBox(height: 20),
          _completionSummary(context, p),
          const SizedBox(height: 14),
          PhotoInlineNotice(
            p.isFreePractice
                ? '보상 없이 자유롭게 반복할 수 있는 연습이에요.'
                : p.isSolo
                ? '용기 포인트 +20점${_daily ? ' · 오늘의 미션 +10점' : ''}'
                : '한걸음 포인트 +10점',
          ),
          if (_badge) ...[
            const SizedBox(height: 10),
            const PhotoInlineNotice('새 배지: 혼자 사진 보내기 첫걸음'),
          ],
          const SizedBox(height: 14),
          const Text('실제 사진은 전송되지 않았고 연락처와 갤러리도 사용하지 않았어요.'),
          const SizedBox(height: 24),
          photoPrimaryButton('다시 연습하기', () => _restart(context, p.mode)),
          OutlinedButton(
            onPressed: () => _restart(context, p.mode),
            child: const Text('다른 사진 보내기'),
          ),
          OutlinedButton(
            onPressed: () => context.go(AppRoutes.practice),
            child: const Text('다른 학습 보기'),
          ),
          OutlinedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('홈으로'),
          ),
        ],
      ),
    );
  }

  Widget _completionSummary(BuildContext context, PhotoSendProvider p) =>
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              p.recipient?.name ?? '연습 결과를 준비하고 있어요.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (p.recipient != null)
              Text(p.recipient!.isGroup ? '단체 채팅' : '개인 채팅'),
            const Divider(height: 24),
            Text('사진 ${p.selectedPhotoIds.length}장'),
            Text(p.selectedPhotos.map((item) => item.name).join(' · ')),
          ],
        ),
      );

  void _restart(BuildContext context, PhotoSendMode mode) {
    final progress = context.read<LearningProgressProvider>();
    progress.resetPhotoLearning();
    final provider = context.read<PhotoSendProvider>();
    final wasFree = provider.isFreePractice;
    if (wasFree) {
      provider.beginFreePractice();
    } else {
      provider.begin(mode, completedCount: progress.photoSoloCompletionCount);
    }
    context.go(
      !wasFree && mode == PhotoSendMode.solo
          ? AppRoutes.photoMission
          : AppRoutes.photoStepOne,
    );
  }
}

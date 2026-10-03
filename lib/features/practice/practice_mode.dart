enum PracticeMode { free, guided, solo }

extension PracticeModeLabel on PracticeMode {
  String get label => switch (this) {
    PracticeMode.free => '자유 연습',
    PracticeMode.guided => '따라 해보기',
    PracticeMode.solo => '혼자 해보기',
  };
}

abstract final class V2PreferenceKeys {
  static const onboardingCompleted = 'onboarding_completed_v1';
  static const accessibilityTextSize = 'accessibility_text_size';
  static const screenContrast = 'screen_contrast';

  static const cafeLegacyCompletionCount = 'cafe_learning_completion_count';
  static const cafeGuidedCompletionCount = 'cafe_guided_completion_count';
  static const cafeSoloCompletionCount = 'cafe_solo_completion_count';
  static const points = 'digital_confidence_points';
  static const dailyMissionRewardTokens = 'daily_mission_reward_tokens';
  static const cafeSoloFirstBadge = 'cafe_solo_first_badge_earned';
  static const cafeFamiliarBadge = 'cafe_familiar_badge_earned';
  static const cafeMode = 'cafe_learning_mode';
  static const cafeGuidedSessionAwarded = 'cafe_guided_session_awarded';
  static const cafeSoloSessionAwarded = 'cafe_solo_session_awarded';

  static const hospitalGuidedCompletionCount =
      'hospital_guided_completion_count';
  static const hospitalSoloCompletionCount = 'hospital_solo_completion_count';
  static const hospitalSoloFirstBadge = 'hospital_solo_first_badge_earned';
  static const hospitalMode = 'hospital_learning_mode';
  static const hospitalGuidedSessionAwarded = 'hospital_guided_session_awarded';
  static const hospitalSoloSessionAwarded = 'hospital_solo_session_awarded';
  static const hospitalReservationGuidedCompletionCount =
      'hospital_reservation_guided_completion_count';
  static const hospitalReservationSoloCompletionCount =
      'hospital_reservation_solo_completion_count';
  static const hospitalReservationGuidedSessionAwarded =
      'hospital_reservation_guided_session_awarded';
  static const hospitalReservationSoloSessionAwarded =
      'hospital_reservation_solo_session_awarded';
  static const hospitalPaymentGuidedCompletionCount =
      'hospital_payment_guided_completion_count';
  static const hospitalPaymentSoloCompletionCount =
      'hospital_payment_solo_completion_count';
  static const hospitalPaymentGuidedSessionAwarded =
      'hospital_payment_guided_session_awarded';
  static const hospitalPaymentSoloSessionAwarded =
      'hospital_payment_solo_session_awarded';
  static const hospitalDocumentGuidedCompletionCount =
      'hospital_document_guided_completion_count';
  static const hospitalDocumentSoloCompletionCount =
      'hospital_document_solo_completion_count';
  static const hospitalDocumentGuidedSessionAwarded =
      'hospital_document_guided_session_awarded';
  static const hospitalDocumentSoloSessionAwarded =
      'hospital_document_solo_session_awarded';

  static const photoGuidedCompletionCount = 'photo_guided_completion_count';
  static const photoSoloCompletionCount = 'photo_solo_completion_count';
  static const photoSoloFirstBadge = 'photo_solo_first_badge_earned';
  static const photoMode = 'photo_learning_mode';
  static const photoGuidedSessionAwarded = 'photo_guided_session_awarded';
  static const photoSoloSessionAwarded = 'photo_solo_session_awarded';

  static const trainGuidedCompletionCount = 'train_guided_completion_count';
  static const trainSoloCompletionCount = 'train_solo_completion_count';
  static const trainSoloFirstBadge = 'train_solo_first_badge_earned';
  static const trainMode = 'train_learning_mode';
  static const trainGuidedSessionAwarded = 'train_guided_session_awarded';
  static const trainSoloSessionAwarded = 'train_solo_session_awarded';

  static const recentPracticeRecords = 'recent_practice_records';

  static const hamburgerGuidedCompletionCount =
      'hamburger_guided_completion_count';
  static const hamburgerSoloCompletionCount = 'hamburger_solo_completion_count';
  static const hamburgerSoloFirstBadge = 'hamburger_solo_first_badge_earned';
  static const hamburgerMode = 'hamburger_learning_mode';
  static const hamburgerCurrentMission = 'hamburger_current_mission_id';
  static const hamburgerLastMission = 'hamburger_last_mission_id';
  static const hamburgerSoloSessionAwarded = 'hamburger_solo_session_awarded';
  static const hamburgerGuidedSessionAwarded =
      'hamburger_guided_session_awarded';

  static const atmGuidedCompletionCount = 'atm_guided_completion_count';
  static const atmGuidedSessionAwarded = 'atm_guided_session_awarded';
  static const atmSoloCompletionCount = 'atm_solo_completion_count';
  static const atmSoloFirstBadge = 'atm_solo_first_badge_earned';
  static const atmSoloSessionAwarded = 'atm_solo_session_awarded';
  static const atmMode = 'atm_learning_mode';

  static const civilDocumentGuidedCompletionCount =
      'civil_document_guided_completion_count';
  static const civilDocumentGuidedSessionAwarded =
      'civil_document_guided_session_awarded';
  static const civilDocumentSoloCompletionCount =
      'civil_document_solo_completion_count';
  static const civilDocumentSoloFirstBadge =
      'civil_document_solo_first_badge_earned';
  static const civilDocumentSoloSessionAwarded =
      'civil_document_solo_session_awarded';
  static const civilDocumentMode = 'civil_document_learning_mode';

  static const dailyMissionDate = 'daily_mission_date';
  static const dailyMissionSelectedIds = 'daily_mission_selected_ids';
  static const dailyMissionCompletedIds = 'daily_mission_completed_ids';
  static const dailyMissionRewardedIds = 'daily_mission_rewarded_ids';
  static const dailyMissionCompletedAt = 'daily_mission_completed_at';
  static const dailyMissionPreviousIds = 'daily_mission_previous_ids';
  static const dailyMissionFrequency = 'daily_mission_frequency';
  static const dailyMissionActiveId = 'daily_mission_active_id';

  static const knownDailyMissionIds = <String>{
    'cafe_solo_complete',
    'hamburger_solo_complete',
    'hospital_solo_complete',
    'train_solo_complete',
    'atm_solo_complete',
    'civil_document_solo_complete',
    'photo_solo_complete',
  };

  static const nonNegativeIntegerKeys = <String>{
    cafeLegacyCompletionCount,
    cafeGuidedCompletionCount,
    cafeSoloCompletionCount,
    points,
    hospitalGuidedCompletionCount,
    hospitalSoloCompletionCount,
    hospitalReservationGuidedCompletionCount,
    hospitalReservationSoloCompletionCount,
    hospitalPaymentGuidedCompletionCount,
    hospitalPaymentSoloCompletionCount,
    hospitalDocumentGuidedCompletionCount,
    hospitalDocumentSoloCompletionCount,
    photoGuidedCompletionCount,
    photoSoloCompletionCount,
    trainGuidedCompletionCount,
    trainSoloCompletionCount,
    hamburgerGuidedCompletionCount,
    hamburgerSoloCompletionCount,
    atmGuidedCompletionCount,
    atmSoloCompletionCount,
    civilDocumentGuidedCompletionCount,
    civilDocumentSoloCompletionCount,
  };

  static const booleanKeys = <String>{
    onboardingCompleted,
    cafeSoloFirstBadge,
    cafeFamiliarBadge,
    cafeGuidedSessionAwarded,
    cafeSoloSessionAwarded,
    hospitalSoloFirstBadge,
    hospitalGuidedSessionAwarded,
    hospitalSoloSessionAwarded,
    hospitalReservationGuidedSessionAwarded,
    hospitalReservationSoloSessionAwarded,
    hospitalPaymentGuidedSessionAwarded,
    hospitalPaymentSoloSessionAwarded,
    hospitalDocumentGuidedSessionAwarded,
    hospitalDocumentSoloSessionAwarded,
    photoSoloFirstBadge,
    photoGuidedSessionAwarded,
    photoSoloSessionAwarded,
    trainSoloFirstBadge,
    trainGuidedSessionAwarded,
    trainSoloSessionAwarded,
    hamburgerSoloFirstBadge,
    hamburgerSoloSessionAwarded,
    hamburgerGuidedSessionAwarded,
    atmGuidedSessionAwarded,
    atmSoloFirstBadge,
    atmSoloSessionAwarded,
    civilDocumentGuidedSessionAwarded,
    civilDocumentSoloFirstBadge,
    civilDocumentSoloSessionAwarded,
  };

  static const modeKeys = <String>{
    cafeMode,
    hospitalMode,
    photoMode,
    trainMode,
    hamburgerMode,
    atmMode,
    civilDocumentMode,
  };

  static const practiceRecordKeys = <String>{
    ...nonNegativeIntegerKeys,
    dailyMissionRewardTokens,
    cafeSoloFirstBadge,
    cafeFamiliarBadge,
    cafeMode,
    cafeGuidedSessionAwarded,
    cafeSoloSessionAwarded,
    hospitalSoloFirstBadge,
    hospitalMode,
    hospitalGuidedSessionAwarded,
    hospitalSoloSessionAwarded,
    hospitalReservationGuidedSessionAwarded,
    hospitalReservationSoloSessionAwarded,
    hospitalPaymentGuidedSessionAwarded,
    hospitalPaymentSoloSessionAwarded,
    hospitalDocumentGuidedSessionAwarded,
    hospitalDocumentSoloSessionAwarded,
    photoSoloFirstBadge,
    photoMode,
    photoGuidedSessionAwarded,
    photoSoloSessionAwarded,
    trainSoloFirstBadge,
    trainMode,
    trainGuidedSessionAwarded,
    trainSoloSessionAwarded,
    recentPracticeRecords,
    hamburgerSoloFirstBadge,
    hamburgerMode,
    hamburgerCurrentMission,
    hamburgerLastMission,
    hamburgerSoloSessionAwarded,
    hamburgerGuidedSessionAwarded,
    atmGuidedSessionAwarded,
    atmSoloFirstBadge,
    atmSoloSessionAwarded,
    atmMode,
    civilDocumentGuidedSessionAwarded,
    civilDocumentSoloFirstBadge,
    civilDocumentSoloSessionAwarded,
    civilDocumentMode,
  };

  static const dailyMissionKeys = <String>{
    dailyMissionDate,
    dailyMissionSelectedIds,
    dailyMissionCompletedIds,
    dailyMissionRewardedIds,
    dailyMissionCompletedAt,
    dailyMissionPreviousIds,
    dailyMissionFrequency,
    dailyMissionActiveId,
  };
}

abstract final class V3DataKeys {
  static const schemaVersion = 'v3_data_schema_version';
  static const pendingRevision = 'v3_migration_pending_revision';
  static const completedRevisions = 'v3_migration_completed_revisions';
  static const lastSuccessRevision = 'v3_migration_last_success_revision';
  static const lastOutcome = 'v3_migration_last_outcome';
}

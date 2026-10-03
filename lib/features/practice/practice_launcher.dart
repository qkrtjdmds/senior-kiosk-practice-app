import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../daily_mission/daily_mission_provider.dart';
import 'practice_registry.dart';

enum PracticeContent {
  cafe,
  hamburger,
  hospital,
  photo,
  train,
  atm,
  civilDocument,
}

abstract final class PracticeLauncher {
  static void startFree(BuildContext context, PracticeContent content) {
    context.read<DailyMissionProvider>().cancelActiveMission();
    final route = switch (content) {
      PracticeContent.cafe => _startCafe(),
      PracticeContent.hamburger => _startHamburger(),
      PracticeContent.hospital => _startHospital(),
      PracticeContent.photo => _startPhoto(),
      PracticeContent.train => _startTrain(),
      PracticeContent.atm => _startAtm(),
      PracticeContent.civilDocument => _startCivilDocument(),
    };
    context.go(route);
  }

  static String _startCafe() {
    cafeOrderProvider.startFreePractice();
    return AppRoutes.cafeV2Menu;
  }

  static String _startHamburger() {
    burgerOrderProvider.beginFreePractice();
    return AppRoutes.hamburgerPractice;
  }

  static String _startHospital() {
    hospitalReceptionProvider.beginFreePractice();
    hospitalReservationProvider.beginFreePractice();
    hospitalPaymentProvider.beginFreePractice();
    hospitalDocumentProvider.beginFreePractice();
    return AppRoutes.hospitalStepOne;
  }

  static String _startPhoto() {
    photoSendProvider.beginFreePractice();
    return AppRoutes.photoStepOne;
  }

  static String _startTrain() {
    trainBookingProvider.beginFreePractice();
    return AppRoutes.trainV2TripType;
  }

  static String _startAtm() {
    atmWithdrawalProvider.beginFreePractice();
    return AppRoutes.atmV2Services;
  }

  static String _startCivilDocument() {
    civilDocumentV2Provider.beginFreePractice();
    return AppRoutes.civilDocumentV2Categories;
  }
}

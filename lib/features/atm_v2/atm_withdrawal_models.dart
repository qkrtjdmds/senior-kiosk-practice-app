import 'package:flutter/material.dart';

enum AtmV2Step {
  services,
  transaction,
  card,
  pin,
  account,
  amount,
  review,
  processing,
  cardReturn,
  cashReturn,
  receipt,
  complete,
}

enum AtmAccountType { checking, living }

enum AtmReceiptChoice { receive, skip }

class AtmPracticeAccount {
  const AtmPracticeAccount({
    required this.type,
    required this.name,
    required this.practiceName,
    required this.balance,
  });

  final AtmAccountType type;
  final String name;
  final String practiceName;
  final int balance;
}

class AtmSoloScenario {
  const AtmSoloScenario({
    required this.title,
    required this.account,
    required this.amount,
    required this.fee,
    required this.receipt,
  });

  final String title;
  final AtmAccountType account;
  final int amount;
  final int fee;
  final AtmReceiptChoice receipt;
}

const atmPracticeAccounts = <AtmPracticeAccount>[
  AtmPracticeAccount(
    type: AtmAccountType.checking,
    name: '입출금 계좌',
    practiceName: '연습용 계좌 1',
    balance: 850000,
  ),
  AtmPracticeAccount(
    type: AtmAccountType.living,
    name: '생활비 계좌',
    practiceName: '연습용 계좌 2',
    balance: 320000,
  ),
];

const guidedAtmScenario = AtmSoloScenario(
  title: '5만 원 출금 연습',
  account: AtmAccountType.checking,
  amount: 50000,
  fee: 0,
  receipt: AtmReceiptChoice.skip,
);

const soloAtmScenarios = <AtmSoloScenario>[
  AtmSoloScenario(
    title: '입출금 계좌에서 3만 원 찾기',
    account: AtmAccountType.checking,
    amount: 30000,
    fee: 0,
    receipt: AtmReceiptChoice.skip,
  ),
  AtmSoloScenario(
    title: '생활비 계좌에서 10만 원 찾기',
    account: AtmAccountType.living,
    amount: 100000,
    fee: 1000,
    receipt: AtmReceiptChoice.receive,
  ),
  AtmSoloScenario(
    title: '입출금 계좌에서 20만 원 찾기',
    account: AtmAccountType.checking,
    amount: 200000,
    fee: 0,
    receipt: AtmReceiptChoice.receive,
  ),
];

String formatAtmWon(int value) {
  final digits = value.toString();
  final result = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) result.write(',');
    result.write(digits[index]);
  }
  return '${result.toString()}원';
}

IconData atmStepIcon(AtmV2Step step) => switch (step) {
  AtmV2Step.services || AtmV2Step.transaction => Icons.account_balance_outlined,
  AtmV2Step.card || AtmV2Step.cardReturn => Icons.credit_card_outlined,
  AtmV2Step.pin => Icons.password_outlined,
  AtmV2Step.account => Icons.account_balance_wallet_outlined,
  AtmV2Step.amount || AtmV2Step.cashReturn => Icons.payments_outlined,
  AtmV2Step.review => Icons.receipt_long_outlined,
  AtmV2Step.processing => Icons.sync,
  AtmV2Step.receipt => Icons.description_outlined,
  AtmV2Step.complete => Icons.check_circle_outline,
};

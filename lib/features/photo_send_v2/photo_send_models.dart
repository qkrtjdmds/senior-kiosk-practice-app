import 'package:flutter/material.dart';

enum PhotoSendMode { guided, solo }

enum PhotoSendStep {
  recipient,
  chat,
  addPhoto,
  permission,
  album,
  photos,
  preview,
  review,
  sending,
  result,
}

enum PhotoPermissionChoice { selectedOnly, allPhotos, denied }

class PracticeContact {
  const PracticeContact({
    required this.id,
    required this.name,
    required this.relation,
    required this.lastMessage,
    this.isGroup = false,
  });

  final String id;
  final String name;
  final String relation;
  final String lastMessage;
  final bool isGroup;
}

class PracticePhoto {
  const PracticePhoto({
    required this.id,
    required this.name,
    required this.album,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final String album;
  final IconData icon;
  final Color color;
}

class PhotoSendScenario {
  const PhotoSendScenario({
    required this.title,
    required this.contactId,
    required this.album,
    required this.photoIds,
  });

  final String title;
  final String contactId;
  final String album;
  final List<String> photoIds;
}

const practiceContacts = <PracticeContact>[
  PracticeContact(
    id: 'daughter',
    name: '딸 김하늘',
    relation: '딸 · 개인 채팅',
    lastMessage: '오늘도 잘 지내고 있어요.',
  ),
  PracticeContact(
    id: 'son',
    name: '아들 김바다',
    relation: '아들 · 개인 채팅',
    lastMessage: '주말에 전화드릴게요.',
  ),
  PracticeContact(
    id: 'neighbor',
    name: '친구 이웃님',
    relation: '친구 · 개인 채팅',
    lastMessage: '사진 고마워요.',
  ),
  PracticeContact(
    id: 'family',
    name: '가족 모임',
    relation: '가족 · 단체 채팅',
    lastMessage: '다음 모임에서 만나요.',
    isGroup: true,
  ),
];

const practiceAlbums = ['최근 사진', '가족 나들이', '음식', '꽃과 풍경'];

const practicePhotos = <PracticePhoto>[
  PracticePhoto(
    id: 'red_flower',
    name: '빨간 꽃',
    album: '꽃과 풍경',
    icon: Icons.local_florist_outlined,
    color: Color(0xFFE7B7B2),
  ),
  PracticePhoto(
    id: 'yellow_flower',
    name: '노란 꽃',
    album: '꽃과 풍경',
    icon: Icons.local_florist,
    color: Color(0xFFE9DCA4),
  ),
  PracticePhoto(
    id: 'beach',
    name: '바닷가',
    album: '가족 나들이',
    icon: Icons.beach_access_outlined,
    color: Color(0xFFB8D4DB),
  ),
  PracticePhoto(
    id: 'walk',
    name: '산책길',
    album: '가족 나들이',
    icon: Icons.park_outlined,
    color: Color(0xFFBFD2B5),
  ),
  PracticePhoto(
    id: 'gimbap',
    name: '김밥',
    album: '음식',
    icon: Icons.rice_bowl_outlined,
    color: Color(0xFFD6C3A7),
  ),
  PracticePhoto(
    id: 'fruit',
    name: '과일',
    album: '음식',
    icon: Icons.apple_outlined,
    color: Color(0xFFD9B7A9),
  ),
  PracticePhoto(
    id: 'sky',
    name: '하늘',
    album: '가족 나들이',
    icon: Icons.cloud_outlined,
    color: Color(0xFFBFD6E2),
  ),
  PracticePhoto(
    id: 'dog_drawing',
    name: '강아지 그림',
    album: '최근 사진',
    icon: Icons.pets_outlined,
    color: Color(0xFFD8C9B8),
  ),
];

const guidedPhotoScenario = PhotoSendScenario(
  title: '딸 김하늘에게 빨간 꽃 보내기',
  contactId: 'daughter',
  album: '꽃과 풍경',
  photoIds: ['red_flower'],
);

const soloPhotoScenarios = <PhotoSendScenario>[
  guidedPhotoScenario,
  PhotoSendScenario(
    title: '친구 이웃님에게 김밥과 과일 보내기',
    contactId: 'neighbor',
    album: '음식',
    photoIds: ['gimbap', 'fruit'],
  ),
  PhotoSendScenario(
    title: '가족 모임에 나들이 사진 3장 보내기',
    contactId: 'family',
    album: '가족 나들이',
    photoIds: ['beach', 'walk', 'sky'],
  ),
];

PracticeContact contactById(String id) =>
    practiceContacts.firstWhere((item) => item.id == id);

PracticePhoto photoById(String id) =>
    practicePhotos.firstWhere((item) => item.id == id);

class RaidConstants {
  // 드롭다운 표시용 카테고리
  static const Map<String, List<String>> dropdownCategory = {
    '전체 레이드': ['전체', '로아 유용한 팁'],
    '군단장 레이드': ['전체', '발탄', '비아키스', '쿠크세이튼', '아브렐슈드', '일리아칸', '카멘'],
    '어비스 던전': ['전체', '카양겔', '상아탑', '지평의 성당'],
    '에픽 레이드': ['전체', '베히모스'],
    '카제로스 레이드': [
      '전체',
      '(서막)에키드나',
      '(1막)에기르',
      '(2막)아브렐슈드',
      '(3막)모르둠',
      '(4막)아르모체',
      '(종막)카제로스',
    ],
    '그림자 레이드': ['전체', '세르카'],
  };

  // 등록 팝업용 카테고리
  static const Map<String, List<String>> raidByCategory = {
    '군단장 레이드': ['발탄', '비아키스', '쿠크세이튼', '아브렐슈드', '일리아칸', '카멘'],
    '어비스 던전': ['카양겔', '상아탑', '지평의 성당'],
    '에픽 레이드': ['베히모스'],
    '카제로스 레이드': [
      '(서막)에키드나',
      '(1막)에기르',
      '(2막)아브렐슈드',
      '(3막)모르둠',
      '(4막)아르모체',
      '(종막)카제로스',
    ],
    '그림자 레이드': ['세르카'],
  };

  // 기존 필터 로직에서 사용하던 변수 유지
  static const List<String> guideKeywords = [
    '전체',
    '발탄',
    '비아키스',
    '쿠크세이튼',
    '아브렐슈드',
    '일리아칸',
    '카멘',
    '카양겔',
    '상아탑',
    '지평의 성당',
    '베히모스',
    '서막',
    '1막',
    '2막',
    '3막',
    '4막',
    '종막',
    '세르카',
    '로아 유용한 팁',
  ];

  static const Map<String, String> keywordMapping = {
    '서막': '에키드나',
    '1막': '에기르',
    '2막': '아브렐슈드',
    '3막': '모르둠',
    '4막': '아르모체',
    '종막': '카제로스',
  };

  // YouTube Playlist IDs
  static const List<String> playlistIds = [
    'PLfeapZwXytc5hLWufxWTGOZsF9Hx_IsVa', // 꿀맹이는 여왕님 로스트아크 공략
    'PLMAYHL7_2pknWRmpGLK6kbsit75Vu4YC0', // 바보온돌 싱글모드 공략
    'PLMAYHL7_2pknNJ_VXH3jd-YtSZq13CBxc', // 바보온돌 헬/시련 공략
    'PLMAYHL7_2pknM3ZUjR68XASaXnOPKy2gB', // 바보온돌 어비스 던전
    'PLMAYHL7_2pkkhJVv05QgpN8ZIb5AjzGZf', // 바보온돌 군단장 레이드
    'PLQMXZuhZUJEBkcXgn9XPb_3xmMXpbXsy1', // 김상드 로스트아크 공략
    'PLMAYHL7_2pknYPEMC7wcP1WFINEfCS9xX', // 바보온돌 완전공략
    'PLSC2n1C_PEtvzu_S0z34-5zi2F_Sw16L1', // 레붕튜브 어둠의 바라트론(카멘)공략
    'PLSC2n1C_PEtveUZ0OW8s_xr9D9SvkJhRY', // 레붕튜브 카제로스 레이드 서막, 에키드나 공략
    'PLSC2n1C_PEttT5QCVgT4ZHUMCjLj6B2P3', // 레붕튜브 카제로스 레이드 1막, 에기르 공략
    'PLSC2n1C_PEtskqCw5bBd6HY31pGkVOwL7', // 레붕튜브 카제로스 레이드 2막 공략
    'PLSC2n1C_PEtuqxHJZHXioB5XQB9gDmtcn', // 레붕튜브 카제로스 레이드 3막 공략
    'PLSC2n1C_PEtuf2vA_GbhvXD-8S7fMw-Tu', // 레붕튜브 카제로스 레이드 4막 공략
    'PLSC2n1C_PEtu1XQJpHbqQ3B9d0qF0_PS1', // 레붕튜브 카제로스 레이드 종막 공략
    'PLSC2n1C_PEtut5Q3C0NTDBkiclH2Xqctm', // 레붕튜브 로아 이것저것 설명
    'PLXEP72pjkcHNZKbBW--1n4-dQiQmOown5'    // 가연우 로스트아크 시즌3 공략
  ];
}

### 1. 프로젝트명 및 소개
가장 먼저 프로젝트의 정체성과 서비스 링크를 명시하는 것이 좋습니다.
* **프로젝트명:** Raid-Hub (LostArk Hub - 공략 & 컨닝 페이퍼)
* **서비스 주소 (URL):** https://raidhub.co.kr
* **소개글:** 로스트아크(LostArk) 유저들을 위한 레이드 공략 및 컨닝 페이퍼를 제공하는 웹 애플리케이션입니다.
<img width="800" height="420" alt="image" src="https://github.com/user-attachments/assets/2c9aff22-2cfa-49d2-8147-202585dab7f7" />


### 2. 주요 기능
커밋 내역을 통해 파악된 주요 업데이트 및 기능들을 소개합니다.
* **공략 및 컨닝 페이퍼 제공:** 레이드 컨닝 페이퍼 업로드 기능 지원.
* **검색 및 정렬:** 사용자 편의를 위한 통합 검색 및 정렬 기능 구현.
* **영상 제공 (VideosGrid):** 최적화된 높이 고정 기능이 적용된 영상 그리드 뷰 제공.
* **통계 시스템:** 유저 혹은 서비스 데이터를 위한 통계 시스템 지원.
<img width="800" height="399" alt="image" src="https://github.com/user-attachments/assets/369fe908-668c-46c8-aa32-4f4e5975f942" />
<img width="800" height="399" alt="image" src="https://github.com/user-attachments/assets/9648fa4e-4210-46c5-b97c-56ad1ce29aa8" />



### 3. 기술 스택 (Tech Stack)
* **Frontend / Client:** Flutter (Dart). HTML 렌더러 방식을 사용하여 웹 앱으로 빌드 및 배포됩니다.
* **Backend:** Spring Boot (Java), Spring Security.
* **Database & Cache:** PostgreSQL, Redis (YouTube API 호출 제어 용도).
* **Infrastructure & Server:** Azure Virtual Machine (Ubuntu), Nginx.
<img width="1251" height="841" alt="Raid-Hub drawio" src="https://github.com/user-attachments/assets/27082d67-fa8f-4321-8fc5-01521a88f320" />


### 4. 프로젝트 구조 (Project Structure)
저장소의 주요 디렉토리 구조를 설명하여 기여자들이 코드를 쉽게 파악할 수 있도록 합니다.
* `raid_hub_frontend/`: 웹앱의 프론트엔드 소스 코드.
* `raid_hub_backend/`: 백엔드 소스 코드 및 초기 테스트 코드.
* `docs/ planning/` & `specs/`: 프로젝트 기획 문서 및 코드 명세서.
* `code_review_docs/`: 코드 리뷰 관련 문서.
* `uploads/ cheatsheets/`: 컨닝 페이퍼 업로드 파일 저장소.
* `data_dump.sql`: 데이터베이스 초기화 및 덤프 파일.
* `REVERSE_SUMMARY.md`: 프로젝트 요약 또는 리버스 엔지니어링 관련 문서.

### 5. 팀원 및 기여자 (Contributors)
함께 개발한 팀원들과 주요 역할입니다.
* **[JAEHYEOK LEE (ljhwogur)](https://github.com/ljhwogur) & [0verfl0w767](https://github.com/0verfl0w767):** Flutter 웹앱 풀스택 개발 및 클라우드(Azure) 인프라 구축
* **[Taeri (lola161385)](https://github.com/lola161385) & [PL-Taeri](https://github.com/PL-Taeri):** `code_review_docs/`(코드 리뷰 관련 문서) 및 `REVERSE_SUMMARY.md`(프로젝트 요약 또는 리버스 엔지니어링 관련 문서) 작성 및 관리

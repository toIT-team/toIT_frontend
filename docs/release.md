# 🚀 Release & Version Management
이 프로젝트는 `main` 브랜치를 기준으로 배포 가능한 앱 버전을 관리하며, GitHub Releases를 사용하여 배포 이력과 버전별 변경 사항을 기록합니다. Flutter 앱 배포는 iOS와 Android 빌드 결과물이 다르기 때문에, 릴리즈 문서에는 앱 버전, 빌드 번호, 배포 대상 플랫폼, 변경 사항을 함께 기록합니다.

## 🧭 Release Policy
현재 프로젝트는 별도의 `release` 브랜치를 사용하지 않습니다.

```text
feature/*
   ↓ Pull Request
main
   ↓ Tag
GitHub Releases
```
`main` 브랜치는 항상 배포 가능한 상태를 유지하는 것을 원칙으로 하며, 실제 배포 시점은 Git tag와 GitHub Releases를 통해 기록합니다.

## 🏷 Versioning Rule
Flutter 앱의 버전은 `pubspec.yaml`의 `version` 값을 기준으로 관리합니다.

```yaml
version: 1.0.0+1
```

버전 형식은 다음과 같습니다.

```text
MAJOR.MINOR.PATCH+BUILD_NUMBER
```

예시는 다음과 같습니다.
```text
1.0.0+1   첫 배포
1.0.1+2   버그 수정
1.1.0+3   기능 추가
2.0.0+4   큰 구조 변경 또는 호환되지 않는 변경
```

Git tag는 앱 버전과 동일하게 `v` prefix를 붙여 관리합니다.

```text
v1.0.0
v1.0.1
v1.1.0
v2.0.0
```

## 📦 GitHub Releases
GitHub Releases에는 다음 내용을 기록합니다.
- 배포 버전
- 주요 변경 사항
- 추가된 기능
- 수정된 문제
- 배포 대상 플랫폼
- Flutter / Dart 버전
- 배포 대상 브랜치 및 태그

Release 예시는 다음과 같습니다.

```text
Tag: v1.0.0
Target: main
Release title: v1.0.0 - 첫 배포
```

## 📝 Release Notes 작성 기준

Release Notes는 다음 형식을 기준으로 작성합니다.

```md
## v1.0.0 - 첫 배포

### 주요 내용
- toIT Flutter 앱 첫 배포
- 로그인 및 회원가입 화면 반영
- 보관함, 자료 등록, 일정, 알림 화면 반영
- iOS / Android 앱 배포 준비

### Changed
- 앱 초기 화면 구성
- API 연동 구조 반영
- 이미지 및 파일 업로드 플로우 반영

### Fixed
- iOS 빌드 의존성 설정 정리
- Flutter 버전 명시

### 배포 대상
- Branch: `main`
- Tag: `v1.0.0`
- Platform: iOS / Android
- Flutter: `3.41.8`
- Dart: `3.11.5`
```

## 📱 Flutter App Version

앱 버전은 `pubspec.yaml`에서 관리합니다.

```yaml
version: 1.0.0+1
```

버전 변경 기준은 다음과 같습니다.

### PATCH 변경

작은 버그 수정 또는 UI 문구 수정입니다.

```text
1.0.0+1 → 1.0.1+2
```

예시:
- 로그인 오류 수정
- 특정 화면 UI 깨짐 수정
- API 응답 처리 오류 수정

### MINOR 변경

새로운 기능이 추가되지만 기존 기능과 호환되는 변경입니다.

```text
1.0.0+1 → 1.1.0+2
```

예시:
- 새로운 화면 추가
- 새 자료 타입 추가
- 알림 설정 기능 추가

### MAJOR 변경

앱 구조가 크게 변경되거나 기존 기능과 호환되지 않는 변경입니다.
```text
1.0.0+1 → 2.0.0+2
```

예시:
- 인증 구조 전면 변경
- API 구조 대규모 변경
- 앱 내 핵심 플로우 변경

## 🧩 iOS Dependency Rule

iOS 의존성 설치 시 반드시 Bundler를 사용합니다.

- iOS 의존성 설치 관련 `bundle exec pod install` 활용할 것
- `pod install` 명령어 금지

사용 예시는 다음과 같습니다.

```bash
cd ios
bundle exec pod install
```

직접 `pod install`을 실행하지 않는 이유는  개발자마다 로컬 CocoaPods 버전이 달라져 iOS 빌드 결과가 달라질 수 있기 때문입니다. 따라서 iOS 의존성 설치는 항상 프로젝트에 정의된 Bundler 환경을 기준으로 실행합니다.

## 🛠 Development Version

현재 프로젝트에서 사용하는 Flutter / Dart 버전은 다음과 같습니다.
```text
Flutter 3.41.8 (stable)
Dart 3.11.5
DevTools 2.54.2
```

개발자는 위 버전을 기준으로 빌드 및 테스트를 수행합니다.

## 🧪 Build Check

Release 생성 전에는 다음 명령어로 기본 빌드 검증을 수행합니다.

```bash
flutter clean
flutter pub get
flutter analyze
```

iOS 의존성 설치가 필요한 경우 다음 명령어를 사용합니다.

```bash
cd ios
bundle exec pod install
cd ..
```

iOS 빌드 확인:

```bash
flutter build ios
```

Android 빌드 확인:

```bash
flutter build apk --release
```

또는 App Bundle 배포가 필요한 경우:

```bash
flutter build appbundle --release
```

## 🍎 iOS Release Build

iOS 배포 빌드는 다음 흐름을 기준으로 진행합니다.

```text
pubspec.yaml version 수정
        ↓
flutter clean
        ↓
flutter pub get
        ↓
cd ios
        ↓
bundle exec pod install
        ↓
Xcode Archive
        ↓
TestFlight 또는 App Store Connect 업로드
```

iOS 배포 시에는 다음 항목을 확인합니다.

- Bundle Identifier
- Signing Certificate
- Provisioning Profile
- App Version
- Build Number
- Apple Login 설정
- Kakao Login URL Scheme 설정
- Firebase 설정 파일 포함 여부

## 🤖 Android Release Build

Android 배포 빌드는 다음 흐름을 기준으로 진행합니다.

```text
pubspec.yaml version 수정
        ↓
flutter clean
        ↓
flutter pub get
        ↓
flutter build appbundle --release
        ↓
Google Play Console 업로드
```

Android 배포 시에는 다음 항목을 확인합니다.

- Application ID
- Version Name
- Version Code
- Signing Key
- Firebase 설정 파일 포함 여부
- Kakao Login Redirect 설정
- Google Play 권한 설명

## ⚠️ Release Asset Policy

GitHub Releases에는 앱 빌드 산출물을 기본적으로 첨부하지 않습니다.

특히 저장소가 Public Repository일 수 있으므로,  
다음 파일은 GitHub Releases에 첨부하지 않습니다.

- `.ipa`
- `.apk`
- `.aab`
- Firebase 설정 파일
- 서명 키
- 인증서
- provisioning profile
- keystore

Release는 배포 이력과 변경 사항을 기록하는 용도로 사용하며,  
실제 앱 배포 파일은 App Store Connect 또는 Google Play Console에 업로드합니다.

## ✅ Release Checklist

Release 생성 전 다음 항목을 확인합니다.

- [ ] `main` 브랜치가 최신 상태인지 확인
- [ ] `pubspec.yaml`의 `version` 값 수정
- [ ] Flutter / Dart 버전 확인
- [ ] `flutter analyze` 통과
- [ ] iOS 의존성 설치 시 `bundle exec pod install` 사용
- [ ] iOS 빌드 확인
- [ ] Android 빌드 확인
- [ ] Git tag 생성
- [ ] GitHub Release 작성
- [ ] Release Notes 작성
- [ ] App Store Connect 또는 Google Play Console 배포 진행
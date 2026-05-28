# toIT

toIT Flutter application.

## 📦 Release & Version Management

이 프로젝트는 `main` 브랜치를 기준으로 배포 가능한 앱 버전을 관리하며, GitHub Releases를 사용하여 배포 이력과 버전별 변경 사항을 기록합니다. 자세한 Flutter 앱 배포 및 버전 관리 규칙은 다음 문서에서 확인합니다.

👉 [Release & Version Management 문서 바로가기](./docs/release.md)


## 🧩 iOS Dependency Rule
- iOS 의존성 설치 관련 `bundle exec pod install` 활용할 것
- `pod install` 명령어 금지

사용 예시:
```bash
cd ios
bundle exec pod install
```

## 🛠 Version
- Flutter 3.41.8 (stable)
- Dart 3.11.5 • DevTools 2.54.2